From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] macvlan: validate flags
Date: Thu, 1 Aug 2013 13:48:42 +0300
Message-ID: <1375353992-7181-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roprabhu@cisco.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit df8ef8f3aaa6692970a436204c4429210addb23a
added a flags field to macvlan, which can be
controlled from userspace.
The idea is to make the interface future-proof
so we can add flags and not new fields.

However, flags value isn't validated, as a result,
userspace can't detect which flags are supported.

Cc: "David S. Miller" <davem@davemloft.net>
CC: Roopa Prabhu <roprabhu@cisco.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Please consider this patch for -stable.

The idea is by the time we add more flags,
everyone has updated to a kernel that
detects errors, so userspace will be able
to detect supported flags cleanly.


 drivers/net/macvlan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d0f9c2f..407b447 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -739,6 +739,10 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EADDRNOTAVAIL;
 	}
 
+	if (data && data[IFLA_MACVLAN_FLAGS] &&
+	    nla_get_u16(data[IFLA_MACVLAN_FLAGS]) & ~MACVLAN_FLAG_NOPROMISC)
+		return -EINVAL;
+
 	if (data && data[IFLA_MACVLAN_MODE]) {
 		switch (nla_get_u32(data[IFLA_MACVLAN_MODE])) {
 		case MACVLAN_MODE_PRIVATE:
@@ -812,6 +816,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_FLAGS])
 		vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
 
+	if (vlan->flags & ~MACVLAN_FLAG_NOPROMISC)
+		return -EINVAL;
+
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
 		if (port->count)
 			return -EINVAL;
-- 
MST
