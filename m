From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] multiple eth0 mixed PCI/ISA init
Date: Fri, 19 Dec 2003 15:14:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219151415.1cfdbe66.shemminger@osdl.org>
References: <Pine.GS4.4.33.0312192251180.6715-100000@lutra.sztaki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zoltan Farkas <zfarkas@lutra.sztaki.hu>, Jeff Garzik
 <jgarzik@pobox.com>,
        Alexander Viro <aviro@redhat.com>
In-Reply-To: <Pine.GS4.4.33.0312192251180.6715-100000@lutra.sztaki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

PCI is getting initialized before the old ISA probing code, so your PCI card
is grabbing eth0 before the ISA card gets started.  

You might be able workaround the problem probably by doing:
	netdev=0,1,0,0,eth0
which should cause the ISA probe code to skip eth0 and go on to eth1

This patch should fix 2.6.0 (have similar but different fix for net-drivers-2.5-exp).
I don't have an ISA card to actually test this code path.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
+++ b/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
@@ -350,7 +350,7 @@
 	 * Backwards compatibility - historically an I/O base of 1 was 
 	 * used to indicate not to probe for this ethN interface 
 	 */
-	if (dev->base_addr == 1) {
+	if (__dev_get_by_name(dev->name) || dev->base_addr == 1) {
 		free_netdev(dev);
 		return -ENXIO;
 	}
