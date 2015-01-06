From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Subject: [PATCH 1/1] bridge: remove BR_GROUPFWD_RESTRICTED for
	arbitrary forwarding of reserved addresses
Date: Tue,  6 Jan 2015 01:56:15 +0100
Message-ID: <1420505776-26827-1-git-send-email-bernhard.thaler@wvnet.at>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>
To: stephen@networkplumber.org,
	davem@davemloft.net
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

BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
/sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
some IEEE 802.1D Table 7-10 Reserved addresses:
	(MAC Control) 802.3		01-80-C2-00-00-01
	(Link Aggregation) 802.3	01-80-C2-00-00-02
	802.1AB LLDP			01-80-C2-00-00-0E
BR_GROUPFWD_RESTRICTED may have been set as an extra protection against
forwarding these control frames as forwarding 802.1X PAE (01-80-C2-00-00-03)
in 802.1X setups satisfies most common use-cases.
Other situations, such as placing a software based bridge as a "TAP" between two
devices may require to forward e.g. LLDP frames while debugging network problems
or actively changing/filtering traffic with ebtables.

This patch allows to set e.g.:
	echo 65535 > /sys/class/net/brX/bridge/group_fwd_mask
which sets no restrictions on the forwardable reserved addresses.

- the default value 0 will still comply with 802.1D and not forward any
  reserved addresses
- values such as 8 for forwarding 802.1X related frames will behave the
  same way as with BR_GROUPFWD_RESTRICTED currently in place, so backward
  compatibility to current scripts using group_fwd_masks shoudl be possible

Administrators and network engineers however will be able to arbitrarily
forward any reserved addresses without BR_GROUPFWD_RESTRICTED. This will
be non-standard compliant behavior, but forwarding of any reserved address
right from the beginning is. Users should be aware of this anyway and
know what/why they are doing when setting values such as 65535, 32768, 16384,
4, 2 for group_fwd_mask

This patch was tested on a bridge with two interfaces created with bridge-utils.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
---
 net/bridge/br_input.c    |    8 ++++++--
 net/bridge/br_private.h  |    2 --
 net/bridge/br_sysfs_br.c |    3 ---
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1f1de71..e44fe38 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -262,8 +262,12 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 				goto forward;
 			break;
 
-		case 0x01:	/* IEEE MAC (Pause) */
-			goto drop;
+		case 0x01:      /* IEEE MAC (Pause) */
+			fwd_mask |= p->br->group_fwd_mask;
+			if (fwd_mask & (1u << dest[5]))
+				goto forward;
+			else
+				goto drop;
 
 		default:
 			/* Allow selective forwarding for most other protocols */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index aea3d13..9b548754 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -33,8 +33,6 @@
 
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
-/* Don't allow forwarding control protocols like STP and LLDP */
-#define BR_GROUPFWD_RESTRICTED	0x4007u
 /* The Nearest Customer Bridge Group Address, 01-80-C2-00-00-[00,0B,0C,0D,0F] */
 #define BR_GROUPFWD_8021AD	0xB801u
 
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..7f04d8b 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -171,9 +171,6 @@ static ssize_t group_fwd_mask_store(struct device *d,
 	if (endp == buf)
 		return -EINVAL;
 
-	if (val & BR_GROUPFWD_RESTRICTED)
-		return -EINVAL;
-
 	br->group_fwd_mask = val;
 
 	return len;
-- 
1.7.10.4
