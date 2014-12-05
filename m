From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC][PATCH 07/13] iov_iter.c: get rid of bvec_copy_page_{to,from}_iter()
Date: Fri, 05 Dec 2014 15:28:14 +0300
Message-ID: <5481A4DE.8040803@cogentembedded.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk> <1417724597-17099-7-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1417724597-17099-7-git-send-email-viro@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/4/2014 11:23 PM, Al Viro wrote:

    Looks like you've erred in the subject as you seem to be getting rid of 
copy_page_{to|from}_iter_bvec() instead of bvec_copy_page_{to|from}_iter()...

> From: Al Viro <viro@zeniv.linux.org.uk>

> Just have copy_page_{to,from}_iter() fall back to kmap_atomic +
> copy_{to,from}_iter() + kunmap_atomic() in ITER_BVEC case.  As
> the matter of fact, that's what we want to do for any iov_iter
> kind that isn't blocking - e.g. ITER_KVEC will also go that way
> once we recognize it on iov_iter.c primitives level

> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>   mm/iov_iter.c | 60 ++++++++++++++++++++++++-----------------------------------
>   1 file changed, 24 insertions(+), 36 deletions(-)

> diff --git a/mm/iov_iter.c b/mm/iov_iter.c
> index 39ad713..17b7144 100644
> --- a/mm/iov_iter.c
> +++ b/mm/iov_iter.c
> @@ -486,30 +486,33 @@ static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
>   	return wanted;
>   }
>
> -static size_t copy_page_to_iter_bvec(struct page *page, size_t offset,
> -					size_t bytes, struct iov_iter *i)
> +size_t copy_to_iter(void *addr, size_t bytes, struct iov_iter *i)
>   {
> -	void *kaddr = kmap_atomic(page);
> -	size_t wanted = copy_to_iter_bvec(kaddr + offset, bytes, i);
> -	kunmap_atomic(kaddr);
> -	return wanted;
> +	if (i->type & ITER_BVEC)
> +		return copy_to_iter_bvec(addr, bytes, i);
> +	else
> +		return copy_to_iter_iovec(addr, bytes, i);
>   }
> +EXPORT_SYMBOL(copy_to_iter);
>
> -static size_t copy_page_from_iter_bvec(struct page *page, size_t offset,
> -					size_t bytes, struct iov_iter *i)
> +size_t copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
>   {
> -	void *kaddr = kmap_atomic(page);
> -	size_t wanted = copy_from_iter_bvec(kaddr + offset, bytes, i);
> -	kunmap_atomic(kaddr);
> -	return wanted;
> +	if (i->type & ITER_BVEC)
> +		return copy_from_iter_bvec(addr, bytes, i);
> +	else
> +		return copy_from_iter_iovec(addr, bytes, i);
>   }
> +EXPORT_SYMBOL(copy_from_iter);
[...]

WBR, Sergei

