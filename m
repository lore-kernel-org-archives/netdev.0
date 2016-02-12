From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: e1000e: initialization breaks IPMI support on
	80003ES2LAN
Date: Fri, 12 Feb 2016 16:58:47 +0100
Message-ID: <20160212155847.GA22910@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, Bruce Allan <bruce.w.allan@intel.com>,
	David Ertman <davidx.m.ertman@intel.com>, e1000-devel@lists.sourceforge.net
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

We have Intel 80003ES2LAN nics on SGI Altix XE310 servers (SuperMicro
Baseboard, with product name X7DGT). On those machines, one of the NIC
port is bridged internally with the BMC.

It seems that during the e1000e driver initialization (at boot time),
the NIC is reset, which causes the BMC to stop working (it stops
responding to pings, the IPMI SOL console stops working; a reboot
restores it, until the next driver initialization).

The exact same problem also occurs on Bull Novascale R422E1 nodes, with
the SuperMicro X7DWT baseboard.

It worked in the past (we noticed it when upgrading from Debian wheezy
(3.2 kernel) to Debian jessie (3.16 kernel)). Using git bisect, I tracked
this down to commit 2800209994f878b00724ceabb65d744855c8f99a (included
in Linux 3.15).

Digging further (as this commit is quite large), it seems that this
specific change introduced the problem:

--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3687,10 +3687,6 @@ void e1000e_power_up_phy(struct e1000_adapter *adapter)
  */
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
-       /* WoL is enabled */
-       if (adapter->wol)
-               return;
-
        if (adapter->hw.phy.ops.power_down)
                adapter->hw.phy.ops.power_down(&adapter->hw);
 }

I also confirmed that reverting this change on top of a 4.4 kernel, with
the following patch, fixes the problem (i.e. the BMC works again).

--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3791,6 +3791,8 @@ void e1000e_power_up_phy(struct e1000_adapter *adapter)
  */
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
+       return;
+
        if (adapter->hw.phy.ops.power_down)
                adapter->hw.phy.ops.power_down(&adapter->hw);
 }


My understanding is that, during driver initialization, e1000e_reset()
is called, which calls e1000_power_down_phy(), which breaks the BMC.

Given the comment above the code that was removed, I suspected that it
could also break WoL, but I haven't confirmed that.

I can test patches if needed.
-- 
| Lucas Nussbaum      Assistant professor @ Univ. de Lorraine |
| lucas.nussbaum@loria.fr                     LORIA / MADYNES |
| http://www.loria.fr/~lnussbau/            +33 3 54 95 86 19 |

------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
