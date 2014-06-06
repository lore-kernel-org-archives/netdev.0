From: Michal Privoznik <mprivozn@redhat.com>
Subject: [PATCH] net-sysfs: Report link speed only when possible
Date: Fri,  6 Jun 2014 10:40:30 +0200
Message-ID: <771f792d4d4391c656305a522557c53c4e84a666.1402043894.git.mprivozn@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link speed is available at /sys/class/net/$nic/speed.
However, in some cases, depending on the driver, if the link is
not plugged, -1 is reported (this is the case of e1000e for
instance). To make things worse, the value is printed out as an
unsigned integer, so you'll get this shady number which you can't
evaluate correctly. This is actually a regression in 3.X kernels
as the commit that broke things is 8ae6daca. With this change,
you'll get -EINVAL whenever a -1 is to be printed out.

Before the change:
  # cat /sys/class/net/eth0/speed
  4294967295

After the change:
  # cat /sys/class/net/eth0/speed
  cat: /sys/class/net/eth0/speed: Invalid argument

Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
---
 net/core/net-sysfs.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..ce4b298 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -172,8 +172,13 @@ static ssize_t speed_show(struct device *dev,
 
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
-		if (!__ethtool_get_settings(netdev, &cmd))
-			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
+		if (!__ethtool_get_settings(netdev, &cmd)) {
+			__u32 speed = ethtool_cmd_speed(&cmd);
+
+			if (speed != (__u32) -1)
+				ret = sprintf(buf, fmt_udec,
+					      ethtool_cmd_speed(&cmd));
+		}
 	}
 	rtnl_unlock();
 	return ret;
-- 
2.0.0
