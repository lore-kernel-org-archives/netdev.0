From: Chris Wright <chrisw@osdl.org>
Subject: [RFC][PATCH 3/3] netlink check sender, rtnetlink
Date: Sat, 12 Feb 2005 01:06:32 -0800
Message-ID: <20050212010632.Y24171@build.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@redhat.com, sds@epoch.ncsc.mil,
        serue@us.ibm.com
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050212010504.X24171@build.pdx.osdl.net>; from chrisw@osdl.org on Sat, Feb 12, 2005 at 01:05:04AM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add rtnetlink_check_sender() function to validate rtnetlink messages in
sender context.  Invalid messages (due to content or sender privileges)
will be rejected before queued to socket.

===== net/core/rtnetlink.c 1.33 vs edited =====
--- 1.33/net/core/rtnetlink.c	2005-01-10 13:42:22 -08:00
+++ edited/net/core/rtnetlink.c	2005-02-12 00:13:46 -08:00
@@ -462,8 +462,32 @@ static int rtnetlink_done(struct netlink
 static struct rtattr **rta_buf;
 static int rtattr_max;
 
-/* Process one rtnetlink message. */
+static int rtnetlink_check_sender(struct sk_buff *skb)
+{
+	struct nlmsghdr *nlh;
+	int kind;
+	int type;
+
+	if (skb->len < NLMSG_LENGTH(0))
+		return -EINVAL;
+
+	nlh = (struct nlmsghdr *)skb->data;
+	type = nlh->nlmsg_type;
+
+	/* Unknown message: reply with EINVAL */
+	if (type > RTM_MAX)
+		return -EINVAL;
+
+	type -= RTM_BASE;
+	kind = type&3;
 
+	if (kind != 2 && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return 0;
+}
+
+/* Process one rtnetlink message. */
 static __inline__ int
 rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
 {
@@ -485,10 +509,6 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	if (type < RTM_BASE)
 		return 0;
 
-	/* Unknown message: reply with EINVAL */
-	if (type > RTM_MAX)
-		goto err_inval;
-
 	type -= RTM_BASE;
 
 	/* All the messages must have at least 1 byte length */
@@ -509,11 +529,6 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb)) {
-		*errp = -EPERM;
-		return -1;
-	}
-
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		u32 rlen;
 
@@ -690,7 +705,8 @@ void __init rtnetlink_init(void)
 	if (!rta_buf)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
-	rtnl = netlink_kernel_create(NETLINK_ROUTE, rtnetlink_rcv);
+	rtnl = netlink_kernel_create_check(NETLINK_ROUTE, rtnetlink_rcv,
+					   rtnetlink_check_sender);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
