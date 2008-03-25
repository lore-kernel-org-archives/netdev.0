From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Tue, 25 Mar 2008 10:17:50 +0100
Message-ID: <1206436671.7589.208.camel@gentoo-jocke.transmode.se>
References: <>
	 <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001D19565@zch01exm26.fsl.freescale.net>
	 <46CAC1281D7CB94A9AEFFB131F9569CA227627@tmnt04.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:53101 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751988AbYCYJRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 05:17:54 -0400
In-Reply-To: <46CAC1281D7CB94A9AEFFB131F9569CA227627@tmnt04.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-03-22 at 12:51 +0100, Joakim Tjernlund wrote:
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org
> >> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Joakim Tjernlund
> > Sent: Tuesday, March 18, 2008 11:11 PM
> >> To: Netdev; Li Yang
> >> Cc: Joakim Tjernlund
> >>Subject: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
> >>
> >> Creating a VLAN interface on top of ucc_geth adds 4 bytes to
> >> the frame and the HW controller is not prepared to TX a frame
> >> bigger than 1518 bytes which is 4 bytes too small for a full
> >> VLAN frame. Also add 4 extra bytes for future expansion.
> > 
> > IMO, VLAN and Jumbo packet support is not general case of Ethernet.
> > Could you make this change optional?  Thanks.
> > 
> > - Leo
> 
> hmm, I do not agree. VLAN is common today.
> 
> If you were to enable HW support for VLAN then the ethernet controller
> would inject an extra 4 bytes into the frame. 
> This change does not change the visible MTU for the user. As is now,
> soft VLAN is silently broken. Do you
> really want the user to find and turn on a controller specific feature
> to use VLAN?
> 
> What does netdev people think? 
> 
>  Jocke 

hmm, I misread the HW specs. The change has nothing to do with TX, it is
the MAX RX frame size that was too small for VLAN and that is what the
patch addresses. I see that tg3.c adds 4 bytes to MAX RX pkgs:
 	/* MTU + ethernet header + FCS + optional VLAN tag */
	tw32(MAC_RX_MTU_SIZE, tp->dev->mtu + ETH_HLEN + 8);
So I don't think this change should be hidden behind a new CONFIG
option. Updated patch below with changed description.

 Jocke

>From ec8ca3c9666bdc72652e403ea5f252b38e5a076b Mon Sep 17 00:00:00 2001
From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Tue, 18 Mar 2008 15:40:59 +0100
Subject: [PATCH] ucc_geth: Add 8 bytes to max RX frame for VLANs

Creating a VLAN interface on top of ucc_geth adds 4 bytes
to the frame and the HW controller is not prepared to
receive a frame bigger than 1518 bytes which is 4 bytes too
small for a full VLAN frame. Also add 4 extra bytes for future
expansion.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 348892b..038ec75 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -114,10 +114,10 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.maxGroupAddrInHash = 4,
 	.maxIndAddrInHash = 4,
 	.prel = 7,
-	.maxFrameLength = 1518,
+	.maxFrameLength = 1518+8, /* Add 4 bytes for VLAN tags and 4 extra bytes */
 	.minFrameLength = 64,
-	.maxD1Length = 1520,
-	.maxD2Length = 1520,
+	.maxD1Length = 1520+8,
+	.maxD2Length = 1520+8,
 	.vlantype = 0x8100,
 	.ecamptr = ((uint32_t) NULL),
 	.eventRegMask = UCCE_OTHER,
-- 
1.5.4.3


