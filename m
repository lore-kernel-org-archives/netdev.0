From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 15/17] bonding: include ARP and Xmit Hash Policy
 information in /proc file
Date: Fri, 1 Jul 2005 14:08:52 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011404150.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For bonds configured to do ARP monitoring, this patch displays polling 
interval and ip targets info in their respective proc files.

For balance-XOR and 802.3ad modes, this patch displays Xmit Hash Policy.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -3370,6 +3370,8 @@
  {
  	struct bonding *bond = seq->private;
  	struct slave *curr;
+	int i;
+	u32 target;

  	read_lock(&bond->curr_slave_lock);
  	curr = bond->curr_active_slave;
@@ -3378,6 +3366,13 @@
  	seq_printf(seq, "Bonding Mode: %s\n",
  		   bond_mode_name(bond->params.mode));

+	if (bond->params.mode == BOND_MODE_XOR ||
+		bond->params.mode == BOND_MODE_8023AD) {
+		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
+			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
+			bond->params.xmit_policy);
+	}
+
  	if (USES_PRIMARY(bond->params.mode)) {
  		seq_printf(seq, "Primary Slave: %s\n",
  			   (bond->primary_slave) ? 
@@ -3394,6 +3403,24 @@
  	seq_printf(seq, "Down Delay (ms): %d\n",
  		   bond->params.downdelay * bond->params.miimon);

+
+	// ARP information
+	if(bond->params.arp_interval > 0) {
+		seq_printf(seq, "ARP Polling Interval (ms): %d\n", 
+				bond->params.arp_interval);
+
+		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
+
+		for(i = 0; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i] ;i++) {
+			target = ntohl(bond->params.arp_targets[i]);
+			seq_printf(seq, " %d.%d.%d.%d", HIPQUAD(target));
+			if((i+1 < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i+1]) 
+				seq_printf(seq, ",");
+			else
+				seq_printf(seq, "\n");
+		}
+	}
+
  	if (bond->params.mode == BOND_MODE_8023AD) {
  		struct ad_info ad_info;
