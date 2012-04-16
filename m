From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] macvtap: zerocopy: validate vector length before
 pinning user pages
Date: Mon, 16 Apr 2012 08:53:03 +0200
Message-ID: <1334559183.28012.45.camel@edumazet-glaptop>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
	 <20120416060807.14140.96229.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mst@redhat.com, ebiederm@xmission.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416060807.14140.96229.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-16 at 14:08 +0800, Jason Wang wrote:
> Currently we do not validate the vector length before calling
> get_user_pages_fast(), host stack would be easily overflowed by
> malicious guest driver who give us a descriptor with length greater
> than MAX_SKB_FRAGS. Solve this problem by checking the free entries
> before trying to pin user pages.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/macvtap.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 7cb2684..d197a78 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -529,6 +529,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		}
>  		base = (unsigned long)from->iov_base + offset;
>  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> +		if (i + size >= MAX_SKB_FRAGS)
> +			return -EFAULT;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if ((num_pages != size) ||
>  		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
> 

Hi Jason

Why is -EFAULT the right error code ?

Also, why not removing the "(num_pages > MAX_SKB_FRAGS -
skb_shinfo(skb)->nr_frags)" test done few lines after ?

Also, if get_user_pages_fast() returns truncated result (size - 1 for
example), we apparently dont free the references on pages.

The comment applies only on pages that were added in skb frags.
