From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [net-2.6 PATCH v2] bonding: fix broken multicast with
	round-robin mode
Date: Thu, 25 Mar 2010 20:49:05 -0400
Message-ID: <20100326004905.GB28741@gospo.rdu.redhat.com>
References: <20100325214033.GA28741@gospo.rdu.redhat.com> <24080.1269556271@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lhh@redhat.com,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085Ab0CZAtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 20:49:15 -0400
Content-Disposition: inline
In-Reply-To: <24080.1269556271@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 03:31:11PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >Round-robin (mode 0) does nothing to ensure that any multicast traffic
> >originally destined for the host will continue to arrive at the host when
> >the link that sent the IGMP join or membership report goes down.  One of
> >the benefits of absolute round-robin transmit.
> >
> >Keeping track of subscribed multicast groups for each slave did not seem
> >like a good use of resources, so I decided to simply send on the
> >curr_active slave of the bond (typically the first enslaved device that
> >is up).  This makes failover management simple as IGMP membership
> >reports only need to be sent when the curr_active_slave changes.  I
> >tested this patch and it appears to work as expected.
> >
> >Originally reported by Lon Hohberger <lhh@redhat.com>.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> 	Seems reasonable, modulo a couple of minor things (see below).
> 
> 	I checked, and the link failover logic appears to maintain
> curr_active_slave even for round robin mode, which, prior to this patch,
> didn't use it.

Correct.  I initially didn't plan to use that, but when I saw that it
was maintained for round-robin mode as well I decided it would be good
to use it rather than wasting space with another pointer.

> 
> >CC: Lon Hohberger <lhh@redhat.com>
> >CC: Jay Vosburgh <fubar@us.ibm.com>
> >
> >---
> > drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++++++--------
> > 1 files changed, 26 insertions(+), 8 deletions(-)
> >
> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >index 430c022..0b38455 100644
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
> > 			write_lock_bh(&bond->curr_slave_lock);
> > 		}
> > 	}
> >+
> >+	/* resend IGMP joins since all were sent on curr_active_slave */
> >+	if (bond->params.mode == BOND_MODE_ROUNDROBIN) {
> >+		bond_resend_igmp_join_requests(bond);
> >+	}
> > }
> >
> > /**
> >@@ -4138,22 +4143,35 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
> > 	struct bonding *bond = netdev_priv(bond_dev);
> > 	struct slave *slave, *start_at;
> > 	int i, slave_no, res = 1;
> >+	struct iphdr *iph = ip_hdr(skb);
> >
> > 	read_lock(&bond->lock);
> >
> > 	if (!BOND_IS_OK(bond))
> > 		goto out;
> >-
> > 	/*
> >-	 * Concurrent TX may collide on rr_tx_counter; we accept that
> >-	 * as being rare enough not to justify using an atomic op here
> >+	 * Start with the curr_active_slave that joined the bond as the
> >+	 * default for sending IGMP traffic.  For failover purposes one
> >+	 * needs to maintain some consistency for the interface that will
> >+	 * send the join/membership reports.  The curr_active_slave found
> >+	 * will send all of this type of traffic.
> > 	 */
> >-	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
> >+	if ((skb->protocol == htons(ETH_P_IP)) &&
> >+	    (iph->protocol == htons(IPPROTO_IGMP))) {
> >+		slave = bond->curr_active_slave;
> 
> 	Technically, this should acquire bond->curr_slave_lock for read
> around the inspection of curr_active_slave.
> 
> 	I believe you'll also want a test for curr_active_slave == NULL,
> and free the skb if so (or do something else).  There's a race window in
> bond_release: when releasing the curr_active_slave, the field is left
> momentarily NULL with the bond unlocked.  This occurs after the
> bond_change_active_slave(bond, NULL) call, during the lock dance prior
> to the call bond_select_active_slave:
> 
> bond_main.c:bond_release():
> [...]
> 	if (oldcurrent == slave)
> 		bond_change_active_slave(bond, NULL);
> [...]
> 	if (oldcurrent == slave) {
> 		/*
> 		 * Note that we hold RTNL over this sequence, so there
> 		 * is no concern that another slave add/remove event
> 		 * will interfere.
> 		 */
> 		write_unlock_bh(&bond->lock);
> 
> 		[ race window is here ]
> 
> 		read_lock(&bond->lock);
> 		write_lock_bh(&bond->curr_slave_lock);
> 
> 		bond_select_active_slave(bond);
> 
> 		write_unlock_bh(&bond->curr_slave_lock);
> 		read_unlock(&bond->lock);
> 		write_lock_bh(&bond->lock);
> 	}
> 
> 	I'm reasonably sure the other TX functions (that need to) will
> handle the case that curr_active_slave is NULL.
> 

Good catch, Jay.  Thanks for looking at this.

Here is an updated and tested patch:

[net-2.6 PATCH] bonding: fix broken multicast with round-robin mode

Round-robin (mode 0) does nothing to ensure that any multicast traffic
originally destined for the host will continue to arrive at the host when
the link that sent the IGMP join or membership report goes down.  One of
the benefits of absolute round-robin transmit.

Keeping track of subscribed multicast groups for each slave did not seem
like a good use of resources, so I decided to simply send on the
curr_active slave of the bond (typically the first enslaved device that
is up).  This makes failover management simple as IGMP membership
reports only need to be sent when the curr_active_slave changes.  I
tested this patch and it appears to work as expected.

Originally reported by Lon Hohberger <lhh@redhat.com>.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Lon Hohberger <lhh@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_main.c |   40 +++++++++++++++++++++++++++++++-------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 430c022..5b92fbf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
+
+	/* resend IGMP joins since all were sent on curr_active_slave */
+	if (bond->params.mode == BOND_MODE_ROUNDROBIN) {
+		bond_resend_igmp_join_requests(bond);
+	}
 }
 
 /**
@@ -4138,22 +4143,41 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int i, slave_no, res = 1;
+	struct iphdr *iph = ip_hdr(skb);
 
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond))
 		goto out;
-
 	/*
-	 * Concurrent TX may collide on rr_tx_counter; we accept that
-	 * as being rare enough not to justify using an atomic op here
+	 * Start with the curr_active_slave that joined the bond as the
+	 * default for sending IGMP traffic.  For failover purposes one
+	 * needs to maintain some consistency for the interface that will
+	 * send the join/membership reports.  The curr_active_slave found
+	 * will send all of this type of traffic.
 	 */
-	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
+	if ((iph->protocol == htons(IPPROTO_IGMP)) &&
+	    (skb->protocol == htons(ETH_P_IP))) {
 
-	bond_for_each_slave(bond, slave, i) {
-		slave_no--;
-		if (slave_no < 0)
-			break;
+		read_lock(&bond->curr_slave_lock);
+		slave = bond->curr_active_slave;
+		read_unlock(&bond->curr_slave_lock);
+
+		if (!slave)
+			goto out;
+	} else {
+		/*
+		 * Concurrent TX may collide on rr_tx_counter; we accept
+		 * that as being rare enough not to justify using an
+		 * atomic op here.
+		 */
+		slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
+
+		bond_for_each_slave(bond, slave, i) {
+			slave_no--;
+			if (slave_no < 0)
+				break;
+		}
 	}
 
 	start_at = slave;
