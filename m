From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 21 Sep 2004 15:58:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921155835.18aee381.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040920203021.GD4242@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 22:30:21 +0200
Andi Kleen <ak@suse.de> wrote:

> I see the same problem here, but it's even worse. I only get 150-200KB/s
> sending data with scp from a fast machine with e1000 with a gigabit link. 
> netperf also gives only 250KB/s. 

So I re-enabled TSO support in the loopback driver to try and
reproduce this, but I can't.

There has been a lot of churn in this area so please make sure you
are using the latest sources, all of my current TSO fixes are in
Linus's BK tree.

And, take the patch below and do a loopback bandwidth test before
and after the patch is applied.  Do things slow down when loopback
has TSO enabled just as it does for your gigabit interfaces?

(If you want to use the ethtool bits included here, you'll
 have to first recompile the ethtool utility with the
 non-sense "eth" and "usb" device name checks removed...)

===== drivers/net/loopback.c 1.17 vs edited =====
--- 1.17/drivers/net/loopback.c	2004-06-22 14:07:33 -07:00
+++ edited/drivers/net/loopback.c	2004-09-21 15:33:04 -07:00
@@ -49,6 +49,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/ethtool.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <linux/if_ether.h>	/* For the statistics structure. */
@@ -183,6 +184,17 @@
 	return stats;
 }
 
+u32 loopback_get_link(struct net_device *dev)
+{
+	return 1;
+}
+
+static struct ethtool_ops loopback_ethtool_ops = {
+	.get_link		= loopback_get_link,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= ethtool_op_set_tso,
+};
+
 struct net_device loopback_dev = {
 	.name	 		= "lo",
 	.mtu			= (16 * 1024) + 20 + 20 + 12,
@@ -198,7 +210,9 @@
 	.flags			= IFF_LOOPBACK,
 	.features 		= NETIF_F_SG|NETIF_F_FRAGLIST
 				  |NETIF_F_NO_CSUM|NETIF_F_HIGHDMA
+				  |NETIF_F_TSO
 				  |NETIF_F_LLTX,
+	.ethtool_ops		= &loopback_ethtool_ops,
 };
 
 /* Setup and register the of the LOOPBACK device. */
