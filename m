From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: Fix crash on receiving VLAN frames
Date: Fri, 3 May 2013 08:04:40 -0700
Message-ID: <20130503080440.73032f54@nehalam.linuxnetplumber.net>
References: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Mirko Lindner <mlindner@marvell.com>
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:48704 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762442Ab3ECPE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 11:04:57 -0400
Received: by mail-da0-f43.google.com with SMTP id u7so846455dae.2
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 08:04:57 -0700 (PDT)
In-Reply-To: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  3 May 2013 18:22:04 +0400
Kirill Smelkov <kirr@mns.spb.ru> wrote:

> After recent 86a9bad3 (net: vlan: add protocol argument to packet
> tagging functions) my sky2 started to crash on receive of tagged
> frames, with backtrace similar to
> 
>     #CRASH!!!
>     vlan_do_receive
>     __netif_receive_skb_core
>     __netif_receive_skb
>     netif_receive_skb
>     sky2_poll
>     ...
>     __net_rx_action
>     __do_softirq
> 
> The problem turned out to be:
> 
>     1) sky2 copies small packets from ring on RX, and in its
>        receive_copy() skb header is copied manually field, by field, and
>        only for some fields;
> 
>     2) 86a9bad3  added skb->vlan_proto, which vlan_untag() or
>        __vlan_hwaccel_put_tag() set, and which is later used in
>        vlan_do_receive().
> 
>        That patch updated copy_skb_header() for newly introduced
>        skb->vlan_proto, but overlooked the need to also copy it in sky2's
>        receive_copy().
> 
> Because of 2, we have the following scenario:
> 
>     - frame is received and tagged in a ring, by sky2_rx_tag(). Both
>       skb->vlan_proto and skb->vlan_tci are set;
> 
>     - later skb is decided to be copied, but skb->vlan_proto is
>       forgotten and becomes 0.
> 
>     - in the beginning of vlan_do_receive() we call
> 
>         __be16 vlan_proto = skb->vlan_proto;
>         vlan_dev = vlan_find_dev(skb->dev, vlan_proto, vlan_id);
> 
>       which eventually invokes
> 
>         vlan_proto_idx(vlan_proto)
> 
>       and that routine BUGs for everything except ETH_P_8021Q and
>       ETH_P_8021AD.
> 
>       Oops.
> 
> Fix it.
> 
> P.S.
> 
> Stephen, I wonder, why copy_skb_header() is not used in
> sky2.c::receive_copy() ? Problems, where receive_copy was updated field
> by field showed several times already, e.g.
> 
>     3f42941b    (sky2: propogate rx hash when packet is copied)
>     e072b3fa    (sky2: fix receive length error in mixed non-VLAN/VLAN traffic)
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Mirko Lindner <mlindner@marvell.com>
> Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>

I wonder what other drivers have same issue?
Looking again, copy_skb_header is overkill, it clones a lot of other values
which is not needed on a freshly received skb. The skb at that point has
not had all the other properties set.
