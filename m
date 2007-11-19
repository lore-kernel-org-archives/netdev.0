From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth boot delay fix
Date: Mon, 19 Nov 2007 13:13:12 -0500
Message-ID: <4741D238.4050005@nvidia.com>
References: <47408EE5.2040302@nvidia.com> <20071120010858.4d098194.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050908080007060706070101"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:1953 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276AbXKTTGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 14:06:36 -0500
In-Reply-To: <20071120010858.4d098194.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050908080007060706070101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Missed that "break". Here is the corrected patch.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



Andrew Morton wrote:
> On Sun, 18 Nov 2007 14:13:41 -0500 Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
> 
>>This patch fixes a long boot delay in the forcedeth driver. During 
>>initialization, the timeout for the handshake between mgmt unit and 
>>driver can be very long. The patch reduces the timeout by eliminating a 
>>extra loop around the timeout logic.
>>
>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
>>
>>
>>
>>[patch-forcedeth-sema-fix  text/plain (1.3KB)]
>>--- old/drivers/net/forcedeth.c	2007-11-08 17:33:00.000000000 -0500
>>+++ new/drivers/net/forcedeth.c	2007-11-08 17:34:25.000000000 -0500
>>@@ -5286,20 +5286,17 @@
>> 		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
>> 			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
>> 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
>>-			for (i = 0; i < 5000; i++) {
>>-				msleep(1);
>>-				if (nv_mgmt_acquire_sema(dev)) {
>>-					/* management unit setup the phy already? */
>>-					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
>>-					    NVREG_XMITCTL_SYNC_PHY_INIT) {
>>-						/* phy is inited by mgmt unit */
>>-						phyinitialized = 1;
>>-						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
>>-					} else {
>>-						/* we need to init the phy */
>>-					}
>>-					break;
>>+			if (nv_mgmt_acquire_sema(dev)) {
>>+				/* management unit setup the phy already? */
>>+				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
>>+				    NVREG_XMITCTL_SYNC_PHY_INIT) {
>>+					/* phy is inited by mgmt unit */
>>+					phyinitialized = 1;
>>+					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
>>+				} else {
>>+					/* we need to init the phy */
>> 				}
>>+				break;
>> 			}
>> 		}
>> 	}
> 
> 
> drivers/net/forcedeth.c: In function 'nv_probe':
> drivers/net/forcedeth.c:5307: error: break statement not within loop or switch  

--------------050908080007060706070101
Content-Type: text/plain;
 name="patch-forcedeth-sema-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-sema-fix"

--- old/drivers/net/forcedeth.c	2007-11-08 17:33:00.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-11-19 13:09:03.000000000 -0500
@@ -5286,19 +5286,15 @@
 		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
 			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
-			for (i = 0; i < 5000; i++) {
-				msleep(1);
-				if (nv_mgmt_acquire_sema(dev)) {
-					/* management unit setup the phy already? */
-					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
-					    NVREG_XMITCTL_SYNC_PHY_INIT) {
-						/* phy is inited by mgmt unit */
-						phyinitialized = 1;
-						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
-					} else {
-						/* we need to init the phy */
-					}
-					break;
+			if (nv_mgmt_acquire_sema(dev)) {
+				/* management unit setup the phy already? */
+				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
+				    NVREG_XMITCTL_SYNC_PHY_INIT) {
+					/* phy is inited by mgmt unit */
+					phyinitialized = 1;
+					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
+				} else {
+					/* we need to init the phy */
 				}
 			}
 		}

--------------050908080007060706070101--
