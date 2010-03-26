From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-2.6 PATCH v2] bonding: fix broken multicast with round-robin mode
Date: Thu, 25 Mar 2010 17:55:14 -0700
Message-ID: <32741.1269564914@death.nxdomain.ibm.com>
References: <20100325214033.GA28741@gospo.rdu.redhat.com> <24080.1269556271@death.nxdomain.ibm.com> <20100326004905.GB28741@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org, lhh@redhat.com,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58468 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063Ab0CZAzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 20:55:19 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2Q0mfbt022781
	for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 18:48:41 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2Q0tHn7132616
	for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 18:55:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2Q0tGH2017581
	for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 18:55:17 -0600
In-reply-to: <20100326004905.GB28741@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>Here is an updated and tested patch:
>
>[net-2.6 PATCH] bonding: fix broken multicast with round-robin mode
>
>Round-robin (mode 0) does nothing to ensure that any multicast traffic
>originally destined for the host will continue to arrive at the host when
>the link that sent the IGMP join or membership report goes down.  One of
>the benefits of absolute round-robin transmit.
>
>Keeping track of subscribed multicast groups for each slave did not seem
>like a good use of resources, so I decided to simply send on the
>curr_active slave of the bond (typically the first enslaved device that
>is up).  This makes failover management simple as IGMP membership
>reports only need to be sent when the curr_active_slave changes.  I
>tested this patch and it appears to work as expected.
>
>Originally reported by Lon Hohberger <lhh@redhat.com>.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>CC: Lon Hohberger <lhh@redhat.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
> drivers/net/bonding/bond_main.c |   40 +++++++++++++++++++++++++++++++-------
> 1 files changed, 32 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 430c022..5b92fbf 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
> 			write_lock_bh(&bond->curr_slave_lock);
> 		}
> 	}
>+
>+	/* resend IGMP joins since all were sent on curr_active_slave */
>+	if (bond->params.mode == BOND_MODE_ROUNDROBIN) {
>+		bond_resend_igmp_join_requests(bond);
>+	}
> }
>
> /**
>@@ -4138,22 +4143,41 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	struct slave *slave, *start_at;
> 	int i, slave_no, res = 1;
>+	struct iphdr *iph = ip_hdr(skb);
>
> 	read_lock(&bond->lock);
>
> 	if (!BOND_IS_OK(bond))
> 		goto out;
>-
> 	/*
>-	 * Concurrent TX may collide on rr_tx_counter; we accept that
>-	 * as being rare enough not to justify using an atomic op here
>+	 * Start with the curr_active_slave that joined the bond as the
>+	 * default for sending IGMP traffic.  For failover purposes one
>+	 * needs to maintain some consistency for the interface that will
>+	 * send the join/membership reports.  The curr_active_slave found
>+	 * will send all of this type of traffic.
> 	 */
>-	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
>+	if ((iph->protocol == htons(IPPROTO_IGMP)) &&
>+	    (skb->protocol == htons(ETH_P_IP))) {
>
>-	bond_for_each_slave(bond, slave, i) {
>-		slave_no--;
>-		if (slave_no < 0)
>-			break;
>+		read_lock(&bond->curr_slave_lock);
>+		slave = bond->curr_active_slave;
>+		read_unlock(&bond->curr_slave_lock);
>+
>+		if (!slave)
>+			goto out;
>+	} else {
>+		/*
>+		 * Concurrent TX may collide on rr_tx_counter; we accept
>+		 * that as being rare enough not to justify using an
>+		 * atomic op here.
>+		 */
>+		slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
>+
>+		bond_for_each_slave(bond, slave, i) {
>+			slave_no--;
>+			if (slave_no < 0)
>+				break;
>+		}
> 	}
>
> 	start_at = slave;
