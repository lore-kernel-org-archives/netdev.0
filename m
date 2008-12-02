From: Yu Zhao <yu.zhao@intel.com>
Subject: [SR-IOV driver example 2/3 resend] PF driver: integrate
	with SR-IOV core
Date: Tue, 2 Dec 2008 17:42:51 +0800
Message-ID: <20081202094251.GB1974@yzhao12-linux.sh.intel.com>
References: <20081121183605.GA7810@yzhao12-linux.sh.intel.com>
	<20081202092741.GA1859@yzhao12-linux.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"matthew@wil.cx" <matthew@wil.cx>, "greg@kroah.com" <greg@kroah.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "Rose,
	Gregory V" <gregory.v.rose@intel.com>, "Nakajima,
	Jun" <jun.nakajima@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <20081202092741.GA1859@yzhao12-linux.sh.intel.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

This patch integrates the IGB driver with the SR-IOV core. It shows how
the SR-IOV API is used to support the capability. Obviously people does
not need to put much effort to integrate the PF driver with SR-IOV core.
All SR-IOV standard stuff are handled by SR-IOV core and PF driver only
concerns the device specific resource allocation and deallocation once it
gets the necessary information (i.e. number of Virtual Functions) from
the callback function.

From: Intel Corporation, LAN Access Division <e1000-devel@lists.sourceforge.net>
Signed-off-by: Yu Zhao <yu.zhao@intel.com>

---
 drivers/net/igb/igb_main.c |   46 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f0361ef..78bda11 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -138,6 +138,7 @@ void igb_set_mc_list_pools(struct igb_adapter *, struct e1000_hw *, int, u16);
 static int igb_vmm_control(struct igb_adapter *, bool);
 static int igb_set_vf_mac(struct net_device *, int, u8*);
 static void igb_mbox_handler(struct igb_adapter *);
+static int igb_virtual(struct pci_dev *, int);
 
 static int igb_suspend(struct pci_dev *, pm_message_t);
 #ifdef CONFIG_PM
@@ -182,6 +183,7 @@ static struct pci_driver igb_driver = {
 #endif
 	.shutdown = igb_shutdown,
 	.err_handler = &igb_err_handler,
+	.virtual = igb_virtual
 };
 
 static int global_quad_port_a; /* global quad port a indication */
@@ -5066,4 +5068,48 @@ void igb_set_mc_list_pools(struct igb_adapter *adapter,
 	wr32(E1000_VMOLR(pool), reg_data);
 }
 
+static	int
+igb_virtual(struct pci_dev *pdev, int nr_virtfn)
+{
+	int i;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	/* the VFs' MAC addresses are hard-coded */
+	unsigned char my_mac_addr[6] = {0x00, 0xDE, 0xAD, 0xBE, 0xEF, 0xFF};
+
+	/*
+	 * the 82576 NIC supports 1-PF NIC + 7-VF NICs mode and 8-VF NICs
+	 * mode. In the 8-VF NICs mode, the PF can't tx/rx packets -- it
+	 * only behaves as 'VF supervisor'. For now we use the 1-PF NIC +
+	 * 7-VF NICs mode to preserve PF's tx/rx capability for the debug
+	 * purpose.
+	 */
+	if (nr_virtfn > (MAX_NUM_VFS - 1))
+		return -EINVAL;
+
+	if (nr_virtfn) {
+		dev_info(&pdev->dev, "SR-IOV is enabled\n");
+		/*
+		 * Currently VFs resources are pre-allocated, so just set
+		 * the MAC addresses of each VF here.
+		 */
+		for (i = 0; i < nr_virtfn; i++) {
+			my_mac_addr[5] = (unsigned char)i;
+			igb_set_vf_mac(netdev, i, my_mac_addr);
+			igb_set_vf_vmolr(adapter, i);
+		}
+	} else {
+		/*
+		 * Since we statically allocate tx/rx queues for the PF
+		 * and the VFs, so we don't need to free any VF related
+		 * resources here.
+		 */
+		dev_info(&pdev->dev, "SR-IOV is disabled\n");
+	}
+
+	adapter->vfs_allocated_count = nr_virtfn;
+
+	return 0;
+}
+
 /* igb_main.c */
-- 
1.5.6.4
