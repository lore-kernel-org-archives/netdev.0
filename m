From: Scott Feldman <scott.feldman@intel.com>
Subject: Re: e100: "Freeing alive device f7dd8000, eth%d"
Date: Sat, 5 Apr 2003 22:24:20 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304052219240.5390-100000@localhost.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010128A28B@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010128A28B@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Apr 2003, Andrew Morton wrote:

> This message comes out all the time when e100 is being brought up.

[cut]

> I'm not sure what the right fix is here - perhaps the driver just
> shouldn't be playing with link state at all in the probe handler, and
> this should actually happen in the open() routine.

This should do the trick, but I'd like to get some testing on it in the QA
lab before giving thumbs up.

-scott


--- linux-2.5.66/drivers/net/e100/e100_phy.c.orig	Sat Apr  5 21:57:42 2003
+++ linux-2.5.66/drivers/net/e100/e100_phy.c	Sat Apr  5 22:00:44 2003
@@ -995,14 +995,13 @@
 {
 	unsigned char link;
 
-	/* Logical AND PHY link & netif_running */
-	link = e100_get_link_state(bdp) && netif_running(bdp->device);
+	link = e100_get_link_state(bdp);
 
 	if (link) {
-		if (!netif_carrier_ok(bdp->device))
+		if(!netif_carrier_ok(bdp->device) && netif_running(bdp->device))
 			netif_carrier_on(bdp->device);
 	} else {
-		if (netif_carrier_ok(bdp->device))
+		if(netif_carrier_ok(bdp->device) && netif_running(bdp->device))
 			netif_carrier_off(bdp->device);
 	}
 
