From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Fri, 23 Sep 2016 12:47:55 -0400
Message-ID: <57E55CBB.5060309@akamai.com>
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, 'Alexander Viro'
	<viro@zeniv.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, 'Michal Hocko'
	<mhocko@kernel.org>, <netdev@vger.kernel.org>, Eric Dumazet
	<eric.dumazet@gmail.com>
To: Nicholas Piggin <npiggin@gmail.com>, Hillf Danton
	<hillf.zj@alibaba-inc.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/23/2016 03:24 AM, Nicholas Piggin wrote:
> On Fri, 23 Sep 2016 14:42:53 +0800
> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
>
>>>
>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>>> with the number of fds passed. We had a customer report page allocation
>>> failures of order-4 for this allocation. This is a costly order, so it might
>>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>>>
>>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>>> physically contiguous. Also the allocation is temporary for the duration of the
>>> syscall, so it's unlikely to stress vmalloc too much.
>>>
>>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
>>> it doesn't need this kind of fallback.
>
> How about something like this? (untested)
>
> Eric isn't wrong about vmalloc sucking :)
>
> Thanks,
> Nick
>
>
> ---
>   fs/select.c | 57 +++++++++++++++++++++++++++++++++++++++++++--------------
>   1 file changed, 43 insertions(+), 14 deletions(-)
>
> diff --git a/fs/select.c b/fs/select.c
> index 8ed9da5..3b4834c 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -555,6 +555,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>   	void *bits;
>   	int ret, max_fds;
>   	unsigned int size;
> +	size_t nr_bytes;
>   	struct fdtable *fdt;
>   	/* Allocate small arguments on the stack to save memory and be faster */
>   	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
> @@ -576,21 +577,39 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>   	 * since we used fdset we need to allocate memory in units of
>   	 * long-words.
>   	 */
> -	size = FDS_BYTES(n);
> +	ret = -ENOMEM;
>   	bits = stack_fds;
> -	if (size > sizeof(stack_fds) / 6) {
> -		/* Not enough space in on-stack array; must use kmalloc */
> +	size = FDS_BYTES(n);
> +	nr_bytes = 6 * size;
> +
> +	if (unlikely(nr_bytes > PAGE_SIZE)) {
> +		/* Avoid multi-page allocation if possible */
>   		ret = -ENOMEM;
> -		bits = kmalloc(6 * size, GFP_KERNEL);
> -		if (!bits)
> -			goto out_nofds;
> +		fds.in = kmalloc(size, GFP_KERNEL);
> +		fds.out = kmalloc(size, GFP_KERNEL);
> +		fds.ex = kmalloc(size, GFP_KERNEL);
> +		fds.res_in = kmalloc(size, GFP_KERNEL);
> +		fds.res_out = kmalloc(size, GFP_KERNEL);
> +		fds.res_ex = kmalloc(size, GFP_KERNEL);
> +
> +		if (!(fds.in && fds.out && fds.ex &&
> +				fds.res_in && fds.res_out && fds.res_ex))
> +			goto out;
> +	} else {
> +		if (nr_bytes > sizeof(stack_fds)) {
> +			/* Not enough space in on-stack array */
> +			if (nr_bytes > PAGE_SIZE * 2)

The 'if' looks extraneous?

Also, I wonder if we can just avoid some allocations altogether by 
checking by if the user fd_set pointers are NULL? That can avoid failures :)

Thanks,

-Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
