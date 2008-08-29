From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: avoid duplicated output of device name in kernel
	warning
Date: Thu, 28 Aug 2008 17:01:00 -0700
Message-ID: <20080829000100.5149.26290.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Frans Pop <elendil@planet.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:35438 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbYH2ABC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 20:01:02 -0400
Received: by rv-out-0506.google.com with SMTP id k40so618966rvb.1
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 17:01:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>

With 2.6.27-rc3 I noticed the following messages in my boot log:

0000:01:00.0: 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:04:ff:09

The second seems correct, but the first has a silly repetition of the
PCI device before the actual message. The message originates from
e1000_eeprom_checks in e1000e/netdev.c.

With this patch below the first message becomes

  e1000e 0000:01:00.0: Warning: detected DSPD enabled in EEPROM

which makes it similar to directly preceding messages.

Use dev_warn instead of e_warn in e1000_eeprom_checks() as the interface
name has not yet been assigned at that point.

Signed-off-by: Frans Pop <elendil@planet.nl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..4563f34 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4335,13 +4335,15 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
 	if (!(le16_to_cpu(buf) & (1 << 0))) {
 		/* Deep Smart Power Down (DSPD) */
-		e_warn("Warning: detected DSPD enabled in EEPROM\n");
+		dev_warn(&adapter->pdev-dev,
+		         "Warning: detected DSPD enabled in EEPROM\n");
 	}
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
 	if (le16_to_cpu(buf) & (3 << 2)) {
 		/* ASPM enable */
-		e_warn("Warning: detected ASPM enabled in EEPROM\n");
+		dev_warn(&adapter->pdev->dev,
+		         "Warning: detected ASPM enabled in EEPROM\n");
 	}
 }
 

