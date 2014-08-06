From: Stefano Babic <sbabic@denx.de>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 06 Aug 2014 17:32:41 +0200
Message-ID: <53E24A99.2020604@denx.de>
References: <53E24147.4050304@parkeon.com> <53E24525.2020809@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, festevam@gmail.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Nathan Lynch <Nathan_Lynch@mentor.com>,
	Martin Fuzzey <mfuzzey@parkeon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38219 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaHFPco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:32:44 -0400
In-Reply-To: <53E24525.2020809@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nathan, Martin,

On 06/08/2014 17:09, Nathan Lynch wrote:
> On 08/06/2014 09:52 AM, Martin Fuzzey wrote:
>> Hi all,
>>
>> I am using the fec ethernet driver on a i.MX53 SoC.
>>
>> All was working fine on 3.13 but, after upgrading to 3.16 I now get a
>> panic on suspend:
> 
> Same issue reported here:
> 
> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-August/277728.html
> 
> a71e3c37960c (net: phy: Set the driver when registering an MDIO bus
> device) has been implicated; try reverting that.
> 

I confirm this issue (on a i.MX35). The ndev pointer is NULL in the
suspend function. I added the check for the pointer:

>From 82af51e87b78000c0e038db6056c34f72a1f4045 Mon Sep 17 00:00:00 2001
From: Stefano Babic <sbabic@denx.de>
Date: Wed, 6 Aug 2014 16:37:58 +0200
Subject: [PATCH] net: fec: check for pointer in suspend/resume

Check to get a valid structure to driver data
in suspend/resume functions before accessing.

Signed-off-by: Stefano Babic <sbabic@denx.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 77037fd..0f5f52f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2659,7 +2659,12 @@ static int
 fec_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
-	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_enet_private *fep;
+
+	if (!ndev)
+		return 0;
+
+	fep = netdev_priv(ndev);

 	if (netif_running(ndev)) {
 		fec_stop(ndev);
@@ -2678,9 +2683,13 @@ static int
 fec_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
-	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_enet_private *fep;
 	int ret;

+	if (!ndev)
+		return 0;
+
+	fep = netdev_priv(ndev);
 	if (fep->reg_phy) {
 		ret = regulator_enable(fep->reg_phy);
 		if (ret)
-- 
1.9.1

Even if checking the pointer is correct (I can send a formal patch if
there is an agreement), I do not understand why suspend is called twice:
the first time with NULL pointer, the second time with the correct pointer.

Best regards,
Stefano Babic


-- 
=====================================================================
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-53 Fax: +49-8142-66989-80 Email: sbabic@denx.de
=====================================================================
