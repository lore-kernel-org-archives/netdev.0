From: Stefan Assmann <sassmann@redhat.com>
Subject: [PATCH] igbvf: avoid name clash between PF and VF
Date: Wed, 30 Jun 2010 10:53:40 +0200
Message-ID: <4C2B0614.9040004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Andy Gospodarek <gospo@redhat.com>,
	jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com
To: netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Stefan Assmann <sassmann@redhat.com>

It looks like the VFs get initialized before all the PFs are. Therefore
the udev mapping MAC <-> ethX (for PFs) gets screwed because the VFs
may grab the ethX interface names (reserved by udev) for the PFs.

Example:
igb max_vfs=0
eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
eth1      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
eth2      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
eth3      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1
igb max_vfs=1
eth0      Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9E
eth1      Link encap:Ethernet  HWaddr 0A:CF:41:69:F7:A9
eth2      Link encap:Ethernet  HWaddr 3A:FE:20:4C:2A:3B
eth3      Link encap:Ethernet  HWaddr C6:C3:B1:56:C9:A4
eth3_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:9F
eth4      Link encap:Ethernet  HWaddr 6E:8A:8A:A3:5F:69
eth4_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A0
eth5_rename Link encap:Ethernet  HWaddr 00:13:20:F7:A5:A1

In the example above VF 0A:CF:41:69:F7:A9 grabs eth1 but udev
has a rule that says eth1 should be assigned PF 00:13:20:F7:A5:9F
(eth3_rename) and waits for the VF to disappear to rename eth3_rename
to eth1. Unfortunately eth1 is not going to disappear.
This is not a udev bug since udev doesn't create persistent rules for
VFs as their MAC address changes every reboot.

To avoid this problem we could change the kernel name for the VFs and
thus avoid confusion between VFs and PFs.

I've already discussed this with Alexander Duyck and Greg Rose, so far
they have no objection. However this problem appears for all drivers that
support PFs and VFs and thus the changes should be applied consistently
to all of these drivers.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 drivers/net/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 5e2b2a8..2fb665b 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);

-	strcpy(netdev->name, "eth%d");
+	strcpy(netdev->name, "veth%d");
 	err = register_netdev(netdev);
 	if (err)
 		goto err_hw_init;
-- 
1.6.5.2


------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
