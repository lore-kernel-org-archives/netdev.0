From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge: fix regression in ageing time
Date: Fri, 12 Feb 2016 13:31:09 -0800
Message-ID: <20160212133109.218ed423@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Jiri Pirko <jiri@resnulli.us>, Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>, Scott Feldman <sfeldma@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This fixes a regression in the bridge ageing time caused by:

commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")

There are users of Linux bridge which use the feature that if ageing time
is set to 0 it causes entries to never expire.
This feature is even listed on the web page:
  https://www.linuxfoundation.org/collaborate/workgroups/networking/bridge

For a pure software bridge, it is unnecessary for the code to have
arbitrary restrictions on what values are allowable.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Please apply to 4.4 for stable as well.

 include/linux/if_bridge.h |    5 -----
 net/bridge/br_stp.c       |    9 ++++++---
 2 files changed, 6 insertions(+), 8 deletions(-)

--- a/include/linux/if_bridge.h	2015-09-23 16:17:25.387594110 -0700
+++ b/include/linux/if_bridge.h	2016-02-11 07:49:35.016689397 -0800
@@ -45,11 +45,6 @@ struct br_ip_list {
 #define BR_PROXYARP		BIT(8)
 #define BR_LEARNING_SYNC	BIT(9)
 #define BR_PROXYARP_WIFI	BIT(10)
-
-/* values as per ieee8021QBridgeFdbAgingTime */
-#define BR_MIN_AGEING_TIME	(10 * HZ)
-#define BR_MAX_AGEING_TIME	(1000000 * HZ)
-
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
--- a/net/bridge/br_stp.c	2015-12-17 17:17:18.650746679 -0800
+++ b/net/bridge/br_stp.c	2016-02-11 07:49:53.240772672 -0800
@@ -568,6 +568,12 @@ int br_set_max_age(struct net_bridge *br
 
 }
 
+/* Set the how long dynamic forwarding database entries live.
+ * The Linux bridge allows values outside the standard 802.1
+ * specification to allow for special cases:
+ *   0 - means entry never age.
+ *   1 - means entries disappear in next clock tick
+ */
 int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
 {
 	struct switchdev_attr attr = {
@@ -579,9 +585,6 @@ int br_set_ageing_time(struct net_bridge
 	unsigned long t = clock_t_to_jiffies(ageing_time);
 	int err;
 
-	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
-		return -ERANGE;
-
 	err = switchdev_port_attr_set(br->dev, &attr);
 	if (err)
 		return err;
