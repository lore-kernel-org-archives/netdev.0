From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Sun, 18 Sep 2016 13:26:30 -0700
Message-ID: <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53220 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758424AbcIRU0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:26:37 -0400
Received: from mfilter24-d.gandi.net (mfilter24-d.gandi.net [217.70.178.152])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 9E70B1720A1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 22:26:34 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter24-d.gandi.net (mfilter24-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id HW5UVEFTzmp9 for <netdev@vger.kernel.org>;
        Sun, 18 Sep 2016 22:26:33 +0200 (CEST)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id E112417209B
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 22:26:32 +0200 (CEST)
Received: by mail-io0-f173.google.com with SMTP id m79so74826872ioo.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 13:26:32 -0700 (PDT)
In-Reply-To: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 3:09 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> In 93515d53b1
>   "net: move vlan pop/push functions into common code"
> skb_vlan_pop was moved from its private location in openvswitch to
> skbuff common code.
>
> In case !vlan_tx_tag_present, the original 'pop_vlan()' assured
> that skb->len is sufficient for the existence of a vlan_ethhdr
> (if skb->len < VLAN_ETH_HLEN then pop was a no-op).
>
> This validation was moved as is into the new common 'skb_vlan_pop'.
>
> Alas, in its original location (openvswitch), there's a guarantee that
> 'data' points to the mac_header, therefore the 'skb->len < VLAN_ETH_HLEN'
> condition made sense.
> However there's no such guarantee in the generic 'skb_vlan_pop'.
>
> For short packets received in rx path going through 'skb_vlan_pop',
> this causes 'skb_vlan_pop' to fail pop-ing a valid vlan hdr (in case tag
> is in payload), or to fail moving next tag into hw-accel tag.
>
> Instead, verify that 'skb->mac_len' is sufficient.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
>  Spotted by code review while doing work augmenting tc act vlan.
>
>  net/core/skbuff.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 1e329d4112..cc2c004838 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
>         } else {
>                 if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
>                               skb->protocol != htons(ETH_P_8021AD)) ||
> -                            skb->len < VLAN_ETH_HLEN))
> +                            skb->mac_len < VLAN_ETH_HLEN))

There is already check in __skb_vlan_pop() to validate skb for a vlan
header. So it is safe to drop this check entirely.
