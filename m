From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/5] [NETLINK]: Introduce nlmsg_hdr() helper
Date: Mon, 19 Mar 2007 22:39:07 -0300
Message-ID: <20070320013907.GG17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:36826 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbXCTBjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 21:39:12 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1497744wxd
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 18:39:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the common "(struct nlmsghdr *)skb->data" sequence, so that we reduce the
number of direct accesses to skb->data and for consistency with all the other
cast skb member helpers.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/connector/connector.c       |    2 +-
 drivers/scsi/scsi_netlink.c         |    2 +-
 drivers/scsi/scsi_transport_iscsi.c |    2 +-
 fs/ecryptfs/netlink.c               |    4 ++--
 include/linux/netlink.h             |    5 +++++
 kernel/audit.c                      |    6 +++---
 kernel/taskstats.c                  |    4 ++--
 net/decnet/netfilter/dn_rtmsg.c     |    2 +-
 net/ipv4/fib_frontend.c             |    2 +-
 net/ipv4/inet_diag.c                |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/netlink/af_netlink.c            |    2 +-
 net/tipc/netlink.c                  |    2 +-
 security/selinux/hooks.c            |    2 +-
 15 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index a905f78..7f9c4fb 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -212,7 +212,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
 	skb = skb_get(__skb);
 
 	if (skb->len >= NLMSG_SPACE(0)) {
-		nlh = (struct nlmsghdr *)skb->data;
+		nlh = nlmsg_hdr(skb);
 
 		if (nlh->nlmsg_len < sizeof(struct cn_msg) ||
 		    skb->len < nlh->nlmsg_len ||
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 1b59b27..45646a2 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -50,7 +50,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 	while (skb->len >= NLMSG_SPACE(0)) {
 		err = 0;
 
-		nlh = (struct nlmsghdr *) skb->data;
+		nlh = nlmsg_hdr(skb);
 		if ((nlh->nlmsg_len < (sizeof(*nlh) + sizeof(*hdr))) ||
 		    (skb->len < nlh->nlmsg_len)) {
 			printk(KERN_WARNING "%s: discarding partial skb\n",
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index ce0d14a..10590cd 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1081,7 +1081,7 @@ iscsi_if_rx(struct sock *sk, int len)
 			struct nlmsghdr	*nlh;
 			struct iscsi_uevent *ev;
 
-			nlh = (struct nlmsghdr *)skb->data;
+			nlh = nlmsg_hdr(skb);
 			if (nlh->nlmsg_len < sizeof(*nlh) ||
 			    skb->len < nlh->nlmsg_len) {
 				break;
diff --git a/fs/ecryptfs/netlink.c b/fs/ecryptfs/netlink.c
index e3aa225..8405d21 100644
--- a/fs/ecryptfs/netlink.c
+++ b/fs/ecryptfs/netlink.c
@@ -97,7 +97,7 @@ out:
  */
 static int ecryptfs_process_nl_response(struct sk_buff *skb)
 {
-	struct nlmsghdr *nlh = (struct nlmsghdr*)skb->data;
+	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 	struct ecryptfs_message *msg = NLMSG_DATA(nlh);
 	int rc;
 
@@ -181,7 +181,7 @@ receive:
 				"rc = [%d]\n", rc);
 		return;
 	}
-	nlh = (struct nlmsghdr *)skb->data;
+	nlh = nlmsg_hdr(skb);
 	if (!NLMSG_OK(nlh, skb->len)) {
 		ecryptfs_printk(KERN_ERR, "Received corrupt netlink "
 				"message\n");
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 68a632b..36629ff 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -138,6 +138,11 @@ struct nlattr
 #include <linux/capability.h>
 #include <linux/skbuff.h>
 
+static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
+{
+	return (struct nlmsghdr *)skb->data;
+}
+
 struct netlink_skb_parms
 {
 	struct ucred		creds;		/* Skb credentials	*/
diff --git a/kernel/audit.c b/kernel/audit.c
index ea85214..80a7457 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -151,7 +151,7 @@ struct audit_buffer {
 
 static void audit_set_pid(struct audit_buffer *ab, pid_t pid)
 {
-	struct nlmsghdr *nlh = (struct nlmsghdr *)ab->skb->data;
+	struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 	nlh->nlmsg_pid = pid;
 }
 
@@ -750,7 +750,7 @@ static void audit_receive_skb(struct sk_buff *skb)
 	u32		rlen;
 
 	while (skb->len >= NLMSG_SPACE(0)) {
-		nlh = (struct nlmsghdr *)skb->data;
+		nlh = nlmsg_hdr(skb);
 		if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 			return;
 		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
@@ -1268,7 +1268,7 @@ void audit_log_end(struct audit_buffer *ab)
 		audit_log_lost("rate limit exceeded");
 	} else {
 		if (audit_pid) {
-			struct nlmsghdr *nlh = (struct nlmsghdr *)ab->skb->data;
+			struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 			nlh->nlmsg_len = ab->skb->len - NLMSG_SPACE(0);
 			skb_queue_tail(&audit_skb_queue, ab->skb);
 			ab->skb = NULL;
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 4c3476f..ad7d239 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -102,7 +102,7 @@ static int prepare_reply(struct genl_info *info, u8 cmd, struct sk_buff **skbp,
  */
 static int send_reply(struct sk_buff *skb, pid_t pid)
 {
-	struct genlmsghdr *genlhdr = nlmsg_data((struct nlmsghdr *)skb->data);
+	struct genlmsghdr *genlhdr = nlmsg_data(nlmsg_hdr(skb));
 	void *reply = genlmsg_data(genlhdr);
 	int rc;
 
@@ -121,7 +121,7 @@ static int send_reply(struct sk_buff *skb, pid_t pid)
 static void send_cpu_listeners(struct sk_buff *skb,
 					struct listener_list *listeners)
 {
-	struct genlmsghdr *genlhdr = nlmsg_data((struct nlmsghdr *)skb->data);
+	struct genlmsghdr *genlhdr = nlmsg_data(nlmsg_hdr(skb));
 	struct listener *s, *tmp;
 	struct sk_buff *skb_next, *skb_cur = skb;
 	void *reply = genlmsg_data(genlhdr);
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index ceefd9d..9e8256a 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -102,7 +102,7 @@ static unsigned int dnrmg_hook(unsigned int hook,
 
 static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 {
-	struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
+	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 
 	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 		return;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1fba643..35515fb 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -796,7 +796,7 @@ static void nl_fib_input(struct sock *sk, int len)
 	struct fib_table *tb;
 
 	skb = skb_dequeue(&sk->sk_receive_queue);
-	nlh = (struct nlmsghdr *)skb->data;
+	nlh = nlmsg_hdr(skb);
 	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
 	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn))) {
 		kfree_skb(skb);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 37362cd..238999e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -847,7 +847,7 @@ static inline void inet_diag_rcv_skb(struct sk_buff *skb)
 {
 	if (skb->len >= NLMSG_SPACE(0)) {
 		int err;
-		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
+		struct nlmsghdr *nlh = nlmsg_hdr(skb);
 
 		if (nlh->nlmsg_len < sizeof(*nlh) ||
 		    skb->len < nlh->nlmsg_len)
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 15e0d20..17f7c98 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -497,7 +497,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	if (skblen < sizeof(*nlh))
 		return;
 
-	nlh = (struct nlmsghdr *)skb->data;
+	nlh = nlmsg_hdr(skb);
 	nlmsglen = nlh->nlmsg_len;
 	if (nlmsglen < sizeof(*nlh) || skblen < nlmsglen)
 		return;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 5cfce21..275e625 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -487,7 +487,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	if (skblen < sizeof(*nlh))
 		return;
 
-	nlh = (struct nlmsghdr *)skb->data;
+	nlh = nlmsg_hdr(skb);
 	nlmsglen = nlh->nlmsg_len;
 	if (nlmsglen < sizeof(*nlh) || skblen < nlmsglen)
 		return;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index b7bfab1..5a7e6c8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1471,7 +1471,7 @@ static int netlink_rcv_skb(struct sk_buff *skb, int (*cb)(struct sk_buff *,
 	int err;
 
 	while (skb->len >= nlmsg_total_size(0)) {
-		nlh = (struct nlmsghdr *) skb->data;
+		nlh = nlmsg_hdr(skb);
 
 		if (nlh->nlmsg_len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len)
 			return 0;
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index b8e1edc..4cdafa2 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -57,7 +57,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	if (rep_buf) {
 		skb_push(rep_buf, hdr_space);
-		rep_nlh = (struct nlmsghdr *)rep_buf->data;
+		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
 		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index addb585..5f02b4b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3786,7 +3786,7 @@ static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 		err = -EINVAL;
 		goto out;
 	}
-	nlh = (struct nlmsghdr *)skb->data;
+	nlh = nlmsg_hdr(skb);
 	
 	err = selinux_nlmsg_lookup(isec->sclass, nlh->nlmsg_type, &perm);
 	if (err) {
-- 
1.5.0.3

