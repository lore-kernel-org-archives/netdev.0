From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH 2.6.9-rc3-mm1] 3c59x: Make use of generic_mii_ioctl
Date: Mon, 4 Oct 2004 13:52:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004115201.GA1635@bayes.mathematik.tu-chemnitz.de>
References: <20041003204507.GA29546@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041003204507.GA29546@bayes.mathematik.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 03, 2004 at 10:45:07PM +0200 or thereabouts, Steffen Klassert wrote:
> With this patch the driver makes use of the MII lib helper 
> function generic_mii_ioctl.
> Patch is tested with the mii-diag tool and a 3c905-TX, 3c905B-TX NIC.
> 
> Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

The first patch has a codeline which ends with two semicolon, sorry.
Please use this patch instead.


--- vanilla-2.6.9-rc3-mm1/drivers/net/3c59x.c	Sat Oct  2 14:54:46 2004
+++ linux-2.6.9-rc3-mm1/drivers/net/3c59x.c	Mon Oct  4 10:59:19 2004
@@ -834,6 +834,7 @@
 	u16 io_size;						/* Size of PCI region (for release_region) */
 	spinlock_t lock;					/* Serialise access to device & its vortex_private */
 	spinlock_t mdio_lock;				/* Serialise access to mdio hardware */
+	struct mii_if_info mii;				/* MII lib hooks/info */
 };
 
 #ifdef CONFIG_PCI
@@ -1218,6 +1219,11 @@
 	spin_lock_init(&vp->lock);
 	spin_lock_init(&vp->mdio_lock);
 	vp->gendev = gendev;
+	vp->mii.dev = dev;
+	vp->mii.mdio_read = mdio_read;
+	vp->mii.mdio_write = mdio_write;
+	vp->mii.phy_id_mask = 0x1f;
+	vp->mii.reg_num_mask = 0x1f;
 
 	/* Makes sure rings are at least 16 byte aligned. */
 	vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct boom_rx_desc) * RX_RING_SIZE
@@ -1445,6 +1451,7 @@
 				mdio_write(dev, vp->phys[0], 4, vp->advertising);
 			}
 		}
+		vp->mii.phy_id = vp->phys[0];
 	}
 
 	if (vp->capabilities & CapBusMaster) {
@@ -2891,41 +2898,6 @@
 };
 
 #ifdef CONFIG_PCI
-static int vortex_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-{
-	struct vortex_private *vp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
-	struct mii_ioctl_data *data = if_mii(rq);
-	int phy = vp->phys[0] & 0x1f;
-	int retval;
-
-	switch(cmd) {
-	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
-		data->phy_id = phy;
-
-	case SIOCGMIIREG:		/* Read MII PHY register. */
-		EL3WINDOW(4);
-		data->val_out = mdio_read(dev, data->phy_id & 0x1f, data->reg_num & 0x1f);
-		retval = 0;
-		break;
-
-	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN)) {
-			retval = -EPERM;
-		} else {
-			EL3WINDOW(4);
-			mdio_write(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
-			retval = 0;
-		}
-		break;
-	default:
-		retval = -EOPNOTSUPP;
-		break;
-	}
-
-	return retval;
-}
-
 /*
  *	Must power the device up to do MDIO operations
  */
@@ -2933,8 +2905,9 @@
 {
 	int err;
 	struct vortex_private *vp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
 	int state = 0;
-
+	
 	if(VORTEX_PCI(vp))
 		state = VORTEX_PCI(vp)->current_state;
 
@@ -2942,7 +2915,8 @@
 
 	if(state != 0)
 		pci_set_power_state(VORTEX_PCI(vp), 0);
-	err = vortex_do_ioctl(dev, rq, cmd);
+	EL3WINDOW(4);
+	err = generic_mii_ioctl(&vp->mii, if_mii(rq), cmd, NULL);
 	if(state != 0)
 		pci_set_power_state(VORTEX_PCI(vp), state);
 
