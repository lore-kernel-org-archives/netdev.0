From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH]e100 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 15:40:39 +0800
Message-ID: <000001d01c28$41c937c0$c55ba740$@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0001_01D01C6B.4FF180D0"
Cc: <netdev@vger.kernel.org>, <Linux-nics@isotope.jf.intel.com>,
	<linux.nics@intel.com>, <e1000-devel@lists.sourceforge.net>
To: <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:55369 "EHLO m50-134.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaLTHlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 02:41:18 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multipart message in MIME format.

------=_NextPart_000_0001_01D01C6B.4FF180D0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have actually tested e100 driver on the real hardware(Intel 82559 PCI
Ethernet Controller), and find some bugs:
The target file is drivers/net/ethernet/intel/e100.c, which is used to build
e100.ko.

(1) The function pci_pool_create is called by e100_probe when initializing
the ethernet card driver. But when pci_pool_create is failed, which means
that it returns NULL to nic->cbs_pool, the system crash will happen. Because
pci_pool_alloc (in e100_alloc_cbs in e100_up in e100_open) need to use
nic->cbs_pool to allocate the resource, but it is NULL. I suggest that a
check can be added in the code to detect whether pci_pool_create returns
NULL.
(2) In the normal process, netif_napi_add is called in e100_probe, but
netif_napi_del is not called in e100_remove. However, many other ethernet
card drivers call them in pairs, even in the error handling paths, such as
r8169 and igb.

Meanwhile, I also write the patch to fix the bugs. I have run the patch on
the hardware, it can work normally and fix the above bugs.

diff --git a/drivers/net/ethernet/intel/e100.c
b/drivers/net/ethernet/intel/e100.c
index 781065e..2631d3f 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev, const
struct pci_device_id *ent)
 			   nic->params.cbs.max * sizeof(struct cb),
 			   sizeof(u32),
 			   0);
+	if(!(nic->cbs_pool))
+	{
+		err = -ENOMEM;
+		goto err_out_pool;
+	}
 	netif_info(nic, probe, nic->netdev,
 		   "addr 0x%llx, irq %d, MAC addr %pM\n",
 		   (unsigned long long)pci_resource_start(pdev, use_io ? 1 :
0),
@@ -2976,6 +2981,8 @@ static int e100_probe(struct pci_dev *pdev, const
struct pci_device_id *ent)
 
 	return 0;
 
+err_out_pool:
+	unregister_netdev(netdev);
 err_out_free:
 	e100_free(nic);
 err_out_iounmap:
@@ -2985,6 +2992,7 @@ err_out_free_res:
 err_out_disable_pdev:
 	pci_disable_device(pdev);
 err_out_free_dev:
+	netif_napi_del(&nic->napi);
 	free_netdev(netdev);
 	return err;
 }
@@ -2995,6 +3003,7 @@ static void e100_remove(struct pci_dev *pdev)
 
 	if (netdev) {
 		struct nic *nic = netdev_priv(netdev);
+		netif_napi_del(&nic->napi);
 		unregister_netdev(netdev);
 		e100_free(nic);
 		pci_iounmap(pdev, nic->csr);

------=_NextPart_000_0001_01D01C6B.4FF180D0
Content-Type: application/octet-stream;
	name="patch_e100"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="patch_e100"

diff --git a/drivers/net/ethernet/intel/e100.c =
b/drivers/net/ethernet/intel/e100.c=0A=
index 781065e..2631d3f 100644=0A=
--- a/drivers/net/ethernet/intel/e100.c=0A=
+++ b/drivers/net/ethernet/intel/e100.c=0A=
@@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev, const =
struct pci_device_id *ent)=0A=
 			   nic->params.cbs.max * sizeof(struct cb),=0A=
 			   sizeof(u32),=0A=
 			   0);=0A=
+	if(!(nic->cbs_pool))=0A=
+	{=0A=
+		err =3D -ENOMEM;=0A=
+		goto err_out_pool;=0A=
+	}=0A=
 	netif_info(nic, probe, nic->netdev,=0A=
 		   "addr 0x%llx, irq %d, MAC addr %pM\n",=0A=
 		   (unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),=0A=
@@ -2976,6 +2981,8 @@ static int e100_probe(struct pci_dev *pdev, const =
struct pci_device_id *ent)=0A=
 =0A=
 	return 0;=0A=
 =0A=
+err_out_pool:=0A=
+	unregister_netdev(netdev);=0A=
 err_out_free:=0A=
 	e100_free(nic);=0A=
 err_out_iounmap:=0A=
@@ -2985,6 +2992,7 @@ err_out_free_res:=0A=
 err_out_disable_pdev:=0A=
 	pci_disable_device(pdev);=0A=
 err_out_free_dev:=0A=
+	netif_napi_del(&nic->napi);=0A=
 	free_netdev(netdev);=0A=
 	return err;=0A=
 }=0A=
@@ -2995,6 +3003,7 @@ static void e100_remove(struct pci_dev *pdev)=0A=
 =0A=
 	if (netdev) {=0A=
 		struct nic *nic =3D netdev_priv(netdev);=0A=
+		netif_napi_del(&nic->napi);=0A=
 		unregister_netdev(netdev);=0A=
 		e100_free(nic);=0A=
 		pci_iounmap(pdev, nic->csr);=0A=

------=_NextPart_000_0001_01D01C6B.4FF180D0--
