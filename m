From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2.6.35-rc3] drivers/net: ks8842 driver
Date: Mon, 19 Jul 2010 15:26:21 -0700 (PDT)
Message-ID: <20100719.152621.93431422.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D0212A7@MELANITE.micrel.com>
	<20100713.101434.180417674.davem@davemloft.net>
	<20100719151725.fc11b40d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Charles.Li@Micrel.Com, horms@verge.net.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966632Ab0GSW0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:26:05 -0400
In-Reply-To: <20100719151725.fc11b40d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 19 Jul 2010 15:17:25 -0700

> On Tue, 13 Jul 2010 10:14:34 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: David J. Choi <david.choi@micrel.com>
>> Date: Tue, 13 Jul 2010 10:09:19 -0700
>> Subject: [PATCH] drivers/net: Add Micrel KS8841/42 support to ks8842 driver
>> 
>> Body of the explanation:
>>    -support 16bit and 32bit bus width.
>>    -add device reset for ks8842/8841 Micrel device.
>>    -set 100Mbps as a default for Micrel device.
>>    -set MAC address in both MAC/Switch layer with different sequence for Micrel
>>     device, as mentioned in data sheet.
>>    -use private data to set options both 16/32bit bus width and Micrel device/
>>     Timberdale(FPGA).
>>    -update Kconfig in order to put more information about ks8842 device.
> 
> gcc says
> 
> drivers/net/ks8842.c: In function 'ks8842_handle_rx':
> drivers/net/ks8842.c:428: warning: 'status' may be used uninitialized in this function
> 
> and I think I agree with it..

I'll fix this, as below.

David Choi, I'm quite upset, this shows that you did not test the
16-bit code paths (the whole _point_ of this change) at all.  You
didn't even validate the build for new warnings.

--------------------
ks8842: Fix ks8842_tx_frame() for 16bit case.

As reported by Andrew:

drivers/net/ks8842.c: In function 'ks8842_handle_rx':
drivers/net/ks8842.c:428: warning: 'status' may be used uninitialized in this function

Just use the 32-bit status for all reads, and delete the useless
cast to 'int' when reading a u16 into 'len'.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ks8842.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index ee69dea..634dad1 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -424,16 +424,14 @@ static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *netdev)
 static void ks8842_rx_frame(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
-	u16 status16;
 	u32 status;
 	int len;
 
 	if (adapter->conf_flags & KS884X_16BIT) {
-		status16 = ks8842_read16(adapter, 17, REG_QMU_DATA_LO);
-		len  = (int)ks8842_read16(adapter, 17, REG_QMU_DATA_HI);
-		len &= 0xffff;
+		status = ks8842_read16(adapter, 17, REG_QMU_DATA_LO);
+		len = ks8842_read16(adapter, 17, REG_QMU_DATA_HI);
 		netdev_dbg(netdev, "%s - rx_data: status: %x\n",
-			   __func__, status16);
+			   __func__, status);
 	} else {
 		status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
 		len = (status >> 16) & 0x7ff;
-- 
1.7.1.1

