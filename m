From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 5/6] audit: add netlink multicast group for log read
Date: Fri, 18 Apr 2014 13:34:09 -0400
Message-ID: <bd8877d51ad46dd6e7ee71a8b45a905095a17bf7.1397831970.git.rgb@redhat.com>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	eparis@redhat.com, netfilter-devel@vger.kernel.org,
	hadi@mojatatu.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140324183406.GE28666@madcap2.tricolour.ca>
In-Reply-To: <cover.1397831970.git.rgb@redhat.com>
References: <cover.1397831970.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a netlink multicast socket with one group to kaudit for "best-effort"
delivery to read-only userspace clients such as systemd, in addition to the
existing bidirectional unicast auditd userspace client.

Currently, auditd is intended to use the CAP_AUDIT_CONTROL and CAP_AUDIT_WRITE
capabilities, but actually uses CAP_NET_ADMIN.  The CAP_AUDIT_READ capability
is added for use by read-only AUDIT_NLGRP_READLOG netlink multicast group
clients to the kaudit subsystem.

This will safely give access to services such as systemd to consume audit logs
while ensuring write access remains restricted for integrity.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 include/uapi/linux/audit.h |    8 +++++++
 kernel/audit.c             |   51 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index 11917f7..dfa4c86 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -373,6 +373,14 @@ enum {
  */
 #define AUDIT_MESSAGE_TEXT_MAX	8560
 
+/* Multicast Netlink socket groups (default up to 32) */
+enum audit_nlgrps {
+	AUDIT_NLGRP_NONE,	/* Group 0 not used */
+	AUDIT_NLGRP_READLOG,	/* "best effort" read only socket */
+	__AUDIT_NLGRP_MAX
+};
+#define AUDIT_NLGRP_MAX                (__AUDIT_NLGRP_MAX - 1)
+
 struct audit_status {
 	__u32		mask;		/* Bit mask for valid entries */
 	__u32		enabled;	/* 1 = enabled, 0 = disabled */
diff --git a/kernel/audit.c b/kernel/audit.c
index 223cb74..d272cc1 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -424,6 +424,35 @@ static void kauditd_send_skb(struct sk_buff *skb)
 }
 
 /*
+ * kauditd_send_multicast_skb - send the skb to multicast userspace listeners
+ *
+ * This function doesn't consume an skb as might be expected since it has to
+ * copy it anyways.
+ */
+static void kauditd_send_multicast_skb(struct sk_buff *skb)
+{
+	struct sk_buff		*copy;
+	struct audit_net	*aunet = net_generic(&init_net, audit_net_id);
+	struct sock		*sock = aunet->nlsk;
+
+	/*
+	 * The seemingly wasteful skb_copy() rather than bumping the refcount
+	 * using skb_get() is necessary because non-standard mods are made to
+	 * the skb by the original kaudit unicast socket send routine.  The
+	 * existing auditd daemon assumes this breakage.  Fixing this would
+	 * require co-ordinating a change in the established protocol between
+	 * the kaudit kernel subsystem and the auditd userspace code.  There is
+	 * no reason for new multicast clients to continue with this
+	 * non-compliance.
+	 */
+	copy = skb_copy(skb, GFP_KERNEL);
+	if (!copy)
+		return;
+
+	nlmsg_multicast(sock, copy, 0, AUDIT_NLGRP_READLOG, GFP_KERNEL);
+}
+
+/*
  * flush_hold_queue - empty the hold queue if auditd appears
  *
  * If auditd just started, drain the queue of messages already
@@ -1090,6 +1119,8 @@ static int __net_init audit_net_init(struct net *net)
 	struct netlink_kernel_cfg cfg = {
 		.input	= audit_receive,
 		.bind	= audit_bind,
+		.flags	= NL_CFG_F_NONROOT_RECV,
+		.groups	= AUDIT_NLGRP_MAX,
 	};
 
 	struct audit_net *aunet = net_generic(net, audit_net_id);
@@ -1911,10 +1942,10 @@ out:
  * audit_log_end - end one audit record
  * @ab: the audit_buffer
  *
- * The netlink_* functions cannot be called inside an irq context, so
- * the audit buffer is placed on a queue and a tasklet is scheduled to
- * remove them from the queue outside the irq context.  May be called in
- * any context.
+ * netlink_unicast() cannot be called inside an irq context because it blocks
+ * (last arg, flags, is not set to MSG_DONTWAIT), so the audit buffer is placed
+ * on a queue and a tasklet is scheduled to remove them from the queue outside
+ * the irq context.  May be called in any context.
  */
 void audit_log_end(struct audit_buffer *ab)
 {
@@ -1924,6 +1955,18 @@ void audit_log_end(struct audit_buffer *ab)
 		audit_log_lost("rate limit exceeded");
 	} else {
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
+
+		kauditd_send_multicast_skb(ab->skb);
+
+		/*
+		 * The original kaudit unicast socket sends up messages with
+		 * nlmsg_len set to the payload length rather than the entire
+		 * message length.  This breaks the standard set by netlink.
+		 * The existing auditd daemon assumes this breakage.  Fixing
+		 * this would require co-ordinating a change in the established
+		 * protocol between the kaudit kernel subsystem and the auditd
+		 * userspace code.
+		 */
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
 		if (audit_pid) {
-- 
1.7.1
