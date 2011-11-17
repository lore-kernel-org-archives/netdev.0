From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/5] stmmac: remove spin_lock in stmmac_ioctl.
Date: Thu, 17 Nov 2011 08:58:01 +0100
Message-ID: <1321516682-32208-4-git-send-email-peppe.cavallaro@st.com>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Cc: francesco.virlinzi@st.com, srinivas.kandagatla@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36420 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1KQH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:58:25 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C4A2F2B5
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:23 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 93B23190C
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:23 +0000 (GMT)
In-Reply-To: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes un-needed spin_lock in stmmac_ioctl while reading and
writing mdio registers. While holding spin_lock the code must be
atomic, which is not true in this case as both mdiobus_read and writes
have mutex locks.

Without this patch reading mdio registers via mii-tool results in below
BUG:
mii-tool -vvv eth0"
Using SIOCGMIIPHY=0x8947
BUG: sleeping function called from invalid context at kernel/mutex.c:287
in_atomic(): 1, irqs_disabled(): 0, pid: 614, name: mii-tool
2 locks held by mii-tool/614:
 #0:  (rtnl_mutex){......}, at: [<c01fd80c>] dev_ioctl+0x550/0x674
 #1:  (&priv->lock){......}, at: [<c01b34ec>] stmmac_ioctl+0x4c/0x78
[<c002ea14>] (unwind_backtrace+0x0/0xcc) from [<c0272c38>]
(mutex_lock_nested+0x24/0x35c)
[<c0272c38>] (mutex_lock_nested+0x24/0x35c) from [<c01b237c>]
(mdiobus_read+0x44/0x70)
[<c01b237c>] (mdiobus_read+0x44/0x70) from [<c01b0c64>]
(phy_mii_ioctl+0x4c/0x138)
[<c01b0c64>] (phy_mii_ioctl+0x4c/0x138) from [<c01b34fc>]
(stmmac_ioctl+0x5c/0x78)
[<c01b34fc>] (stmmac_ioctl+0x5c/0x78) from [<c01fcec8>]
(dev_ifsioc+0x2a4/0x2c8)
[<c01fcec8>] (dev_ifsioc+0x2a4/0x2c8) from [<c01fd81c>]
(dev_ioctl+0x560/0x674)
[<c01fd81c>] (dev_ioctl+0x560/0x674) from [<c00c36e0>]
(vfs_ioctl+0x2c/0x8c)
[<c00c36e0>] (vfs_ioctl+0x2c/0x8c) from [<c00c4130>]
(do_vfs_ioctl+0x530/0x578)
[<c00c4130>] (do_vfs_ioctl+0x530/0x578) from [<c00c41ac>]
(sys_ioctl+0x34/0x54)
[<c00c41ac>] (sys_ioctl+0x34/0x54) from [<c0028aa0>]
(ret_fast_syscall+0x0/0x2c)

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7f3ffd3..29dd87c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1536,9 +1536,7 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!priv->phydev)
 		return -EINVAL;
 
-	spin_lock(&priv->lock);
 	ret = phy_mii_ioctl(priv->phydev, rq, cmd);
-	spin_unlock(&priv->lock);
 
 	return ret;
 }
-- 
1.7.4.4
