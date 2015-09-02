From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Wed, 2 Sep 2015 09:04:00 +0900
Message-ID: <20150902000400.GA14821@gmail.com>
References: <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150817.140222.1763422851882964859.davem@davemloft.net>
 <55D492CC.6010602@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35830 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbIBAEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 20:04:07 -0400
Received: by pacfv12 with SMTP id fv12so11664543pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 17:04:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55D492CC.6010602@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 04:29:32PM +0200, Daniel Borkmann wrote:
> On 08/17/2015 11:02 PM, David Miller wrote:
> >From: Daniel Borkmann <daniel@iogearbox.net>
> >Date: Fri, 14 Aug 2015 12:38:21 +0200
> >
> >>diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> >>index 67d2104..4307446 100644
> >>--- a/net/netlink/af_netlink.c
> >>+++ b/net/netlink/af_netlink.c
> >>@@ -238,6 +238,13 @@ static void __netlink_deliver_tap(struct sk_buff
> >>*skb)
> >>
> >>  static void netlink_deliver_tap(struct sk_buff *skb)
> >>  {
> >>+	/* Netlink mmaped skbs must not access shared info, and thus
> >>+	 * are not allowed to be cloned. For now, just don't allow
> >>+	 * them to get inspected by taps.
> >>+	 */
> >>+	if (netlink_skb_is_mmaped(skb))
> >>+		return;
> >>+
> >
> >I would seriously rather see us do an expensive full copy of the SKB
> >than to have traffic which is unexpectedly invisible to taps.
> 
> Do you mean generically as we do in TX path, or only in this
> particular scenario?

It seems that we only handle this particular scenario.

I think I can understand the cause of the panic. The original mmaped
skb, allocated by netlink_alloc_skb, has a skb destructor which set
skb head NULL. This prevents from accessing shared info in
skb_release_all, so my concerns that the shared info of original skb
may be accessed in kfree_skb and may cause a panic, is unnecessary.

But since skb_clone does not copy the destructor, skb_release_all
calls skb_release_data for cloned skb, accessing shared info and
causes the panic, I think. Setting the destructor after clone could
not fix the problem since __dev_queue_xmit call path,
netif_skb_features?, accesses shared info.

Talking about skb_copy path, original skb's shared info is accessed
only in copy_skb_header, to get gso related field. As a result of
those, we can avoid the panic by:

  @@ -205,7 +205,10 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
        int ret = -ENOMEM;

        dev_hold(dev);
        -       nskb = skb_clone(skb, GFP_ATOMIC);
        +       if (netlink_skb_is_mmaped(skb))
        +               nskb = skb_copy(skb, GFP_ATOMIC);
        +       else
        +               nskb = skb_clone(skb, GFP_ATOMIC);
        
Thanks to you, my question become clear:
Should we set gso_size to 0 after copying to make skb_is_gso
returning false?

Thanks,
