From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 03/11] cirrus/mac89x0: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:54 +0100
Message-ID: <1330091162-8141-4-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM instead
of custom code.

Use memcpy to set the address to dev->dev_addr in set_mac_address,
instead of mxing it up in a for loop with printing a debug msg.

Check also if the given address is valid.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cirrus/mac89x0.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index 83781f3..a7324ce 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -592,10 +592,14 @@ static void set_multicast_list(struct net_device *dev)
 static int set_mac_address(struct net_device *dev, void *addr)
 {
 	int i;
-	printk("%s: Setting MAC address to ", dev->name);
-	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i] = ((unsigned char *)addr)[i]);
-	printk(".\n");
+	struct sockaddr *saddr = addr;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	printk("%s: Setting MAC address to %pM\n", dev->name, dev->dev_addr);
+
 	/* set the Ethernet address */
 	for (i=0; i < ETH_ALEN/2; i++)
 		writereg(dev, PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));
-- 
1.7.8.3
