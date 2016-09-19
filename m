From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 16:05:17 +0300
Message-ID: <20160919160517.6ee28bde@pixies>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
        <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
        <20160919091538.56defd2b@pixies>
        <57DFD8A1.1090103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35949 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbcISNFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 09:05:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id b184so14904781wma.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 06:05:31 -0700 (PDT)
In-Reply-To: <57DFD8A1.1090103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 14:22:57 +0200, daniel@iogearbox.net wrote:
> On 09/19/2016 08:15 AM, Shmulik Ladkani wrote:
> > On Sun, 18 Sep 2016 13:26:30 -0700, pshelar@ovn.org wrote:
> >> On Sun, Sep 18, 2016 at 3:09 AM, Shmulik Ladkani
> >> <shmulik.ladkani@gmail.com> wrote:
> >>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >>> index 1e329d4112..cc2c004838 100644
> >>> --- a/net/core/skbuff.c
> >>> +++ b/net/core/skbuff.c
> >>> @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
> >>>          } else {
> >>>                  if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
> >>>                                skb->protocol != htons(ETH_P_8021AD)) ||
> >>> -                            skb->len < VLAN_ETH_HLEN))
> >>> +                            skb->mac_len < VLAN_ETH_HLEN))
> >>
> >> There is already check in __skb_vlan_pop() to validate skb for a vlan
> >> header. So it is safe to drop this check entirely.
> >
> > Seems validation in '__skb_vlan_pop' has slightly different semantics:
> >
> > 	unsigned int offset = skb->data - skb_mac_header(skb);
> >
> > 	__skb_push(skb, offset);
> > 	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
> >
> > this pushes 'data' back to mac_header, then makes sure there's sufficient
> > place in skb to _store_ VLAN_ETH_HLEN bytes (by pulling into linear part
> > if needed, or erroring if skb is too small).
> 
> Yes, but this skb_ensure_writable() is needed for doing the memmove anyway.

Had no intention dropping the skb_ensure_writable from __skb_vlan_pop :)

> > There's no guarantee the original mac header was sized VLAN_ETH_HLEN.
> 
> I'm wondering, what happens when you'd call this on tx path, when you'd
> change that to suggested skb->mac_len? Isn't that 0 in such case, thus
> such setups could fail then?

Thanks, I think you're right.

Seems __dev_queue_xmit needs a 'skb_reset_mac_len' right after call to
'skb_reset_mac_header' (or maybe call 'skb_reset_mac_len' from within
skb_reset_mac_header?).

Also, I'm okay with removing the excess 'skb->mac_len < VLAN_ETH_HLEN'
condition if it is agreed that the "tag exists but insufficient to pop"
semantic is no longer wanted.

Regards,
Shmulik
