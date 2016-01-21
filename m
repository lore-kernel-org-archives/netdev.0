From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v4)
Date: Thu, 21 Jan 2016 09:35:06 +0100
Message-ID: <20160121083506.GA2251@nanopsycho.orion>
References: <1453354378-3018-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	jay.vosburgh@canonical.com, zyjzyj2000@gmail.com
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34940 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbcAUIfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 03:35:09 -0500
Received: by mail-wm0-f66.google.com with SMTP id 123so9264001wmz.2
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 00:35:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1453354378-3018-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 21, 2016 at 06:32:58AM CET, wen.gang.wang@oracle.com wrote:
>In a bonding setting, we determines fragment size according to MTU and
>PMTU associated to the bonding master. If the slave finds the fragment
>size is too big, it drops the fragment and calls ip_rt_update_pmtu(),
>passing _skb_ and _pmtu_, trying to update the path MTU.
>Problem is that the target device that function ip_rt_update_pmtu actually
>tries to update is the slave (skb->dev), not the master. Thus since no
>PMTU change happens on master, the fragment size for later packets doesn't
>change so all later fragments/packets are dropped too.
>
>The fix is letting build_skb_flow_key() take care of the transition of
>device index from bonding slave to the master. That makes the master become
>the target device that ip_rt_update_pmtu tries to update PMTU to.
>
>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>---
> net/ipv4/route.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>
>diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>index 85f184e..7e766b5 100644
>--- a/net/ipv4/route.c
>+++ b/net/ipv4/route.c
>@@ -524,10 +524,19 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
> {
> 	const struct iphdr *iph = ip_hdr(skb);
> 	int oif = skb->dev->ifindex;
>+	struct net_device *master;
> 	u8 tos = RT_TOS(iph->tos);
> 	u8 prot = iph->protocol;
> 	u32 mark = skb->mark;
> 
>+	if (netif_is_bond_slave(skb->dev)) {
>+		rcu_read_lock();
>+		master = netdev_master_upper_dev_get_rcu(skb->dev);
>+		if (master)
>+			oif = master->ifindex;
>+		rcu_read_unlock();
>+	}

This is certainly not correct as it should not be bond-specific but
rather generic. Note that you may have bond over bond or bridge over
bond or other scenarios, which this patch ignores.
