From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 2/4] net: enables interface option to skip IP
Date: Fri, 14 Feb 2014 18:59:38 -0800
Message-ID: <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	linux-kernel@vger.kernel.org, James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, xen-devel@lists.xenproject.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Some interfaces do not need to have any IPv4 or IPv6
addresses, so enable an option to specify this. One
example where this is observed are virtualization
backend interfaces which just use the net_device
constructs to help with their respective frontends.

This should optimize boot time and complexity on
virtualization environments for each backend interface
while also avoiding triggering SLAAC and DAD, which is
simply pointless for these type of interfaces.

Cc: "David S. Miller" <davem@davemloft.net>
cC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 include/uapi/linux/if.h | 1 +
 net/ipv4/devinet.c      | 3 +++
 net/ipv6/addrconf.c     | 6 ++++++
 3 files changed, 10 insertions(+)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 8d10382..566d856 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -85,6 +85,7 @@
 					 * change when it's running */
 #define IFF_MACVLAN 0x200000		/* Macvlan device */
 #define IFF_BRIDGE_NON_ROOT 0x400000    /* Don't consider for root bridge */
+#define IFF_SKIP_IP	0x800000	/* Skip IPv4, IPv6 */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcb..8e9ef07 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1342,6 +1342,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 
 	ASSERT_RTNL();
 
+	if (dev->priv_flags & IFF_SKIP_IP)
+		goto out;
+
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b6b720..57f58e3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -314,6 +314,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 	ASSERT_RTNL();
 
+	if (dev->priv_flags & IFF_SKIP_IP)
+		return NULL;
+
 	if (dev->mtu < IPV6_MIN_MTU)
 		return NULL;
 
@@ -2749,6 +2752,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	int run_pending = 0;
 	int err;
 
+	if (dev->priv_flags & IFF_SKIP_IP)
+		return NOTIFY_OK;
+
 	switch (event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
-- 
1.8.5.2
