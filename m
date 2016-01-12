From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v2)
Date: Tue, 12 Jan 2016 12:22:48 -0800
Message-ID: <12940.1452630168@famine>
References: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
Cc: netdev@vger.kernel.org
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49419 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbcALUWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:22:51 -0500
In-reply-to: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wengang Wang <wen.gang.wang@oracle.com> wrote:

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

	Does the team driver have the equivalent issue?

>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>---
> net/ipv4/route.c | 10 +++++++++-
> 1 file changed, 9 insertions(+), 1 deletion(-)
>
>diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>index 85f184e..fffc7e6 100644
>--- a/net/ipv4/route.c
>+++ b/net/ipv4/route.c
>@@ -523,10 +523,18 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
> 			       const struct sock *sk)
> {
> 	const struct iphdr *iph = ip_hdr(skb);
>-	int oif = skb->dev->ifindex;
> 	u8 tos = RT_TOS(iph->tos);
>+	struct net_device *master;
> 	u8 prot = iph->protocol;
> 	u32 mark = skb->mark;
>+	int oif;
>+
>+	if (skb->dev->flags & IFF_SLAVE) {
>+		master = netdev_master_upper_dev_get(skb->dev);
>+		oif = master->ifindex;
>+	} else {
>+		oif = skb->dev->ifindex;
>+	}

	netdev_master_upper_dev_get() requires RTNL to be held; I don't
see that all callers to build_skb_flow_key will do so.

	I also believe the above would dereference a NULL pointer if an
eql device is configured, as it uses IFF_SLAVE but doesn't use the
upper/lower device infrastructure, thus, netdev_master_upper_dev_get()
would likely return NULL for eql.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
