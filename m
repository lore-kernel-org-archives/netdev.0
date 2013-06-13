From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2] macvlan: don't touch promisc without passthrough
Date: Thu, 13 Jun 2013 10:07:29 +0300
Message-ID: <1371107001-10250-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit df8ef8f3aaa6692970a436204c4429210addb23a
"macvlan: add FDB bridge ops and macvlan flags"
added a way to control NOPROMISC macvlan flag through netlink.

However, with a non passthrough device we never set promisc on open,
even if NOPROMISC is off.  As a result:

If userspace clears NOPROMISC on open, then does not clear it on a
netlink command, promisc counter is not decremented on stop and there
will be no way to clear it once macvlan is detached.

If userspace does not clear NOPROMISC on open, then sets NOPROMISC on a
netlink command, promisc counter will be decremented from 0 and overflow
to fffffffff with no way to clear promisc.

To fix, simply ignore NOPROMISC flag in a netlink command for
non-passthrough devices, same as we do at open/close.

Since we touch this code anyway - check dev_set_promiscuity return code
and pass it to users (though an error here is unlikely).

Cc: "David S. Miller" <davem@davemloft.net>
Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1:
    minor style changes suggested by Sergei Shtylyov

 drivers/net/macvlan.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1c502bb..6e91931 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -853,18 +853,24 @@ static int macvlan_changelink(struct net_device *dev,
 		struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	if (data && data[IFLA_MACVLAN_MODE])
-		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+
 	if (data && data[IFLA_MACVLAN_FLAGS]) {
 		__u16 flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
 		bool promisc = (flags ^ vlan->flags) & MACVLAN_FLAG_NOPROMISC;
-
-		if (promisc && (flags & MACVLAN_FLAG_NOPROMISC))
-			dev_set_promiscuity(vlan->lowerdev, -1);
-		else if (promisc && !(flags & MACVLAN_FLAG_NOPROMISC))
-			dev_set_promiscuity(vlan->lowerdev, 1);
+		if (vlan->port->passthru && promisc) {
+			int err;
+
+			if (flags & MACVLAN_FLAG_NOPROMISC)
+				err = dev_set_promiscuity(vlan->lowerdev, -1);
+			else
+				err = dev_set_promiscuity(vlan->lowerdev, 1);
+			if (err < 0)
+				return err;
+		}
 		vlan->flags = flags;
 	}
+	if (data && data[IFLA_MACVLAN_MODE])
+		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 	return 0;
 }
 
-- 
MST
