From: Chris Wright <chrisw@osdl.org>
Subject: [RFC][PATCH 2/3] netlink check sender, audit
Date: Sat, 12 Feb 2005 01:05:04 -0800
Message-ID: <20050212010504.X24171@build.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@redhat.com, sds@epoch.ncsc.mil,
        serue@us.ibm.com
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050212010243.W24171@build.pdx.osdl.net>; from chrisw@osdl.org on Sat, Feb 12, 2005 at 01:02:43AM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add audit_check_sender() function for audit netlink messages.  This can also
be used to set the loginuid, although I left that off for the moment.

===== kernel/audit.c 1.9 vs edited =====
--- 1.9/kernel/audit.c	2005-01-30 22:33:47 -08:00
+++ edited/kernel/audit.c	2005-02-11 22:25:33 -08:00
@@ -309,27 +309,36 @@ nlmsg_failure:			/* Used by NLMSG_PUT */
  * Check for appropriate CAP_AUDIT_ capabilities on incoming audit
  * control messages.
  */
-static int audit_netlink_ok(kernel_cap_t eff_cap, u16 msg_type)
+static int audit_check_sender(struct sk_buff *skb)
 {
-	int err = 0;
+	struct nlmsghdr *nlh;
+	u16 msg_type;
+	int err = -EINVAL;
 
+	if (skb->len < NLMSG_LENGTH(0))
+		goto out;
+
+	nlh = (struct nlmsghdr *)skb->data;
+	msg_type = nlh->nlmsg_type;
+
+	err = 0;
 	switch (msg_type) {
 	case AUDIT_GET:
 	case AUDIT_LIST:
 	case AUDIT_SET:
 	case AUDIT_ADD:
 	case AUDIT_DEL:
-		if (!cap_raised(eff_cap, CAP_AUDIT_CONTROL))
+		if (!capable(CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
-		if (!cap_raised(eff_cap, CAP_AUDIT_WRITE))
+		if (!capable(CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
 		err = -EINVAL;
 	}
-
+out:
 	return err;
 }
 
@@ -338,14 +347,10 @@ static int audit_receive_msg(struct sk_b
 	u32			uid, pid, seq;
 	void			*data;
 	struct audit_status	*status_get, status_set;
-	int			err;
+	int			err = 0;
 	struct audit_buffer	*ab;
 	u16			msg_type = nlh->nlmsg_type;
 
-	err = audit_netlink_ok(NETLINK_CB(skb).eff_cap, msg_type);
-	if (err)
-		return err;
-
 	pid  = NETLINK_CREDS(skb)->pid;
 	uid  = NETLINK_CREDS(skb)->uid;
 	seq  = nlh->nlmsg_seq;
@@ -551,7 +556,7 @@ int __init audit_init(void)
 {
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	audit_sock = netlink_kernel_create(NETLINK_AUDIT, audit_receive);
+	audit_sock = netlink_kernel_create_check(NETLINK_AUDIT, audit_receive, audit_check_sender);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 
