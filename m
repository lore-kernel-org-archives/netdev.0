From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 9 Jun 2007 23:31:24 -0400
Message-ID: <20070610033124.GA29731@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33340 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757911AbXFJDb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 23:31:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A big batch of fixes for the newly added libertas wireless driver is
coming soon, too.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upst=
ream-linus

to receive the following updates:

 drivers/net/ehea/ehea.h                 |    2 +-
 drivers/net/ehea/ehea_main.c            |   12 ++---
 drivers/net/ibmveth.c                   |   80 +++++++++++++++++++++--=
--------
 drivers/net/netxen/netxen_nic.h         |   47 +++++++++---------
 drivers/net/netxen/netxen_nic_ethtool.c |    8 ++--
 drivers/net/netxen/netxen_nic_hw.c      |   12 ++--
 drivers/net/netxen/netxen_nic_init.c    |   23 +++++----
 drivers/net/netxen/netxen_nic_main.c    |    7 +++
 drivers/net/netxen/netxen_nic_niu.c     |    8 +--
 drivers/net/phy/marvell.c               |   62 +++++++++++++++++++++--=
-
 drivers/net/usb/Kconfig                 |    4 +-
 drivers/net/via-velocity.c              |    2 +-
 12 files changed, 172 insertions(+), 95 deletions(-)

Brian King (2):
      ibmveth: Fix h_free_logical_lan error on pool resize
      ibmveth: Automatically enable larger rx buffer pools for larger m=
tu

Dave Jones (1):
      typo in via-velocity.c

Kim Phillips (1):
      phylib: add RGMII-ID mode to the Marvell m88e1111 PHY to fix brok=
en ucc_geth

Mithlesh Thukral (2):
      NetXen: Fix ping issue after reboot on Blades with 3.4.19 firmwar=
e
      NetXen: Fix compile failure seen on PPC architecture

Sam Ravnborg (1):
      net: fix typo in drivers/net/usb/Kconfig

Thomas Klein (1):
      ehea: Fixed possible kernel panic on VLAN packet recv

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index e85a933..c0f81b5 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
=20
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0061"
+#define DRV_VERSION	"EHEA_0064"
=20
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index 152bb20..9e13433 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -451,7 +451,8 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_=
device *dev,
 				processed_rq3++;
 			}
=20
-			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+			    && port->vgrp)
 				vlan_hwaccel_receive_skb(skb, port->vgrp,
 							 cqe->vlan_tag);
 			else
@@ -1910,10 +1911,7 @@ static void ehea_vlan_rx_register(struct net_dev=
ice *dev,
 		goto out;
 	}
=20
-	if (grp)
-		memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
-	else
-		memset(cb1->vlan_filter, 0xFF, sizeof(cb1->vlan_filter));
+	memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
=20
 	hret =3D ehea_h_modify_ehea_port(adapter->handle, port->logical_port_=
id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
@@ -1947,7 +1945,7 @@ static void ehea_vlan_rx_add_vid(struct net_devic=
e *dev, unsigned short vid)
 	}
=20
 	index =3D (vid / 64);
-	cb1->vlan_filter[index] |=3D ((u64)(1 << (vid & 0x3F)));
+	cb1->vlan_filter[index] |=3D ((u64)(0x8000000000000000 >> (vid & 0x3F=
)));
=20
 	hret =3D ehea_h_modify_ehea_port(adapter->handle, port->logical_port_=
id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
@@ -1982,7 +1980,7 @@ static void ehea_vlan_rx_kill_vid(struct net_devi=
ce *dev, unsigned short vid)
 	}
=20
 	index =3D (vid / 64);
-	cb1->vlan_filter[index] &=3D ~((u64)(1 << (vid & 0x3F)));
+	cb1->vlan_filter[index] &=3D ~((u64)(0x8000000000000000 >> (vid & 0x3=
=46)));
=20
 	hret =3D ehea_h_modify_ehea_port(adapter->handle, port->logical_port_=
id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 3bec0f7..6ec3d50 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -915,17 +915,36 @@ static int ibmveth_change_mtu(struct net_device *=
dev, int new_mtu)
 {
 	struct ibmveth_adapter *adapter =3D dev->priv;
 	int new_mtu_oh =3D new_mtu + IBMVETH_BUFF_OH;
-	int i;
+	int reinit =3D 0;
+	int i, rc;
=20
 	if (new_mtu < IBMVETH_MAX_MTU)
 		return -EINVAL;
=20
+	for (i =3D 0; i < IbmVethNumBufferPools; i++)
+		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size)
+			break;
+
+	if (i =3D=3D IbmVethNumBufferPools)
+		return -EINVAL;
+
 	/* Look for an active buffer pool that can hold the new MTU */
 	for(i =3D 0; i<IbmVethNumBufferPools; i++) {
-		if (!adapter->rx_buff_pool[i].active)
-			continue;
+		if (!adapter->rx_buff_pool[i].active) {
+			adapter->rx_buff_pool[i].active =3D 1;
+			reinit =3D 1;
+		}
+
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
-			dev->mtu =3D new_mtu;
+			if (reinit && netif_running(adapter->netdev)) {
+				adapter->pool_config =3D 1;
+				ibmveth_close(adapter->netdev);
+				adapter->pool_config =3D 0;
+				dev->mtu =3D new_mtu;
+				if ((rc =3D ibmveth_open(adapter->netdev)))
+					return rc;
+			} else
+				dev->mtu =3D new_mtu;
 			return 0;
 		}
 	}
@@ -1243,16 +1262,19 @@ const char * buf, size_t count)
=20
 	if (attr =3D=3D &veth_active_attr) {
 		if (value && !pool->active) {
-			if(ibmveth_alloc_buffer_pool(pool)) {
-                                ibmveth_error_printk("unable to alloc =
pool\n");
-                                return -ENOMEM;
-                        }
-			pool->active =3D 1;
-			adapter->pool_config =3D 1;
-			ibmveth_close(netdev);
-			adapter->pool_config =3D 0;
-			if ((rc =3D ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				if(ibmveth_alloc_buffer_pool(pool)) {
+					ibmveth_error_printk("unable to alloc pool\n");
+					return -ENOMEM;
+				}
+				pool->active =3D 1;
+				adapter->pool_config =3D 1;
+				ibmveth_close(netdev);
+				adapter->pool_config =3D 0;
+				if ((rc =3D ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->active =3D 1;
 		} else if (!value && pool->active) {
 			int mtu =3D netdev->mtu + IBMVETH_BUFF_OH;
 			int i;
@@ -1281,23 +1303,29 @@ const char * buf, size_t count)
 		if (value <=3D 0 || value > IBMVETH_MAX_POOL_COUNT)
 			return -EINVAL;
 		else {
-			adapter->pool_config =3D 1;
-			ibmveth_close(netdev);
-			adapter->pool_config =3D 0;
-			pool->size =3D value;
-			if ((rc =3D ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				adapter->pool_config =3D 1;
+				ibmveth_close(netdev);
+				adapter->pool_config =3D 0;
+				pool->size =3D value;
+				if ((rc =3D ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->size =3D value;
 		}
 	} else if (attr =3D=3D &veth_size_attr) {
 		if (value <=3D IBMVETH_BUFF_OH || value > IBMVETH_MAX_BUF_SIZE)
 			return -EINVAL;
 		else {
-			adapter->pool_config =3D 1;
-			ibmveth_close(netdev);
-			adapter->pool_config =3D 0;
-			pool->buff_size =3D value;
-			if ((rc =3D ibmveth_open(netdev)))
-				return rc;
+			if (netif_running(netdev)) {
+				adapter->pool_config =3D 1;
+				ibmveth_close(netdev);
+				adapter->pool_config =3D 0;
+				pool->buff_size =3D value;
+				if ((rc =3D ibmveth_open(netdev)))
+					return rc;
+			} else
+				pool->buff_size =3D value;
 		}
 	}
=20
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxe=
n_nic.h
index ad6688e..272f8c3 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -68,9 +68,10 @@
 #define _NETXEN_NIC_LINUX_SUBVERSION 2
 #define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
=20
-#define NUM_FLASH_SECTORS (64)
-#define FLASH_SECTOR_SIZE (64 * 1024)
-#define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
+#define NETXEN_NUM_FLASH_SECTORS (64)
+#define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
+#define NETXEN_FLASH_TOTAL_SIZE  (NETXEN_NUM_FLASH_SECTORS \
+					* NETXEN_FLASH_SECTOR_SIZE)
=20
 #define PHAN_VENDOR_ID 0x4040
=20
@@ -677,28 +678,28 @@ struct netxen_new_user_info {
=20
 /* Flash memory map */
 typedef enum {
-	CRBINIT_START =3D 0,	/* Crbinit section */
-	BRDCFG_START =3D 0x4000,	/* board config */
-	INITCODE_START =3D 0x6000,	/* pegtune code */
-	BOOTLD_START =3D 0x10000,	/* bootld */
-	IMAGE_START =3D 0x43000,	/* compressed image */
-	SECONDARY_START =3D 0x200000,	/* backup images */
-	PXE_START =3D 0x3E0000,	/* user defined region */
-	USER_START =3D 0x3E8000,	/* User defined region for new boards */
-	FIXED_START =3D 0x3F0000	/* backup of crbinit */
+	NETXEN_CRBINIT_START =3D 0,	/* Crbinit section */
+	NETXEN_BRDCFG_START =3D 0x4000,	/* board config */
+	NETXEN_INITCODE_START =3D 0x6000,	/* pegtune code */
+	NETXEN_BOOTLD_START =3D 0x10000,	/* bootld */
+	NETXEN_IMAGE_START =3D 0x43000,	/* compressed image */
+	NETXEN_SECONDARY_START =3D 0x200000,	/* backup images */
+	NETXEN_PXE_START =3D 0x3E0000,	/* user defined region */
+	NETXEN_USER_START =3D 0x3E8000,	/* User defined region for new boards=
 */
+	NETXEN_FIXED_START =3D 0x3F0000	/* backup of crbinit */
 } netxen_flash_map_t;
=20
-#define USER_START_OLD PXE_START	/* for backward compatibility */
-
-#define FLASH_START		(CRBINIT_START)
-#define INIT_SECTOR		(0)
-#define PRIMARY_START 		(BOOTLD_START)
-#define FLASH_CRBINIT_SIZE 	(0x4000)
-#define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
-#define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
-#define NUM_PRIMARY_SECTORS	(0x20)
-#define NUM_CONFIG_SECTORS 	(1)
+#define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compati=
bility */
+
+#define NETXEN_FLASH_START		(NETXEN_CRBINIT_START)
+#define NETXEN_INIT_SECTOR		(0)
+#define NETXEN_PRIMARY_START 		(NETXEN_BOOTLD_START)
+#define NETXEN_FLASH_CRBINIT_SIZE 	(0x4000)
+#define NETXEN_FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
+#define NETXEN_FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeo=
f(u32))
+#define NETXEN_FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-NETXEN_SECONDA=
RY_START)
+#define NETXEN_NUM_PRIMARY_SECTORS	(0x20)
+#define NETXEN_NUM_CONFIG_SECTORS 	(1)
 #define PFX "NetXen: "
 extern char netxen_nic_driver_name[];
=20
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index 16fabb3..0175f6c 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -94,7 +94,7 @@ static const char netxen_nic_gstrings_test[][ETH_GSTR=
ING_LEN] =3D {
=20
 static int netxen_nic_get_eeprom_len(struct net_device *dev)
 {
-	return FLASH_TOTAL_SIZE;
+	return NETXEN_FLASH_TOTAL_SIZE;
 }
=20
 static void
@@ -470,7 +470,7 @@ netxen_nic_set_eeprom(struct net_device *dev, struc=
t ethtool_eeprom *eeprom,
 		return 0;
 	}
=20
-	if (offset =3D=3D BOOTLD_START) {
+	if (offset =3D=3D NETXEN_BOOTLD_START) {
 		ret =3D netxen_flash_erase_primary(adapter);
 		if (ret !=3D FLASH_SUCCESS) {
 			printk(KERN_ERR "%s: Flash erase failed.\n",=20
@@ -478,10 +478,10 @@ netxen_nic_set_eeprom(struct net_device *dev, str=
uct ethtool_eeprom *eeprom,
 			return ret;
 		}
=20
-		ret =3D netxen_rom_se(adapter, USER_START);
+		ret =3D netxen_rom_se(adapter, NETXEN_USER_START);
 		if (ret !=3D FLASH_SUCCESS)
 			return ret;
-		ret =3D netxen_rom_se(adapter, FIXED_START);
+		ret =3D netxen_rom_se(adapter, NETXEN_FIXED_START);
 		if (ret !=3D FLASH_SUCCESS)
 			return ret;
=20
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/ne=
txen_nic_hw.c
index baff17a..c012764 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -257,7 +257,7 @@ u64 ctx_addr_sig_regs[][3] =3D {
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) <=3D (high)) && ((addr) >=3D (low)))
=20
-#define NETXEN_FLASH_BASE	(BOOTLD_START)
+#define NETXEN_FLASH_BASE	(NETXEN_BOOTLD_START)
 #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
 #define NETXEN_MAX_MTU		8000 + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FC=
S_SIZE
 #define NETXEN_MIN_MTU		64
@@ -611,7 +611,7 @@ int netxen_get_flash_mac_addr(struct netxen_adapter=
 *adapter, u64 mac[])
 	u32 *pmac =3D (u32 *) & mac[0];
=20
 	if (netxen_get_flash_block(adapter,
-				   USER_START +
+				   NETXEN_USER_START +
 				   offsetof(struct netxen_new_user_info,
 					    mac_addr),
 				   FLASH_NUM_PORTS * sizeof(u64), pmac) =3D=3D -1) {
@@ -619,7 +619,7 @@ int netxen_get_flash_mac_addr(struct netxen_adapter=
 *adapter, u64 mac[])
 	}
 	if (*mac =3D=3D ~0ULL) {
 		if (netxen_get_flash_block(adapter,
-					   USER_START_OLD +
+					   NETXEN_USER_START_OLD +
 					   offsetof(struct netxen_user_old_info,
 						    mac_addr),
 					   FLASH_NUM_PORTS * sizeof(u64),
@@ -942,7 +942,7 @@ netxen_nic_pci_set_window(struct netxen_adapter *ad=
apter,
 int
 netxen_nic_erase_pxe(struct netxen_adapter *adapter)
 {
-	if (netxen_rom_fast_write(adapter, PXE_START, 0) =3D=3D -1) {
+	if (netxen_rom_fast_write(adapter, NETXEN_PXE_START, 0) =3D=3D -1) {
 		printk(KERN_ERR "%s: erase pxe failed\n",=20
 			netxen_nic_driver_name);
 		return -1;
@@ -953,7 +953,7 @@ netxen_nic_erase_pxe(struct netxen_adapter *adapter=
)
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
 	int rv =3D 0;
-	int addr =3D BRDCFG_START;
+	int addr =3D NETXEN_BRDCFG_START;
 	struct netxen_board_info *boardinfo;
 	int index;
 	u32 *ptr32;
@@ -1115,7 +1115,7 @@ void netxen_nic_flash_print(struct netxen_adapter=
 *adapter)
 	u32 fw_build =3D 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	struct netxen_new_user_info user_info;
-	int i, addr =3D USER_START;
+	int i, addr =3D NETXEN_USER_START;
 	__le32 *ptr32;
=20
 	struct netxen_board_info *board_info =3D &(adapter->ahw.boardcfg);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/=
netxen_nic_init.c
index a368924..8e7c4a5 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -585,7 +585,7 @@ int netxen_backup_crbinit(struct netxen_adapter *ad=
apter)
 {
 	int ret =3D FLASH_SUCCESS;
 	int val;
-	char *buffer =3D kmalloc(FLASH_SECTOR_SIZE, GFP_KERNEL);
+	char *buffer =3D kmalloc(NETXEN_FLASH_SECTOR_SIZE, GFP_KERNEL);
=20
 	if (!buffer)
 		return -ENOMEM;=09
@@ -601,13 +601,13 @@ int netxen_backup_crbinit(struct netxen_adapter *=
adapter)
 		goto out_kfree;
=20
 	/* copy  sector 0 to sector 63 */
-	ret =3D netxen_rom_fast_read_words(adapter, CRBINIT_START,=20
-						buffer, FLASH_SECTOR_SIZE);
+	ret =3D netxen_rom_fast_read_words(adapter, NETXEN_CRBINIT_START,=20
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret !=3D FLASH_SUCCESS)
 		goto out_kfree;
=20
-	ret =3D netxen_rom_fast_write_words(adapter, FIXED_START,=20
-						buffer, FLASH_SECTOR_SIZE);
+	ret =3D netxen_rom_fast_write_words(adapter, NETXEN_FIXED_START,=20
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret !=3D FLASH_SUCCESS)
 		goto out_kfree;
=20
@@ -654,7 +654,8 @@ void check_erased_flash(struct netxen_adapter *adap=
ter, int addr)
 	int count =3D 0, erased_errors =3D 0;
 	int range;
=20
-	range =3D (addr =3D=3D USER_START) ? FIXED_START : addr + FLASH_SECTO=
R_SIZE;
+	range =3D (addr =3D=3D NETXEN_USER_START) ?=20
+		NETXEN_FIXED_START : addr + NETXEN_FLASH_SECTOR_SIZE;
 =09
 	for (i =3D addr; i < range; i +=3D 4) {
 		netxen_rom_fast_read(adapter, i, &val);
@@ -689,7 +690,7 @@ netxen_flash_erase_sections(struct netxen_adapter *=
adapter, int start, int end)
 	int i;
=20
 	for (i =3D start; i < end; i++) {
-		ret =3D netxen_rom_se(adapter, i * FLASH_SECTOR_SIZE);
+		ret =3D netxen_rom_se(adapter, i * NETXEN_FLASH_SECTOR_SIZE);
 		if (ret)
 			break;
 		ret =3D netxen_rom_wip_poll(adapter);
@@ -706,8 +707,8 @@ netxen_flash_erase_secondary(struct netxen_adapter =
*adapter)
 	int ret =3D FLASH_SUCCESS;
 	int start, end;
=20
-	start =3D SECONDARY_START / FLASH_SECTOR_SIZE;
-	end   =3D USER_START / FLASH_SECTOR_SIZE;
+	start =3D NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   =3D NETXEN_USER_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret =3D netxen_flash_erase_sections(adapter, start, end);
=20
 	return ret;
@@ -719,8 +720,8 @@ netxen_flash_erase_primary(struct netxen_adapter *a=
dapter)
 	int ret =3D FLASH_SUCCESS;
 	int start, end;
=20
-	start =3D PRIMARY_START / FLASH_SECTOR_SIZE;
-	end   =3D SECONDARY_START / FLASH_SECTOR_SIZE;
+	start =3D NETXEN_PRIMARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   =3D NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret =3D netxen_flash_erase_sections(adapter, start, end);
=20
 	return ret;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index c61181f..6167b58 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -542,6 +542,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struc=
t pci_device_id *ent)
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+
+	       /* leave the hw in the same state as reboot */
+	       writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	       netxen_pinit_from_rom(adapter, 0);
+	       udelay(500);
+	       netxen_load_firmware(adapter);
+	       netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
=20
 	/*
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/n=
etxen_nic_niu.c
index cef90a7..75102d3 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -454,16 +454,12 @@ int netxen_niu_gbe_init_port(struct netxen_adapte=
r *adapter, int port)
=20
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 reg;
 	u32 portnum =3D physical_port[adapter->portnum];
=20
 	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_0+(0x10000*portnum), 0x5);
-	netxen_nic_hw_read_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), &reg, 4);
-	reg =3D (reg & ~0x2000UL);
+		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), 0x1447);
 	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), reg);
+		NETXEN_NIU_XGE_CONFIG_0+(0x10000*portnum), 0x5);
=20
 	return 0;
 }
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 22aec5c..b87f8d2 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -54,6 +54,12 @@
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
 #define MII_M1111_PHY_LED_COMBINE	0x411c
+#define MII_M1111_PHY_EXT_CR		0x14
+#define MII_M1111_RX_DELAY		0x80
+#define MII_M1111_TX_DELAY		0x2
+#define MII_M1111_PHY_EXT_SR		0x1b
+#define MII_M1111_HWCFG_MODE_MASK	0xf
+#define MII_M1111_HWCFG_MODE_RGMII	0xb
=20
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -131,6 +137,45 @@ static int marvell_config_aneg(struct phy_device *=
phydev)
 	return err;
 }
=20
+static int m88e1111_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	if ((phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII) ||
+	    (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID)) {
+		int temp;
+
+		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID) {
+			temp =3D phy_read(phydev, MII_M1111_PHY_EXT_CR);
+			if (temp < 0)
+				return temp;
+
+			temp |=3D (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
+
+			err =3D phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+			if (err < 0)
+				return err;
+		}
+
+		temp =3D phy_read(phydev, MII_M1111_PHY_EXT_SR);
+		if (temp < 0)
+			return temp;
+
+		temp &=3D ~(MII_M1111_HWCFG_MODE_MASK);
+		temp |=3D MII_M1111_HWCFG_MODE_RGMII;
+
+		err =3D phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+		if (err < 0)
+			return err;
+	}
+
+	err =3D phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static int m88e1145_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -152,7 +197,7 @@ static int m88e1145_config_init(struct phy_device *=
phydev)
 	if (err < 0)
 		return err;
=20
-	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII) {
+	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID) {
 		int temp =3D phy_read(phydev, MII_M1145_PHY_EXT_CR);
 		if (temp < 0)
 			return temp;
@@ -206,7 +251,7 @@ static struct phy_driver m88e1101_driver =3D {
 	.driver =3D {.owner =3D THIS_MODULE,},
 };
=20
-static struct phy_driver m88e1111s_driver =3D {
+static struct phy_driver m88e1111_driver =3D {
 	.phy_id =3D 0x01410cc0,
 	.phy_id_mask =3D 0xfffffff0,
 	.name =3D "Marvell 88E1111",
@@ -216,6 +261,7 @@ static struct phy_driver m88e1111s_driver =3D {
 	.read_status =3D &genphy_read_status,
 	.ack_interrupt =3D &marvell_ack_interrupt,
 	.config_intr =3D &marvell_config_intr,
+	.config_init =3D &m88e1111_config_init,
 	.driver =3D {.owner =3D THIS_MODULE,},
 };
=20
@@ -241,9 +287,9 @@ static int __init marvell_init(void)
 	if (ret)
 		return ret;
=20
-	ret =3D phy_driver_register(&m88e1111s_driver);
+	ret =3D phy_driver_register(&m88e1111_driver);
 	if (ret)
-		goto err1111s;
+		goto err1111;
=20
 	ret =3D phy_driver_register(&m88e1145_driver);
 	if (ret)
@@ -251,9 +297,9 @@ static int __init marvell_init(void)
=20
 	return 0;
=20
-      err1145:
-	phy_driver_unregister(&m88e1111s_driver);
-      err1111s:
+err1145:
+	phy_driver_unregister(&m88e1111_driver);
+err1111:
 	phy_driver_unregister(&m88e1101_driver);
 	return ret;
 }
@@ -261,7 +307,7 @@ static int __init marvell_init(void)
 static void __exit marvell_exit(void)
 {
 	phy_driver_unregister(&m88e1101_driver);
-	phy_driver_unregister(&m88e1111s_driver);
+	phy_driver_unregister(&m88e1111_driver);
 	phy_driver_unregister(&m88e1145_driver);
 }
=20
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3de564b..8dc09a3 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -313,8 +313,8 @@ config USB_KC2190
 	boolean "KT Technology KC2190 based cables (InstaNet)"
 	depends on USB_NET_CDC_SUBSET && EXPERIMENTAL
 	help
-	 =A0Choose this option if you're using a host-to-host cable
-	 =A0with one of these chips.
+	  Choose this option if you're using a host-to-host cable
+	  with one of these chips.
=20
 config USB_NET_ZAURUS
 	tristate "Sharp Zaurus (stock ROMs) and compatible"
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 25b75b6..b670b97 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1562,7 +1562,7 @@ static void velocity_print_link_status(struct vel=
ocity_info *vptr)
 	if (vptr->mii_status & VELOCITY_LINK_FAIL) {
 		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable=
 link\n", vptr->dev->name);
 	} else if (vptr->options.spd_dpx =3D=3D SPD_DPX_AUTO) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link autonegation", vp=
tr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation"=
, vptr->dev->name);
=20
 		if (vptr->mii_status & VELOCITY_SPEED_1000)
 			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps");
