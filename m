From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] Add audit uid to netlink credentials
Date: Fri, 4 Feb 2005 10:58:40 -0600
Message-ID: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com
To: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Most audit control messages are sent over netlink.  In order to properly
log the identity of the sender of audit control messages, we would like
to add the loginuid to the netlink_creds structure, as per the attached
patch.

thanks,
-serge

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
Index: linux-2.6.10/include/linux/audit.h
===================================================================
--- linux-2.6.10.orig/include/linux/audit.h	2005-01-27 10:46:57.887036520 -0600
+++ linux-2.6.10/include/linux/audit.h	2005-01-27 10:51:37.408542792 -0600
@@ -145,7 +145,7 @@ extern void audit_inode(const char *name
 
 				/* Private API (for audit.c only) */
 extern int  audit_receive_filter(int type, int pid, int uid, int seq,
-				 void *data);
+				 void *data, uid_t loginuid);
 extern void audit_get_stamp(struct audit_context *ctx,
 			    struct timespec *t, int *serial);
 extern int  audit_set_loginuid(struct audit_context *ctx, uid_t loginuid);
@@ -179,10 +179,10 @@ extern void		    audit_log_d_path(struct
 					     const char *prefix,
 					     struct dentry *dentry,
 					     struct vfsmount *vfsmnt);
-extern int		    audit_set_rate_limit(int limit);
-extern int		    audit_set_backlog_limit(int limit);
-extern int		    audit_set_enabled(int state);
-extern int		    audit_set_failure(int state);
+extern int		    audit_set_rate_limit(int limit, uid_t loginuid);
+extern int		    audit_set_backlog_limit(int limit, uid_t loginuid);
+extern int		    audit_set_enabled(int state, uid_t loginuid);
+extern int		    audit_set_failure(int state, uid_t loginuid);
 
 				/* Private API (for auditsc.c only) */
 extern void		    audit_send_reply(int pid, int seq, int type,
Index: linux-2.6.10/include/linux/netlink.h
===================================================================
--- linux-2.6.10.orig/include/linux/netlink.h	2005-01-27 10:46:57.888036368 -0600
+++ linux-2.6.10/include/linux/netlink.h	2005-01-27 10:51:37.409542640 -0600
@@ -110,6 +110,7 @@ struct netlink_skb_parms
 	__u32			dst_pid;
 	__u32			dst_groups;
 	kernel_cap_t		eff_cap;
+	__u32			loginuid;	/* Login (audit) uid */
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
Index: linux-2.6.10/kernel/audit.c
===================================================================
--- linux-2.6.10.orig/kernel/audit.c	2005-01-27 10:46:57.888036368 -0600
+++ linux-2.6.10/kernel/audit.c	2005-01-27 10:52:28.753737136 -0600
@@ -236,36 +236,36 @@ void audit_log_lost(const char *message)
 
 }
 
-int audit_set_rate_limit(int limit)
+int audit_set_rate_limit(int limit, uid_t loginuid)
 {
 	int old		 = audit_rate_limit;
 	audit_rate_limit = limit;
-	audit_log(current->audit_context, "audit_rate_limit=%d old=%d",
-		  audit_rate_limit, old);
+	audit_log(NULL, "audit_rate_limit=%d old=%d by loginuid %u",
+			audit_rate_limit, old, loginuid);
 	return old;
 }
 
-int audit_set_backlog_limit(int limit)
+int audit_set_backlog_limit(int limit, uid_t loginuid)
 {
 	int old		 = audit_backlog_limit;
 	audit_backlog_limit = limit;
-	audit_log(current->audit_context, "audit_backlog_limit=%d old=%d",
-		  audit_backlog_limit, old);
+	audit_log(NULL, "audit_backlog_limit=%d old=%d by loginuid %u",
+			audit_backlog_limit, old, loginuid);
 	return old;
 }
 
-int audit_set_enabled(int state)
+int audit_set_enabled(int state, uid_t loginuid)
 {
 	int old		 = audit_enabled;
 	if (state != 0 && state != 1)
 		return -EINVAL;
 	audit_enabled = state;
-	audit_log(current->audit_context, "audit_enabled=%d old=%d",
-		  audit_enabled, old);
+	audit_log(NULL, "audit_enabled=%d old=%d by loginuid %u",
+		  audit_enabled, old, loginuid);
 	return old;
 }
 
-int audit_set_failure(int state)
+int audit_set_failure(int state, uid_t loginuid)
 {
 	int old		 = audit_failure;
 	if (state != AUDIT_FAIL_SILENT
@@ -273,8 +273,8 @@ int audit_set_failure(int state)
 	    && state != AUDIT_FAIL_PANIC)
 		return -EINVAL;
 	audit_failure = state;
-	audit_log(current->audit_context, "audit_failure=%d old=%d",
-		  audit_failure, old);
+	audit_log(NULL, "audit_failure=%d old=%d by loginuid %u",
+		  audit_failure, old, loginuid);
 	return old;
 }
 
@@ -341,6 +341,7 @@ static int audit_receive_msg(struct sk_b
 	int			err;
 	struct audit_buffer	*ab;
 	u16			msg_type = nlh->nlmsg_type;
+	uid_t			loginuid; /* loginuid of sender */
 
 	err = audit_netlink_ok(NETLINK_CB(skb).eff_cap, msg_type);
 	if (err)
@@ -348,6 +349,7 @@ static int audit_receive_msg(struct sk_b
 
 	pid  = NETLINK_CREDS(skb)->pid;
 	uid  = NETLINK_CREDS(skb)->uid;
+	loginuid = NETLINK_CB(skb).loginuid;
 	seq  = nlh->nlmsg_seq;
 	data = NLMSG_DATA(nlh);
 
@@ -368,31 +370,33 @@ static int audit_receive_msg(struct sk_b
 			return -EINVAL;
 		status_get   = (struct audit_status *)data;
 		if (status_get->mask & AUDIT_STATUS_ENABLED) {
-			err = audit_set_enabled(status_get->enabled);
+			err = audit_set_enabled(status_get->enabled, loginuid);
 			if (err < 0) return err;
 		}
 		if (status_get->mask & AUDIT_STATUS_FAILURE) {
-			err = audit_set_failure(status_get->failure);
+			err = audit_set_failure(status_get->failure, loginuid);
 			if (err < 0) return err;
 		}
 		if (status_get->mask & AUDIT_STATUS_PID) {
 			int old   = audit_pid;
 			audit_pid = status_get->pid;
-			audit_log(current->audit_context,
-				  "audit_pid=%d old=%d", audit_pid, old);
+			audit_log(NULL, "audit_pid=%d old=%d by loginuid %u",
+				  audit_pid, old, loginuid);
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT)
-			audit_set_rate_limit(status_get->rate_limit);
+			audit_set_rate_limit(status_get->rate_limit, loginuid);
 		if (status_get->mask & AUDIT_STATUS_BACKLOG_LIMIT)
-			audit_set_backlog_limit(status_get->backlog_limit);
+			audit_set_backlog_limit(status_get->backlog_limit,
+							loginuid);
 		break;
 	case AUDIT_USER:
 		ab = audit_log_start(NULL);
 		if (!ab)
 			break;	/* audit_panic has been called */
 		audit_log_format(ab,
-				 "user pid=%d uid=%d length=%d msg='%.1024s'",
-				 pid, uid,
+				 "user pid=%d uid=%d loginuid=%u length=%d"
+				 " msg='%.1024s'",
+				 pid, uid, loginuid,
 				 (int)(nlh->nlmsg_len
 				       - ((char *)data - (char *)nlh)),
 				 (char *)data);
@@ -408,7 +412,7 @@ static int audit_receive_msg(struct sk_b
 	case AUDIT_LIST:
 #ifdef CONFIG_AUDITSYSCALL
 		err = audit_receive_filter(nlh->nlmsg_type, pid, uid, seq,
-					   data);
+					   data, loginuid);
 #else
 		err = -EOPNOTSUPP;
 #endif
Index: linux-2.6.10/kernel/auditsc.c
===================================================================
--- linux-2.6.10.orig/kernel/auditsc.c	2005-01-27 10:46:57.890036064 -0600
+++ linux-2.6.10/kernel/auditsc.c	2005-01-27 10:52:53.776933032 -0600
@@ -228,7 +228,8 @@ static int audit_copy_rule(struct audit_
 	return 0;
 }
 
-int audit_receive_filter(int type, int pid, int uid, int seq, void *data)
+int audit_receive_filter(int type, int pid, int uid, int seq, void *data,
+							uid_t loginuid)
 {
 	u32		   flags;
 	struct audit_entry *entry;
@@ -263,6 +264,7 @@ int audit_receive_filter(int type, int p
 			err = audit_add_rule(entry, &audit_entlist);
 		if (!err && (flags & AUDIT_AT_EXIT))
 			err = audit_add_rule(entry, &audit_extlist);
+		audit_log(NULL, "loginuid %u added an audit rule\n", loginuid);
 		break;
 	case AUDIT_DEL:
 		flags =((struct audit_rule *)data)->flags;
@@ -272,6 +274,8 @@ int audit_receive_filter(int type, int p
 			err = audit_del_rule(data, &audit_entlist);
 		if (!err && (flags & AUDIT_AT_EXIT))
 			err = audit_del_rule(data, &audit_extlist);
+		audit_log(NULL, "loginuid %u removed an audit rule\n",
+							loginuid);
 		break;
 	default:
 		return -EINVAL;
Index: linux-2.6.10/net/netlink/af_netlink.c
===================================================================
--- linux-2.6.10.orig/net/netlink/af_netlink.c	2005-01-27 10:46:57.891035912 -0600
+++ linux-2.6.10/net/netlink/af_netlink.c	2005-01-27 10:51:37.411542336 -0600
@@ -928,6 +928,7 @@ static int netlink_sendmsg(struct kiocb 
 	NETLINK_CB(skb).groups	= nlk->groups;
 	NETLINK_CB(skb).dst_pid = dst_pid;
 	NETLINK_CB(skb).dst_groups = dst_groups;
+	NETLINK_CB(skb).loginuid = audit_get_loginuid(current->audit_context);
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
 	/* What can I do? Netlink is asynchronous, so that
