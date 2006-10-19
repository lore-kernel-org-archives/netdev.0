From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Thu, 19 Oct 2006 15:04:08 -0400
Message-ID: <20061019190407.GA23446@gospo.rdu.redhat.com>
References: <200610162021.12884.dpc@asn.pl> <200610162107.57477.dpc@asn.pl> <20061016213053.GA16231@gospo.rdu.redhat.com> <200610171016.21964.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:24509 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1946384AbWJSTEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 15:04:21 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
Content-Disposition: inline
In-Reply-To: <200610171016.21964.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2006 at 10:16:21AM +0200, Dawid Ciezarkiewicz wrote:
> 
> In fact - as default weight is being set to 1, without changing it wrr bonding 
> mode works like plain round-robin one. But it have little more overhead 
> (recharging tokens), and code is a bit more complicated. I was not sure if 
> some tools could assume that in mode 0 all interfaces work with same weights 
> and because of that behave strange with this patch in use. 
> 
> It was written as a solution for some problem, and I'm still not sure if such 
> change will always be patch to linux kernel or may some day go into mainline. 
> For compatibility I've decided to have those modes separated.
> 
> Because of that I haven't replaced mode 0. If this patch will be considered 
> useful, and my concerns are not a problem - I'd like to replace 0 mode if 
> possible.
> -

It would seem to me that extending an existing mode would be more
desirable than adding yet another mode to worry about.  I don't even
like the fact that there are as many as there are, but I understand why
they are there.  

I recently extended rr mode to allow an additional parameter called that
rr_repeat that would allow someone to send more than a single frame out
of each device before moving to the next one.  It seemed this could be
helpful when dealing with switches that constantly re-learned source MAC
addresses.  Network performance would suffer whenever rr_repeat was >1,
but box performance might be better if there weren't so many locks
taken.

This patch is pretty bad (in-fact even the math could be done better to
avoid the expensive modulo), but since I did did it as a proof of
concept I wasn't too worried about it at the time.  The functionality
might be interesting to add to your weighted rr concept.  It's also
against an older kernel, but it should apply to an upstream one with
minimal, if any, porting.


--- linux/drivers/net/bonding/bond_main.c.orig	2006-10-11 10:41:07.611562000 -0400
+++ linux/drivers/net/bonding/bond_main.c	2006-10-11 13:40:54.767425000 -0400
@@ -543,6 +543,7 @@
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
 #define BOND_LINK_MON_INTERV	0
 #define BOND_LINK_ARP_INTERV	0
+#define BOND_RR_REPEAT		1
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int miimon	= BOND_LINK_MON_INTERV;
@@ -555,6 +556,8 @@ static char *lacp_rate	= NULL;
 static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
+static int rr_repeat   = BOND_RR_REPEAT;
+static int rr_repeat_count = 0;
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -578,6 +581,8 @@ MODULE_PARM(arp_interval, "i");
 MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
 MODULE_PARM(arp_ip_target, "1-" __MODULE_STRING(BOND_MAX_ARP_TARGETS) "s");
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
+MODULE_PARM(rr_repeat, "i");
+MODULE_PARM_DESC(rr_repeat, "number of frames to send on round-robin bonds before switching interfaces");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -4390,21 +4395,27 @@ static int bond_xmit_roundrobin(struct s
 		goto out;
 	}
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (IS_UP(slave->dev) &&
-		    (slave->link == BOND_LINK_UP) &&
-		    (slave->state == BOND_STATE_ACTIVE)) {
-			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+	/* just xmit if we haven't hit the repeat val */
+	if (!(++rr_repeat_count % rr_repeat)) {
 
-			write_lock(&bond->curr_slave_lock);
-			bond->curr_active_slave = slave->next;
-			write_unlock(&bond->curr_slave_lock);
+		rr_repeat_count = 0;
+		bond_for_each_slave_from(bond, slave, i, start_at) {
+			if (IS_UP(slave->dev) &&
+			    (slave->link == BOND_LINK_UP) &&
+			    (slave->state == BOND_STATE_ACTIVE)) {
+				res = bond_dev_queue_xmit(bond, skb, slave->dev);
 
-			break;
+				write_lock(&bond->curr_slave_lock);
+				bond->curr_active_slave = slave->next;
+				write_unlock(&bond->curr_slave_lock);
+
+				break;
+			}
 		}
+	} else {
+		res = bond_dev_queue_xmit(bond, skb, slave->dev);
 	}
 
-
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
