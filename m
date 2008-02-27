From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 0000:02:00.0: error interrupt status=0x8
Date: Tue, 26 Feb 2008 19:48:18 -0800
Message-ID: <20080226194818.1ee41099@extreme>
References: <47C4CB57.2060004@cygnusx-1.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nathan Grennan <linux-netdev@cygnusx-1.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:49813 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750806AbYB0Dsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 22:48:31 -0500
In-Reply-To: <47C4CB57.2060004@cygnusx-1.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2008 18:30:47 -0800
Nathan Grennan <linux-netdev@cygnusx-1.org> wrote:

>     I am using the sky2 driver in kernel-2.6.23.15-137.fc8.x86_64 with 
> my Marvell 88E8056 to do iSCSI. I have many errors in dmesg like the 
> ones below. If I count just the lines that match the first one, there 
> are over 1500. If I include the suppressed lines it is over 100k. At 
> first I got three of these doing something and then didn't see it for a 
> while. I suspect the 100k came from a download of an 8gb file from the 
> internet that was being written to the remote machine via iSCSI. The 
> download took about an hour and fifteen minutes. I would ignore just 
> three of these, but 100k of them suggests a real problem to me.
> 
> sky2 0000:02:00.0: error interrupt status=0x8
> printk: 77 messages suppressed.

That status comes from the MAC getting an error.
Most likely the receive FIFO is getting overrun. Look at the receive
errors, RX fifo is probably non-zero.

$ ip -s -s li show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:00:5a:9b:0e:76 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    199873594  240394   0       0       0       0      
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       0      
                                        ^


Make sure and use hardware flow control if you are using jumbo frames because
it is real easy to get the ram buffer full, and frames lost.

The message should just be turned into a debug message since the
functions called by sky2_err_intr() all print a more informative message anyway.

--- a/drivers/net/sky2.c	2008-02-26 19:45:26.000000000 -0800
+++ b/drivers/net/sky2.c	2008-02-26 19:45:43.000000000 -0800
@@ -2587,8 +2587,7 @@ static void sky2_watchdog(unsigned long 
 /* Hardware/software error handling */
 static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 {
-	if (net_ratelimit())
-		dev_warn(&hw->pdev->dev, "error interrupt status=%#x\n", status);
+	dev_dbg(&hw->pdev->dev, "error interrupt status=%#x\n", status);
 
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
