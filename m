From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 1/22] xfrm offload v2: Add direction information to xfrm_state
Date: Mon, 10 Jan 2005 10:36:59 -0500
Message-ID: <20040110014300.10@ori.thedillows.org>
References: <20040110014300.01@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 23:59:53-05:00 dave@thedillows.org 
#   Add direction information to xfrm_state. This will be needed to
#   offload xfrm processing to the NIC.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/xfrm/xfrm_state.c
#   2005/01/09 23:59:35-05:00 dave@thedillows.org +5 -0
#   Add direction information to xfrm_state. This will be needed to
#   offload xfrm processing to the NIC.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv6/xfrm6_state.c
#   2005/01/09 23:59:35-05:00 dave@thedillows.org +10 -0
#   Place holder for adding IPv6 direction mapping routine.
# 
# net/ipv4/xfrm4_state.c
#   2005/01/09 23:59:35-05:00 dave@thedillows.org +9 -0
#   Add direction information to xfrm_state. This will be needed to
#   offload xfrm processing to the NIC.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# include/net/xfrm.h
#   2005/01/09 23:59:35-05:00 dave@thedillows.org +10 -0
#   Add direction information to xfrm_state. This will be needed to
#   offload xfrm processing to the NIC.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2005-01-10 01:20:40 -05:00
+++ b/include/net/xfrm.h	2005-01-10 01:20:40 -05:00
@@ -146,6 +146,9 @@
 	/* Private data of this transformer, format is opaque,
 	 * interpreted by xfrm_type methods. */
 	void			*data;
+
+	/* Intended direction of this state, used for offloading */
+	u8			dir;
 };
 
 enum {
@@ -157,6 +160,12 @@
 	XFRM_STATE_DEAD
 };
 
+enum {
+	XFRM_STATE_DIR_UNKNOWN,
+	XFRM_STATE_DIR_IN,
+	XFRM_STATE_DIR_OUT,
+};
+
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -194,6 +203,7 @@
 	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
 					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					     int create);
+	u8			(*direction)(struct xfrm_state *xfrm);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
diff -Nru a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
--- a/net/ipv4/xfrm4_state.c	2005-01-10 01:20:40 -05:00
+++ b/net/ipv4/xfrm4_state.c	2005-01-10 01:20:40 -05:00
@@ -106,12 +106,21 @@
 	return x0;
 }
 
+static u8
+__xfrm4_direction(struct xfrm_state *x)
+{
+	if (inet_addr_type(x->id.daddr.a4) == RTN_LOCAL)
+		return XFRM_STATE_DIR_IN;
+	return XFRM_STATE_DIR_OUT;
+}
+
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.lock			= RW_LOCK_UNLOCKED,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
 	.find_acq		= __xfrm4_find_acq,
+	.direction		= __xfrm4_direction,
 };
 
 void __init xfrm4_state_init(void)
diff -Nru a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
--- a/net/ipv6/xfrm6_state.c	2005-01-10 01:20:40 -05:00
+++ b/net/ipv6/xfrm6_state.c	2005-01-10 01:20:40 -05:00
@@ -116,12 +116,22 @@
 	return x0;
 }
 
+static u8
+__xfrm6_direction(struct xfrm_state *x)
+{
+	/* XXX This needs to be implemented by someone who knows
+	 * IPv6 better then I.
+	 */
+	return XFRM_STATE_DIR_UNKNOWN;
+}
+
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.lock			= RW_LOCK_UNLOCKED,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
 	.find_acq		= __xfrm6_find_acq,
+	.direction		= __xfrm6_direction,
 };
 
 void __init xfrm6_state_init(void)
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-01-10 01:20:40 -05:00
+++ b/net/xfrm/xfrm_state.c	2005-01-10 01:20:40 -05:00
@@ -189,6 +189,7 @@
 		x->lft.soft_packet_limit = XFRM_INF;
 		x->lft.hard_byte_limit = XFRM_INF;
 		x->lft.hard_packet_limit = XFRM_INF;
+		x->dir = XFRM_STATE_DIR_UNKNOWN;
 		spin_lock_init(&x->lock);
 	}
 	return x;
@@ -407,6 +408,8 @@
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
+	x->dir = afinfo->direction(x);
+
 	spin_lock_bh(&xfrm_state_lock);
 
 	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
@@ -454,6 +457,8 @@
 	afinfo = xfrm_state_get_afinfo(x->props.family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
+
+	x->dir = afinfo->direction(x);
 
 	spin_lock_bh(&xfrm_state_lock);
 	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
