From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] macvlan: better mode validation
Date: Thu, 1 Aug 2013 13:43:19 +0300
Message-ID: <20130801104319.GA7127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

macvlan passthrough mode is special: it's not possible to switch to or
from it through a netlink command.

But if you try, the command will succeed, which is
confusing.

Validate input and return error to user.

Cc:  Sridhar Samudrala <sri@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/macvlan.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 18373b6..13937f9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -863,6 +863,18 @@ static int macvlan_changelink(struct net_device *dev,
 		struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	enum macvlan_mode mode;
+	bool set_mode = false;
+
+	/* Validate mode, but don't set yet: setting flags may fail. */
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		set_mode = true;
+		mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+		/* Passthrough mode can't be set or cleared dynamically */
+		if ((mode == MACVLAN_MODE_PASSTHRU) !=
+		    (vlan->mode == MACVLAN_MODE_PASSTHRU))
+			return -EINVAL;
+	}
 
 	if (data && data[IFLA_MACVLAN_FLAGS]) {
 		__u16 flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
@@ -879,8 +891,8 @@ static int macvlan_changelink(struct net_device *dev,
 		}
 		vlan->flags = flags;
 	}
-	if (data && data[IFLA_MACVLAN_MODE])
-		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+	if (set_mode)
+		vlan->mode = mode;
 	return 0;
 }
 
-- 
MST
