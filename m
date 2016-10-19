From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 08/10] mm: replace __access_remote_vm() write parameter
 with gup_flags
Date: Wed, 19 Oct 2016 09:59:03 +0200
Message-ID: <20161019075903.GP29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-9-lstoakes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Rik van Riel <riel@redhat.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mips@linux-mips.org, linux-rdma@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-sh@
To: Lorenzo Stoakes <lstoakes@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-9-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu 13-10-16 01:20:18, Lorenzo Stoakes wrote:
> This patch removes the write parameter from __access_remote_vm() and replaces it
> with a gup_flags parameter as use of this function previously _implied_
> FOLL_FORCE, whereas after this patch callers explicitly pass this flag.
> 
> We make this explicit as use of FOLL_FORCE can result in surprising behaviour
> (and hence bugs) within the mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

So I'm not convinced this (and the following two patches) is actually
helping much. By grepping for FOLL_FORCE we will easily see that any caller
of access_remote_vm() gets that semantics and can thus continue search
accordingly (it is much simpler than searching for all get_user_pages()
users and extracting from parameter lists what they actually pass as
'force' argument). Sure it makes somewhat more visible to callers of
access_remote_vm() that they get FOLL_FORCE semantics but OTOH it also
opens a space for issues where a caller of access_remote_vm() actually
wants FOLL_FORCE (and currently all of them want it) and just mistakenly
does not set it. All in all I'd prefer to keep access_remote_vm() and
friends as is...

								Honza

> ---
>  mm/memory.c | 23 +++++++++++++++--------
>  mm/nommu.c  |  9 ++++++---
>  2 files changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 20a9adb..79ebed3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3869,14 +3869,11 @@ EXPORT_SYMBOL_GPL(generic_access_phys);
>   * given task for page fault accounting.
>   */
>  static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
> -		unsigned long addr, void *buf, int len, int write)
> +		unsigned long addr, void *buf, int len, unsigned int gup_flags)
>  {
>  	struct vm_area_struct *vma;
>  	void *old_buf = buf;
> -	unsigned int flags = FOLL_FORCE;
> -
> -	if (write)
> -		flags |= FOLL_WRITE;
> +	int write = gup_flags & FOLL_WRITE;
>  
>  	down_read(&mm->mmap_sem);
>  	/* ignore errors, just check how much was successfully transferred */
> @@ -3886,7 +3883,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  		struct page *page = NULL;
>  
>  		ret = get_user_pages_remote(tsk, mm, addr, 1,
> -				flags, &page, &vma);
> +				gup_flags, &page, &vma);
>  		if (ret <= 0) {
>  #ifndef CONFIG_HAVE_IOREMAP_PROT
>  			break;
> @@ -3945,7 +3942,12 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  int access_remote_vm(struct mm_struct *mm, unsigned long addr,
>  		void *buf, int len, int write)
>  {
> -	return __access_remote_vm(NULL, mm, addr, buf, len, write);
> +	unsigned int flags = FOLL_FORCE;
> +
> +	if (write)
> +		flags |= FOLL_WRITE;
> +
> +	return __access_remote_vm(NULL, mm, addr, buf, len, flags);
>  }
>  
>  /*
> @@ -3958,12 +3960,17 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr,
>  {
>  	struct mm_struct *mm;
>  	int ret;
> +	unsigned int flags = FOLL_FORCE;
>  
>  	mm = get_task_mm(tsk);
>  	if (!mm)
>  		return 0;
>  
> -	ret = __access_remote_vm(tsk, mm, addr, buf, len, write);
> +	if (write)
> +		flags |= FOLL_WRITE;
> +
> +	ret = __access_remote_vm(tsk, mm, addr, buf, len, flags);
> +
>  	mmput(mm);
>  
>  	return ret;
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 70cb844..bde7df3 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1809,9 +1809,10 @@ void filemap_map_pages(struct fault_env *fe,
>  EXPORT_SYMBOL(filemap_map_pages);
>  
>  static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
> -		unsigned long addr, void *buf, int len, int write)
> +		unsigned long addr, void *buf, int len, unsigned int gup_flags)
>  {
>  	struct vm_area_struct *vma;
> +	int write = gup_flags & FOLL_WRITE;
>  
>  	down_read(&mm->mmap_sem);
>  
> @@ -1853,7 +1854,8 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  int access_remote_vm(struct mm_struct *mm, unsigned long addr,
>  		void *buf, int len, int write)
>  {
> -	return __access_remote_vm(NULL, mm, addr, buf, len, write);
> +	return __access_remote_vm(NULL, mm, addr, buf, len,
> +			write ? FOLL_WRITE : 0);
>  }
>  
>  /*
> @@ -1871,7 +1873,8 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
>  	if (!mm)
>  		return 0;
>  
> -	len = __access_remote_vm(tsk, mm, addr, buf, len, write);
> +	len = __access_remote_vm(tsk, mm, addr, buf, len,
> +			write ? FOLL_WRITE : 0);
>  
>  	mmput(mm);
>  	return len;
> -- 
> 2.10.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
