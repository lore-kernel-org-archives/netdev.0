From: Andre Tomt <andre@tomt.net>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 14:59:21 +0200
Message-ID: <5072CE29.5010504@tomt.net>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>  <1349677373.21172.2756.camel@edumazet-glaptop>  <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>  <1349689640.21172.3008.camel@edumazet-glaptop>  <80bb011e8f1289218087633fd7b115ea@justnet.pl>  <5072C063.6000302@tomt.net> <1349698406.21172.3168.camel@edumazet-glaptop> <5072C7F4.1090002@tomt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060603080206030909030501"
Cc: adam.niescierowicz@justnet.pl, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from catastrophix.ugh.no ([178.79.162.34]:36784 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab2JHM70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:59:26 -0400
In-Reply-To: <5072C7F4.1090002@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060603080206030909030501
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 08. okt. 2012 14:32, Andre Tomt wrote:
> On 08. okt. 2012 14:13, Eric Dumazet wrote:
>> On Mon, 2012-10-08 at 14:00 +0200, Andre Tomt wrote:
>>> On 08. okt. 2012 12:49, Nieścierowicz Adam wrote:
>>>> W dniu 08.10.2012 11:47, Eric Dumazet napisał(a):
>>>>> Anyway you dont say where are drops, (ifconfig give us very few drops)
>>>>
>>>> you can see no losses(drop), but a temporary decline in traffic on the
>>>> interface to 0kb/s
>>>
>>> This sounds very familiar, could it be something similar to:
>>> http://marc.info/?l=linux-netdev&m=134594936016796&w=3
>>>
>>> The chip seems to be of the same family (though not model)
>>
>> Yes, but Adam says 3.4.1 already has a problem, while
>> commit 2cb7a9cc008c25dc03314de563c00c107b3e5432 is in 3.5 only.
>  >
>> Since Adam uses Intel e1000e, it could be the BQL related problem.
>
> The other chips have had DMA burst flag enabled for longer, so that he
> sees the same problem in 3.4 while I'm not makes sense. Hmm, as 3.4 is
> when BQL went in (IIRC) it seems very likely that this BQL issue is the
> problem for both of us.

To clarify; I think the DMA burst flag in the driver triggers the BQL 
related issue. Judging by the patchwork link for wthresh=1 this seems 
very related indeed.

Removing the FLAG2_DMA_BURST flag for 82574 in the driver works for me. 
Adam, it might be worth testing out a build on your system too with the 
flag removed. If you try the attached patch (for 3.6, probably OK for 
3.5) and the problem dissapears, we are probably at least talking about 
the same bug.

--------------060603080206030909030501
Content-Type: text/x-patch;
 name="e1000e-disable-dma-burst.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="e1000e-disable-dma-burst.patch"

diff -Naur linux-3.6.1/drivers/net/ethernet/intel/e1000e/82571.c linux-3.6.1-2/drivers/net/ethernet/intel/e1000e/82571.c
--- linux-3.6.1/drivers/net/ethernet/intel/e1000e/82571.c	2012-10-07 17:41:28.000000000 +0200
+++ linux-3.6.1-2/drivers/net/ethernet/intel/e1000e/82571.c	2012-10-08 14:54:08.853095363 +0200
@@ -2031,8 +2031,7 @@
 				  | FLAG_RESET_OVERWRITES_LAA /* errata */
 				  | FLAG_TARC_SPEED_MODE_BIT /* errata */
 				  | FLAG_APME_CHECK_PORT_B,
-	.flags2			= FLAG2_DISABLE_ASPM_L1 /* errata 13 */
-				  | FLAG2_DMA_BURST,
+	.flags2			= FLAG2_DISABLE_ASPM_L1, /* errata 13 */
 	.pba			= 38,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -2049,8 +2048,7 @@
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
-	.flags2			= FLAG2_DISABLE_ASPM_L1 /* errata 13 */
-				  | FLAG2_DMA_BURST,
+	.flags2			= FLAG2_DISABLE_ASPM_L1, /* errata 13 */
 	.pba			= 38,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -2090,8 +2088,7 @@
 	.flags2			 = FLAG2_CHECK_PHY_HANG
 				  | FLAG2_DISABLE_ASPM_L0S
 				  | FLAG2_DISABLE_ASPM_L1
-				  | FLAG2_NO_DISABLE_RX
-				  | FLAG2_DMA_BURST,
+				  | FLAG2_NO_DISABLE_RX,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,

--------------060603080206030909030501--
