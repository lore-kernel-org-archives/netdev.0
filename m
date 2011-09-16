From: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Subject: [PATCH] ixgbe: get pauseparam autoneg
Date: Fri, 16 Sep 2011 09:20:21 +0300
Message-ID: <op.v1v077z76ywr33@esapekka-pc.rad1>
References: <op.v1ozj4zk6ywr33@esapekka-pc.rad1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "mika.lansirinne@stonesoft.com" <mika.lansirinne@stonesoft.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-1a.stonesoft.com ([192.89.38.178]:55417 "EHLO
	hki-smtp-1a.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab1IPGlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 02:41:12 -0400
Received: from hki-smtp-1a.stonesoft.com (localhost.localdomain [127.0.0.1])
	by localhost.stonesoft.com (Postfix) with ESMTP id 4DFFF34813E
	for <netdev@vger.kernel.org>; Fri, 16 Sep 2011 09:20:21 +0300 (EEST)
Received: from outlook.stonesoft.com (unknown [172.16.40.22])
	by hki-smtp-1a.stonesoft.com (Postfix) with ESMTP id 3D683348130
	for <netdev@vger.kernel.org>; Fri, 16 Sep 2011 09:20:21 +0300 (EEST)
In-Reply-To: <op.v1ozj4zk6ywr33@esapekka-pc.rad1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a problem in the ixgbe driver with the reporting of the flow
control parameters. The autoneg parameter is shown to be of if
*either* it really is off, or current modes for both tx and rx are off.

The problem is seen when the parameters are read or set when the link
is down. In this case, the driver sees that tx and rx are currently off
and therefore autoneg parameter is incorrectly reported to be off too.
Also, the ethtool binary can not set the autoneg off since it sees that
it already is. When a link later comes up, the autonegotiation is
carried out normally and the driver later on reports the autoneg
parameter to be on (as it is) and then it can also be changed with
ethtool.

The patch is made against v3.0 kernel, but the problem seems to be there
since v2.6.30-rc1.

Reviewer comments: What we are trying to do is to disable flow control
while the cable is disconnected. Since ixgbe defaults to full flow
control, we call ethtool -A autoneg off rx off tx off while the cable
is disconnected. This doesn't work, because the driver sets
hw->fc.current_mode = ixgbe_fc_none if the cable is unplugged.
ixgbe_get_pauseparam() then reports to ethtool that nothing needs to be
done. The code fixes this, but it might have some unknown consequences.

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
Reviewed-by: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Cc: Tantilov, Emil S <emil.s.tantilov@intel.com>
---
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c  
b/drivers/net/ixgbe/ixgbe_ethtool.c
index 82d4244..db27c24 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -368,13 +368,7 @@ static void ixgbe_get_pauseparam(struct net_device  
*netdev,
         struct ixgbe_adapter *adapter = netdev_priv(netdev);
         struct ixgbe_hw *hw = &adapter->hw;

-       /*
-        * Flow Control Autoneg isn't on if
-        *  - we didn't ask for it OR
-        *  - it failed, we know this by tx & rx being off
-        */
-       if (hw->fc.disable_fc_autoneg ||
-           (hw->fc.current_mode == ixgbe_fc_none))
+       if (hw->fc.disable_fc_autoneg)
                 pause->autoneg = 0;
         else
                 pause->autoneg = 1;
