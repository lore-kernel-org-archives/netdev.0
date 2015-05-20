From: Arun Parameswaran <aparames@broadcom.com>
Subject: [PATCH 1/1] net: core: 'ethtool' issue with querying phy settings
Date: Wed, 20 May 2015 14:35:30 -0700
Message-ID: <1432157730-26865-2-git-send-email-aparames@broadcom.com>
References: <1432157730-26865-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>, <rjui@broadcom.com>,
	<aparames@broadcom.com>, <sbranden@broadcom.com>,
	<jdzheng@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432157730-26865-1-git-send-email-aparames@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When trying to configure the settings for PHY1, using commands
like 'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' seems to
modify other settings apart from the speed of the PHY1, in the
above case.

The ethtool seems to query the settings for PHY0, and use this
as the base to apply the new settings to the PHY1. This is
causing the other settings of the PHY 1 to be wrongly
configured.

The issue is caused by the '_ethtool_get_settings()' API, which
gets called because of the 'ETHTOOL_GSET' command, is clearing
the 'cmd' pointer (of type 'struct ethtool_cmd') by calling
memset. This clears all the parameters (if any) passed for the
'ETHTOOL_GSET' cmd. So the driver's callback is always invoked
with 'cmd->phy_address' as '0'.

The '_ethtool_get_settings()' is called from other files in the
'net/core'. So the fix is applied to the 'ethtool_get_settings()'
which is only called in the context of the 'ethtool'.

Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
Reviewed-by: Ray Jui <rjui@broadcom.com>
Reviewed-by: Scott Branden <sbranden@broadcom.com>
---
 net/core/ethtool.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1d00b89..1347e11 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -359,7 +359,15 @@ static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 	int err;
 	struct ethtool_cmd cmd;
 
-	err = __ethtool_get_settings(dev, &cmd);
+	if (!dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	cmd.cmd = ETHTOOL_GSET;
+
+	err = dev->ethtool_ops->get_settings(dev, &cmd);
 	if (err < 0)
 		return err;
 
-- 
1.7.9.5
