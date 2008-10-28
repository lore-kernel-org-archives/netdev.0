From: Yu Zhao <yu.zhao@intel.com>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Tue, 28 Oct 2008 14:44:11 +0800
Message-ID: <20081028064411.GA7043@yzhao12-linux.sh.intel.com>
References: <48920413.6080508@cosmosbay.com> <4906405F.6080708@cosmosbay.com> <1225164385.3977.11.camel@localhost> <4906AF5F.9040704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "willy@linux.intel.com" <willy@linux.intel.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <dada1@cosmosbay.com>, benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60325 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568AbYJ1HjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 03:39:14 -0400
Content-Disposition: inline
In-Reply-To: <4906AF5F.9040704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 02:21:19PM +0800, Eric Dumazet wrote:
> Benjamin Li a =E9crit :
> > Hi Eric,
> >=20
> > It looks like the same problem again: we are reading past a valid V=
PD
> > address.
> >=20
> > After some initial debugging, it looks like dev->vpd is NULL when t=
he
> > Broadcom 5706C/5706S/5708C/570S/5709 quirk is called.  Because of t=
his
> > dev->vpd->len is never set to the proper length to limit the VPD re=
ads.
> > I will debug further to determine what has changed.
> >=20
> > Thanks again for pointing out the problem.
> >=20
>=20
> I did a git bisect this morning :
>=20
> $ git bisect good
> 201de56eb22f1ff3f36804bc70cbff220b50f067 is first bad commit
> commit 201de56eb22f1ff3f36804bc70cbff220b50f067
> Author: Zhao, Yu <yu.zhao@intel.com>
> Date:   Mon Oct 13 19:49:55 2008 +0800
>=20
>     PCI: centralize the capabilities code in probe.c
>=20
>     This patch centralizes the initialization and release functions o=
f
>     various PCI capabilities in probe.c, which makes the introduction
>     of new capability support functions cleaner in the future.
>=20
>     Signed-off-by: Yu Zhao <yu.zhao@intel.com>
>     Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>
>=20

Yes, the VPD initialization code has been moved to a later stage that i=
s
after the pci_fixup_header. Can you please try following fix?

Thanks,
Yu

VPD quirks needs to be called after the capability is initialized. Sinc=
e
VPD initialization is move to after pci_fixup_header, VPD quirks should
be done at pci_fixup_final stage correspondingly.

Signed-off-by: Yu Zhao <yu.zhao@intel.com>

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index bbf66ea..5049a47 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1692,24 +1692,24 @@ static void __devinit quirk_brcm_570x_limit_vpd=
(struct pci_dev *dev)
 	}
 }
=20
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5706,
-			 quirk_brcm_570x_limit_vpd);
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5706S,
-			 quirk_brcm_570x_limit_vpd);
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5708,
-			 quirk_brcm_570x_limit_vpd);
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5708S,
-			 quirk_brcm_570x_limit_vpd);
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5709,
-			 quirk_brcm_570x_limit_vpd);
-DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_BROADCOM,
-			 PCI_DEVICE_ID_NX2_5709S,
-			 quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5706,
+			quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5706S,
+			quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5708,
+			quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5708S,
+			quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5709,
+			quirk_brcm_570x_limit_vpd);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
+			PCI_DEVICE_ID_NX2_5709S,
+			quirk_brcm_570x_limit_vpd);
=20
 #ifdef CONFIG_PCI_MSI
 /* Some chipsets do not support MSI. We cannot easily rely on setting
