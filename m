From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Sat, 15 Aug 2015 11:25:05 +0900
Message-ID: <20150815022505.GA30991@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
 <20150812.163819.620222685130362816.davem@davemloft.net>
 <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fw@strlen.de,
	David Miller <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32847 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbbHOCZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 22:25:12 -0400
Received: by pabyb7 with SMTP id yb7so70466989pab.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 19:25:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55CDC51D.1060204@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

Thank you for taking your time and trying to understand, even though
one of samples is wrong. correct one is:

    rx only mmaped nflog sample:
    https://gist.github.com/chamaken/dc0f80c14862e8061c06/raw/365c8a106840368f313a3791958da9be0f5fbed0/rxring-nflog.c

> >Currently, what happens is that the shared info accesses whatever
> >memory is there in the mmaped region. So when you already do an
> >skb_clone() you should already get into trouble right there f.e. when
> >we test for orphaning frags etc (if at the right offset in the mmap
> >buffer, the tx_flags member would contain a SKBTX_DEV_ZEROCOPY bit).

And I'm afraid of a skb which does not have shared info can be released
by kfree_skb or not if the next frame is valid. i.e. the current
skb->end, shared info points to the next frame's nm_status, say
NL_MMAP_STATUS_SKIP, and handle it as shared info pointer.

> Ken-ichirou, have you observed this issue only in relation to nlmon?

Yes,

> if taps are indeed the only ones affected, it might probably not be
> worth adding that much complexity for a fix itself, but to keep it simple
> instead. I don't know if there are any real users of netlink mmap, but

You mean mmaped skb can not be monitored by nlmon for a while?
I'll follow you, it's tough for me to fix this issue.

> It seems you have some other, separate fixes in your series, so you might
> want to submit them separately against the net tree, instead?

I'll follow you too.
Thank you, I appreciate.

>  include/linux/netlink.h  |  4 ++++
>  net/netlink/af_netlink.c | 12 +++++++-----
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 9120edb..42cdcd8 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -35,6 +35,10 @@ struct netlink_skb_parms {
>  #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
>  #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
> 
> +static inline bool netlink_skb_is_mmaped(const struct sk_buff *skb)
> +{
> +	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
> +}
> 
>  extern void netlink_table_grab(void);
>  extern void netlink_table_ungrab(void);
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 67d2104..4307446 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -238,6 +238,13 @@ static void __netlink_deliver_tap(struct sk_buff *skb)
> 
>  static void netlink_deliver_tap(struct sk_buff *skb)
>  {
> +	/* Netlink mmaped skbs must not access shared info, and thus
> +	 * are not allowed to be cloned. For now, just don't allow
> +	 * them to get inspected by taps.
> +	 */
> +	if (netlink_skb_is_mmaped(skb))
> +		return;
> +
>  	rcu_read_lock();
> 
>  	if (unlikely(!list_empty(&netlink_tap_all)))
> @@ -278,11 +285,6 @@ static void netlink_rcv_wake(struct sock *sk)
>  }
> 
>  #ifdef CONFIG_NETLINK_MMAP
> -static bool netlink_skb_is_mmaped(const struct sk_buff *skb)
> -{
> -	return NETLINK_CB(skb).flags & NETLINK_SKB_MMAPED;
> -}
> -
>  static bool netlink_rx_is_mmaped(struct sock *sk)
>  {
>  	return nlk_sk(sk)->rx_ring.pg_vec != NULL;
> -- 
> 1.9.3
