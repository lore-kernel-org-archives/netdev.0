From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet
Date: Sun, 4 Dec 2011 16:29:41 +0200
Message-ID: <201112041629.41466.jackm@dev.mellanox.co.il>
References: <4ED8A636.40901@mellanox.co.il> <CAL1RGDV8LzSOei=aQW7VXUP=G+9qdO+Y4eKZu8mBuHJuUp8UuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDV8LzSOei=aQW7VXUP=G+9qdO+Y4eKZu8mBuHJuUp8UuQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 02 December 2011 19:51, Roland Dreier wrote:
> > =A0#else /* CONFIG_PCI_IOV */
> > +static int sr_iov;
> > +#define probe_vf 0
> > =A0int mlx4_log_num_mgm_entry_size =3D 9;
> > =A0#endif /* CONFIG_PCI_IOV */
>=20
> I don't think it's a good idea to put module parameters inside an
> #ifdef. =A0Then depending on the
> kernel config someone compiles with, their modprobe.conf may or may n=
ot break.
>=20
I agree.  I will change this so that the module parameters are always t=
here.

If the kernel is not configured to support IOV, pci_enable_sriov will f=
ail.
Currently, we abort the device startup.  I can change this to simply co=
ntinue
without sriov enabled:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D

mlx4_core: fix sriov module parameters

Always have the sr_iov module parameters (even if the kernel
is not compiled with sriov support).  Change device startup logic
so that if pci_enable_sriov() fails, the PF-driver continues to bring u=
p
the device, but in non-sriov mode.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

---
Roland,
I will roll this change into the original patch set, so that V1 will co=
ntain
this code.


Index: net-next/drivers/net/ethernet/mellanox/mlx4/main.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- net-next.orig/drivers/net/ethernet/mellanox/mlx4/main.c	2011-12-04 =
10:38:52.000000000 +0200
+++ net-next/drivers/net/ethernet/mellanox/mlx4/main.c	2011-12-04 16:23=
:33.000000000 +0200
@@ -76,8 +76,6 @@ MODULE_PARM_DESC(msi_x, "attempt to use=20
=20
 #endif /* CONFIG_PCI_MSI */
=20
-#ifdef CONFIG_PCI_IOV
-
 static int sr_iov;
 module_param(sr_iov, int, 0444);
 MODULE_PARM_DESC(sr_iov, "enable #sr_iov functions if sr_iov > 0");
@@ -94,12 +92,6 @@ MODULE_PARM_DESC(log_num_mgm_entry_size,
 					 " 10 gives 248.range: 9<=3D"
 					 " log_num_mgm_entry_size <=3D 12");
=20
-#else /* CONFIG_PCI_IOV */
-static int sr_iov;
-#define probe_vf 0
-int mlx4_log_num_mgm_entry_size =3D 9;
-#endif /* CONFIG_PCI_IOV */
-
 #define MLX4_VF					(1 << 0)
=20
 #define HCA_GLOBAL_CAP_MASK	0
@@ -1732,13 +1724,19 @@ static int __mlx4_init_one(struct pci_de
=20
 		if (sr_iov) {
 			mlx4_warn(dev, "Enabling sriov with:%d vfs\n", sr_iov);
-			if (pci_enable_sriov(pdev, sr_iov)) {
-				mlx4_err(dev, "Failed to enable sriov, aborting.\n");
-				goto err_rel_own;
+			err =3D pci_enable_sriov(pdev, sr_iov);
+			if (err) {
+				mlx4_err(dev, "Failed to enable sriov,"
+					 "continuing without sriov enabled"
+					 " (err =3D %d).\n", err);
+				sr_iov =3D 0;
+				err =3D 0;
+			} else {
+				mlx4_warn(dev, "Running in master mode\n");
+				dev->flags |=3D MLX4_FLAG_SRIOV |
+					MLX4_FLAG_MASTER;
+				dev->sr_iov =3D sr_iov;
 			}
-			mlx4_warn(dev, "Running in master mode\n");
-			dev->flags |=3D MLX4_FLAG_SRIOV | MLX4_FLAG_MASTER;
-			dev->sr_iov =3D sr_iov;
 		}
=20
 		/*


- Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
