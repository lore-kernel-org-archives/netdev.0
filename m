From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel crash with sky2
Date: Mon, 17 May 2010 12:22:36 -0700
Message-ID: <20100517122236.7f33101f@nehalam>
References: <20100517185228.GG9007@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41395 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab0EQTWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 15:22:39 -0400
In-Reply-To: <20100517185228.GG9007@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 20:52:28 +0200
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Hi Stephen,
> 
> I experience the following crash with 2.6.34 in the sky2 code on my
> laptop when I plug off the lan-cable and then plug-off the power cable
> and switching to battery. It does not happen with acpi=off.

So you have a busted BIOS that powers off the device.

> I havn't tested earlier kernels but I can do that if necessary. I did
> some initial research and found that the driver assumes that port[1] is
> available when the status bits for it are set on the device. Please let
> me know if you need any additional information or want me to test
> anything.

The driver assumes that it won't get garbage in NAPI.

> The crash message is:
> 
> [  107.010134] sky2 0000:02:00.0: PCI hardware error (0xffff)
> [  107.015614] sky2 0000:02:00.0: PCI Express error (0xffffffff)
> [  107.021355] sky2 0000:02:00.0: eth0: ram data read parity error
> [  107.027249] sky2 0000:02:00.0: eth0: ram data write parity error
> [  107.033253] sky2 0000:02:00.0: eth0: MAC parity error
> [  107.038283] sky2 0000:02:00.0: eth0: RX parity error
> [  107.043259] sky2 0000:02:00.0: eth0: TCP segmentation error
> [  107.048823] BUG: unable to handle kernel NULL pointer dereference at 0000000000000438
> [  107.053238] IP: [<ffffffffa0001713>] sky2_hw_error+0x153/0x310 [sky2]
> [  107.053238] PGD 139600067 PUD 139643067 PMD 0 
> [  107.053238] Oops: 0000 [#1] SMP 
> [  107.053238] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
> [  107.053238] CPU 1 
> [  107.053238] Modules linked in: snd_hda_codec_atihdmi snd_hda_codec_idt snd_hda_intel rfcomm snd_pcm_oss snd_hda_2
> [  107.053238] 

Something in power management has turned off your device.
The fact that the sky2 driver has decided to die is unintended casulty.

This will stop the crash, but not fix the problem with PM.
As soon as it sees the device off, it will go offline until you reboot.


--- a/drivers/net/sky2.c	2010-05-17 12:09:22.721738360 -0700
+++ b/drivers/net/sky2.c	2010-05-17 12:19:52.845893670 -0700
@@ -2904,6 +2904,16 @@ static int sky2_poll(struct napi_struct 
 	int work_done = 0;
 	u16 idx;
 
+	if (unlikely(status == ~0)) {
+		int i;
+		dev_err(&hw->pdev->dev,
+			"device no longer available (powered off?)\n");
+
+		for (i = 0; i < hw->ports; i++)
+			netif_device_detach(hw->dev[i]);
+		goto complete;
+	}
+
 	if (unlikely(status & Y2_IS_ERROR))
 		sky2_err_intr(hw, status);
 
@@ -2922,7 +2932,7 @@ static int sky2_poll(struct napi_struct 
 		if (work_done >= work_limit)
 			goto done;
 	}
-
+complete:
 	napi_complete(napi);
 	sky2_read32(hw, B0_Y2_SP_LISR);
 done:

-- 
