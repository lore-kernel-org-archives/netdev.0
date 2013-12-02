From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [net v2 2/7] e1000: prevent oops when adapter is being closed
 and reset simultaneously
Date: Mon, 2 Dec 2013 17:50:06 +0800
Message-ID: <529C57CE.1040801@windriver.com>
References: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com> <1385803221-3752-3-git-send-email-jeffrey.t.kirsher@intel.com> <529A145C.4030503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------040704000609090002060304"
Cc: <netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38961 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab3LBJuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 04:50:13 -0500
In-Reply-To: <529A145C.4030503@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------040704000609090002060304
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 12/01/2013 12:37 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 30-11-2013 13:20, Jeff Kirsher wrote:
>
>> From: yzhu1 <yanjun.zhu@windriver.com>
>
>> This change is based on a similar change made to e1000e support in
>> commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is being closed
>> and reset simultaneously").  The same issue has also been observed
>> on the older e1000 cards.
>
>> Here, we have increased the RESET_COUNT value to 50 because there are 
>> too
>> many accesses to e1000 nic on stress tests to e1000 nic, it is not 
>> enough
>> to set RESET_COUT 25. Experimentation has shown that it is enough to set
>> RESET_COUNT 50.
>
>> Signed-off-by: yzhu1 <yanjun.zhu@windriver.com>
>
>    Jeff, why are you accepting patches without real name in the 
> sign-off line?
>
>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> WBR, Sergei
>
>
Hi,

Thanks for the advice from Sergei. I made a new patch with the name 
"yanjun.zhu".

Best Regards!
Zhu Yanjun

--------------040704000609090002060304
Content-Type: text/x-patch;
	name="0001-e1000-prevent-oops-when-adapter-is-being-closed-and-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-e1000-prevent-oops-when-adapter-is-being-closed-and-.pa";
	filename*1="tch"

>From 54e9e48a9f878eb45f0cc6322415244d7a9f1598 Mon Sep 17 00:00:00 2001
From: yzhu1 <yanjun.zhu@windriver.com>
Date: Fri, 22 Nov 2013 15:46:48 +0800
Subject: [PATCH 1/1] e1000: prevent oops when adapter is being closed and
 reset simultaneously

This change is based on a similar change made to e1000e support in
commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is being closed
and reset simultaneously").  The same issue has also been observed
on the older e1000 cards.

Here, we have increased the RESET_COUNT value to 50 because there are too
many accesses to e1000 nic on stress tests to e1000 nic, it is not enough
to set RESET_COUT 25. Experimentation has shown that it is enough to set
RESET_COUNT 50.

Signed-off-by: yanjun.zhu <yanjun.zhu@windriver.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |    5 +++++
 drivers/net/ethernet/intel/e1000/e1000_main.c |    9 +++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 58c1472..0af4a8e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -83,6 +83,11 @@ struct e1000_adapter;
 
 #define E1000_MAX_INTR			10
 
+/*
+ * Count for polling __E1000_RESET condition every 10-20msec.
+ */
+#define E1000_CHECK_RESET_COUNT         50
+
 /* TX/RX descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			256
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e386228..c0f5217 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1440,6 +1440,10 @@ static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int count = E1000_CHECK_RESET_COUNT;
+
+	while (test_bit(__E1000_RESETTING, &adapter->flags) && count--)
+		usleep_range(10000, 20000);
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
@@ -4963,6 +4967,11 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
+		int count = E1000_CHECK_RESET_COUNT;
+
+		while (test_bit(__E1000_RESETTING, &adapter->flags) && count--)
+			usleep_range(10000, 20000);
+
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
 	}
-- 
1.7.9.5


--------------040704000609090002060304--
