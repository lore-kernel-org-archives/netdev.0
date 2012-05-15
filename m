From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 3/9] macvtap: zerocopy: put page when fail to get
 all requested user pages
Date: Tue, 15 May 2012 10:33:56 -0700
Message-ID: <1337103236.8220.13.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034157.11782.66606.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:41718 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966051Ab2EORe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 13:34:26 -0400
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Tue, 15 May 2012 13:34:24 -0400
In-Reply-To: <20120502034157.11782.66606.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 11:41 +0800, Jason Wang wrote:
> When get_user_pages_fast() fails to get all requested pages, we could
> not use
> kfree_skb() to free it as it has not been put in the skb fragments. So
> we need
> to call put_page() instead.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/macvtap.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 7cb2684..9ab182a 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -531,9 +531,11 @@ static int zerocopy_sg_from_iovec(struct sk_buff
> *skb, const struct iovec *from,
>                 size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >>
> PAGE_SHIFT;
>                 num_pages = get_user_pages_fast(base, size, 0,
> &page[i]);
>                 if ((num_pages != size) ||
> -                   (num_pages > MAX_SKB_FRAGS -
> skb_shinfo(skb)->nr_frags))
> -                       /* put_page is in skb free */
> +                   (num_pages > MAX_SKB_FRAGS -
> skb_shinfo(skb)->nr_frags)) {
> +                       for (i = 0; i < num_pages; i++)
> +                               put_page(page[i]);
>                         return -EFAULT;
> +               }
>                 truesize = size * PAGE_SIZE;
>                 skb->data_len += len;
>                 skb->len += len; 

Good catch. I don't know why I thought put_page would be called in
skb_free for these pages which hadn't been added to skb frags before. :(

thanks
Shirley
