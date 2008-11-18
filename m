From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: macb phy address bug?
Date: Tue, 18 Nov 2008 09:50:17 +0100
Message-ID: <492281C9.6060006@st.com>
References: <20081116.015050.238612963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090806010104000104010305"
Cc: giulio.benetti@micronovasrl.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:55527 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbYKRIxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 03:53:42 -0500
In-Reply-To: <20081116.015050.238612963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090806010104000104010305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In my opinion, we need to rework this patch again for two reasons:
1) it doesn't cover the case when the PHYID is 0xffffffff.
2) we need to add an explicit comment on the PHYID check to highlight that
    this is a  work-around the broken hardware (in case we get 0xffff or 
0x0).
I've also tested it on several PHY devices: e.g. smsc lan 8700, ste101p, 
ste100p,
DP83865 National GPHY.
Where, for some of these, we need to treat the phyid=0 as wrong UID.
Please, review the attached patch.

Regards,
Peppe

David Miller wrote:
> I've applied this patch to net-2.6, thanks.
>
> As mentioned there is some rare chance that the new
> zero test could cause problems, in which case we'll
> need to undo that part.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   


--------------090806010104000104010305
Content-Type: text/x-patch;
 name="phy_dev_uid_detection.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="phy_dev_uid_detection.patch"

Fix phy_id detection also for broken hardware.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

--- phy_device.c.orig	2008-11-18 09:25:06.929041000 +0100
+++ phy_device.c	2008-11-18 09:27:15.876041000 +0100
@@ -227,7 +227,16 @@ struct phy_device * get_phy_device(struc
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is all Fs or all 0s, there is no device there */
+	/* If the phy_id is mostly Fs, there is no device there */
+	if ((phy_id & 0x1fffffff) == 0x1fffffff)
+		return NULL;
+
+	/*
+	 * Broken hardware is sometimes missing the pull down resistor on the
+	 * MDIO line, which results in reads to non-existent devices returning
+	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
+	 * device as well.
+	 */ 
 	if ((0xffff == phy_id) || (0x00 == phy_id))
 		return NULL;
 

--------------090806010104000104010305--
