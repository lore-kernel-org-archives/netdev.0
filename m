From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about memory leak detector giving false positive
 report for net/core/flow.c
Date: Mon, 26 Sep 2011 21:46:35 +0200
Message-ID: <1317066395.2796.11.camel@edumazet-laptop>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
	 <1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Huajun Li <huajun.li.lee@gmail.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel
 <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux-foundation.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le lundi 26 septembre 2011 =C3=A0 17:50 +0100, Catalin Marinas a =C3=A9cr=
it :
> On Mon, Sep 26, 2011 at 05:32:54PM +0100, Eric Dumazet wrote:
> > Le lundi 26 septembre 2011 =C3=A0 23:17 +0800, Huajun Li a =C3=A9crit=
 :
> > > Memory leak detector gives following memory leak report, it seems t=
he
> > > report is triggered by net/core/flow.c, but actually, it should be =
a
> > > false positive report.
> > > So, is there any idea from kmemleak side to fix/disable this false
> > > positive report like this?
> > > Yes, kmemleak_not_leak(...) could disable it, but is it suitable fo=
r this case ?
> ...
> > CC lkml and percpu maintainers (Tejun Heo & Christoph Lameter ) as we=
ll
> >=20
> > AFAIK this false positive only occurs if percpu data is allocated
> > outside of embedded pcu space.=20
> >=20
> >  (grep pcpu_get_vm_areas /proc/vmallocinfo)
> >=20
> > I suspect this is a percpu/kmemleak cooperation problem (a missing
> > kmemleak_alloc() ?)
> >=20
> > I am pretty sure kmemleak_not_leak() is not the right answer to this
> > problem.
>=20
> kmemleak_not_leak() definitely not the write answer. The alloc_percpu()
> call does not have any kmemleak_alloc() callback, so it doesn't scan
> them.
>=20
> Huajun, could you please try the patch below:
>=20
> 8<--------------------------------
> kmemleak: Handle percpu memory allocation
>=20
> From: Catalin Marinas <catalin.marinas@arm.com>
>=20
> This patch adds kmemleak callbacks from the percpu allocator, reducing =
a
> number of false positives caused by kmemleak not scanning such memory
> blocks.
>=20
> Reported-by: Huajun Li <huajun.li.lee@gmail.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  mm/percpu.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/percpu.c b/mm/percpu.c
> index bf80e55..c47a90b 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -67,6 +67,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
>  #include <linux/workqueue.h>
> +#include <linux/kmemleak.h>
> =20
>  #include <asm/cacheflush.h>
>  #include <asm/sections.h>
> @@ -833,7 +834,9 @@ fail_unlock_mutex:
>   */
>  void __percpu *__alloc_percpu(size_t size, size_t align)
>  {
> -	return pcpu_alloc(size, align, false);
> +	void __percpu *ptr =3D pcpu_alloc(size, align, false);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
>  EXPORT_SYMBOL_GPL(__alloc_percpu);
> =20
> @@ -855,7 +858,9 @@ EXPORT_SYMBOL_GPL(__alloc_percpu);
>   */
>  void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
>  {
> -	return pcpu_alloc(size, align, true);
> +	void __percpu *ptr =3D pcpu_alloc(size, align, true);
> +	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> +	return ptr;
>  }
> =20
>  /**
> @@ -915,6 +920,8 @@ void free_percpu(void __percpu *ptr)
>  	if (!ptr)
>  		return;
> =20
> +	kmemleak_free(ptr);
> +
>  	addr =3D __pcpu_ptr_to_addr(ptr);
> =20
>  	spin_lock_irqsave(&pcpu_lock, flags);
>=20

Hmm, you need to call kmemleak_alloc() for each chunk allocated per
possible cpu.

Here is the (untested) patch for the allocation phase, need the same at
freeing time

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 89633fe..5061ac5 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -37,9 +37,12 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chun=
k, int off, int size)
 {
 	unsigned int cpu;
=20
-	for_each_possible_cpu(cpu)
-		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
+	for_each_possible_cpu(cpu) {
+		void *chunk_addr =3D (void *)pcpu_chunk_addr(chunk, cpu, 0) + off;
=20
+		kmemleak_alloc(chunk_addr, size, 1, GFP_KERNEL);
+		memset(chunk_addr, 0, size);
+	}
 	return 0;
 }
=20
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index ea53496..0d397cc 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -342,8 +342,12 @@ static int pcpu_populate_chunk(struct pcpu_chunk *ch=
unk, int off, int size)
 	/* commit new bitmap */
 	bitmap_copy(chunk->populated, populated, pcpu_unit_pages);
 clear:
-	for_each_possible_cpu(cpu)
-		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
+	for_each_possible_cpu(cpu) {
+		void *chunk_addr =3D (void *)pcpu_chunk_addr(chunk, cpu, 0) + off;
+
+		kmemleak_alloc(chunk_addr, size, 1, GFP_KERNEL);
+		memset(chunk_addr, 0, size);
+	}
 	return 0;
=20
 err_unmap:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
