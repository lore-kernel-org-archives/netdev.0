From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 15:31:34 -0500 (EST)
Message-ID: <20121207.153134.25835204617509469.davem@davemloft.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, linville@tuxdriver.com
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424190Ab2LGUbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 15:31:37 -0500
In-Reply-To: <1354906561-4695-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>
Date: Fri,  7 Dec 2012 19:56:01 +0100

Wireless folks, please take a look.  The issue is that,
under the circumstances listed below, we get SKBs in
the AF_PACKET input path that are shared.

Given the logic present in ieee80211_deliver_skb() I think
the mac80211 code doesn't expect this either.

More commentary from me below:

> This patch is adding a check on skb before trying to defrag the
> packet for the hash computation in fanout mode. The goal of this
> patch is to avoid an kernel crash in pskb_expand_head.
> It appears that under some specific condition there is a shared
> skb reaching the defrag code and this lead to a crash due to the
> following code:
> 
> 	if (skb_shared(skb))
> 		BUG();
> 
> I've observed this crash under the following condition:
>  1. a program is listening to an wifi interface (let say wlan0)
>  2. it is using fanout capture in flow load balancing mode
>  3. defrag option is on on the fanout socket
>  4. the interface disconnect (radio down for example)
>  5. the interface reconnect (radio switched up)
>  6. once reconnected a single packet is seen with skb->users=2
>  7. the kernel crash in pskb_expand_head at skbuff.c:1035
> 
> [BBB55:744364] [<ffffffff812a2761>] ? __pskb_pull_tail+0x43x0x26f
> [BB8S5.744395] [<ffffffff812d29Tb>] ? ip_check_defrag+ox3a/0x14a
> [BBB55.744422] [<ffffffffB1344459>] ? packet_rcv_fanout+ox5e/oxf9
> [BBBS5.7444S0] [<ffffffffB12aaS9b>] ? __netif_receive_skb+ox444/ox4f9
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? netif_receive_skb+ox6d/0x?3
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_deliver_skb+0xbd/0xfa [mac80211]
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_rx_h_data+0x1e0/0x21a [mac80211]
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? ieee80211_rx_handlers+0x3d5/0x480 [mac80211]
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? __wake_up
> [BBB55.T4447B] [<ffffffffB12aa?e1>] ? evdev_eventr+0xc0/0xcf [evdev]
> 
> Signed-off-by: Eric Leblond <eric@regit.org>

So if we look at ieee80211_deliver_skb(), it has code to deal with unaligned
packet headers, wherein it memoves() the data into a better aligned location.

But if these SKBs really are skb_shared(), this packet data
modification is illegal.

I suspect that the assumptions built into this unaligned data handling
code, and AF_PACKET, are correct.  Meaning that we should never see
skb_shared() packets here.  We just have a missing skb_copy()
somewhere in mac80211, Johannes can you please take a look?

Thanks.
