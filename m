From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [BUG] acess_ok() missing from zerocopy_sg_from_iovec()
Date: Tue, 4 Jun 2013 08:32:07 +0300
Message-ID: <20130604053207.GB19433@redhat.com>
References: <1370306052.24311.193.camel@edumazet-glaptop>
 <1370307969.24311.196.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279Ab3FDFbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 01:31:36 -0400
Content-Disposition: inline
In-Reply-To: <1370307969.24311.196.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 03, 2013 at 06:06:09PM -0700, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 17:34 -0700, Eric Dumazet wrote:
> > It looks like access_ok(VERIFY_READ, base, len) checks are missing in
> > drivers/net/tun.c & drivers/net/macvtap.c before the
> > get_user_pages_fast() calls.
> > 
> > Or am I missing something ?
> > 
> 
> Patch would be :
> 
> [PATCH] tun/macvtap: use access_ok(VERIFY_READ)
> 
> Zero copy is good if only we make all needed security checks.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This is only called if msg_control is set, and the
assumption is that callers of tun_sendmsg
are in-kernel callers that have validated the iovec.

> ---
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 59e9605..d793b7d 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -522,6 +522,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>  		if (i + size > MAX_SKB_FRAGS)
>  			return -EMSGSIZE;
> +		if (!access_ok(VERIFY_READ, base, len))
> +			return -EFAULT;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if (num_pages != size) {
>  			for (i = 0; i < num_pages; i++)
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 89776c5..7a7b3b1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1008,6 +1008,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>  		if (i + size > MAX_SKB_FRAGS)
>  			return -EMSGSIZE;
> +		if (!access_ok(VERIFY_READ, base, len))
> +			return -EFAULT;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if (num_pages != size) {
>  			for (i = 0; i < num_pages; i++)
> 
