From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix bridge notification processing
Date: Tue, 29 Jul 2003 17:07:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030729170715.7ff9bbc7.shemminger@osdl.org>
References: <20030722234508.0af40e80.shemminger@osdl.org>
	<20030724033430.GA20304@mautner.ca>
	<20030724102821.GA32274@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
   Christian Mautner <christian@mautner.ca>,
   "David S. Miller" <davem@redhat.com>, Andrew Morton <akpm@digeo.com>
In-Reply-To: <20030724102821.GA32274@gareth.mathematik.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jul 2003 12:28:21 +0200
Steffen Klassert <klassert@mathematik.tu-chemnitz.de> wrote:

> I probably found the problem.
> If I do
> 
> brctl addbr br0
> brctl addif br0 eth0
> brctl addif br0 eth1
> ifconfig eth0 up
> ifconfig eth1 up
> ifconfig br0 up

The bridge needs to ignore up/down notifications when it is down (like 2.4);
somewhere with all the other changes I put in, a bug got in and it was looking
at networks when the bridge is down.  When bridge comes up it scans and sees
the state...

This applies against 2.6.0-test2 (i.e. after my earlier fixup patch).

diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	Tue Jul 29 17:01:45 2003
+++ b/net/bridge/br_notify.c	Tue Jul 29 17:01:45 2003
@@ -39,19 +39,23 @@
 	br = p->br;
 
 	spin_lock_bh(&br->lock);
+
 	switch (event) 
 	{
 	case NETDEV_CHANGEADDR:
 		br_fdb_changeaddr(p, dev->dev_addr);
-		br_stp_recalculate_bridge_id(br);
+		if (br->dev->flags & IFF_UP)
+			br_stp_recalculate_bridge_id(br);
 		break;
 
 	case NETDEV_DOWN:
-		br_stp_disable_port(p);
+		if (br->dev->flags & IFF_UP)
+			br_stp_disable_port(p);
 		break;
 
 	case NETDEV_UP:
-		br_stp_enable_port(p);
+		if (br->dev->flags & IFF_UP)
+			br_stp_enable_port(p);
 		break;
 
 	case NETDEV_UNREGISTER:
