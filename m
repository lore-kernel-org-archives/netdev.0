From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] Fix to avoid overriding TCP/UDP with a new protocol of same
 type.
Date: Wed, 19 Feb 2003 16:14:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302191603540.1590-100000@dyn9-47-18-140.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, Alexey,

I think i found a bug in inet_register_protosw() which results in a behavior
that is not expected.

Registering a new protocol of type SOCK_STREAM with a protocol value other
than IPPROTO_TCP will override TCP if the application passes 0 as the protocol
to the socket() call.
	socket(AF_INET, SOCK_STREAM, 0)
I guess many applications follow this syntax as they assume TCP is the default
protocol for SOCK_STREAM type.
The same holds true for SOCK_DGRAM type sockets assuing UDP as the default.

This is due to the insertion of a new inet_protosw entry into the inetsw list
of a particular type at the head of the list. inet_create() uses the first
entry in the list if a wild-card protocol is passed.

The following patch fixes the insertion of a new entry so that it is added
after the last permanent entry in the list. This makes sure that the new 
entries do not override any existing permanent entries.

I found this problem when i registered SOCK_STREAM/IPPROTO_SCTP to support
tcp-style SCTP sockets and surprisingly noticed 'ssh' using SCTP as the 
transport protocol.

Thanks
Sridhar

Patch against linux 2.5.62
-------------------------------------------------------------------------------
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Wed Feb 19 15:37:34 2003
+++ b/net/ipv4/af_inet.c	Wed Feb 19 15:37:34 2003
@@ -976,6 +976,7 @@
 	struct list_head *lh;
 	struct inet_protosw *answer;
 	int protocol = p->protocol;
+	struct list_head *last_perm;
 
 	br_write_lock_bh(BR_NETPROTO_LOCK);
 
@@ -984,24 +985,29 @@
 
 	/* If we are trying to override a permanent protocol, bail. */
 	answer = NULL;
+	last_perm = &inetsw[p->type];
 	list_for_each(lh, &inetsw[p->type]) {
 		answer = list_entry(lh, struct inet_protosw, list);
 
 		/* Check only the non-wild match. */
-		if (protocol == answer->protocol &&
-		    (INET_PROTOSW_PERMANENT & answer->flags))
-			break;
+		if (INET_PROTOSW_PERMANENT & answer->flags) {
+			if (protocol == answer->protocol)
+				break;
+			last_perm = lh;
+		}
 
 		answer = NULL;
 	}
 	if (answer)
 		goto out_permanent;
 
-	/* Add to the BEGINNING so that we override any existing
-	 * entry.  This means that when we remove this entry, the
+	/* Add the new entry after the last permanent entry if any, so that
+	 * the new entry does not override a permanent entry when matched with
+	 * a wild-card protocol. But it is allowed to override any existing
+	 * non-permanent entry.  This means that when we remove this entry, the 
 	 * system automatically returns to the old behavior.
 	 */
-	list_add(&p->list, &inetsw[p->type]);
+	list_add(&p->list, last_perm);
 out:
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 	return;
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	Wed Feb 19 15:37:34 2003
+++ b/net/ipv6/af_inet6.c	Wed Feb 19 15:37:34 2003
@@ -571,6 +571,7 @@
 	struct list_head *lh;
 	struct inet_protosw *answer;
 	int protocol = p->protocol;
+	struct list_head *last_perm;
 
 	br_write_lock_bh(BR_NETPROTO_LOCK);
 
@@ -579,24 +580,29 @@
 
 	/* If we are trying to override a permanent protocol, bail. */
 	answer = NULL;
+	last_perm = &inetsw6[p->type];
 	list_for_each(lh, &inetsw6[p->type]) {
 		answer = list_entry(lh, struct inet_protosw, list);
 
 		/* Check only the non-wild match. */
-		if (protocol == answer->protocol &&
-		    (INET_PROTOSW_PERMANENT & answer->flags))
-			break;
+		if (INET_PROTOSW_PERMANENT & answer->flags) {
+			if (protocol == answer->protocol)
+				break;
+			last_perm = lh;
+		}
 
 		answer = NULL;
 	}
 	if (answer)
 		goto out_permanent;
 
-	/* Add to the BEGINNING so that we override any existing
-	 * entry.  This means that when we remove this entry, the
+	/* Add the new entry after the last permanent entry if any, so that
+	 * the new entry does not override a permanent entry when matched with
+	 * a wild-card protocol. But it is allowed to override any existing
+	 * non-permanent entry.  This means that when we remove this entry, the 
 	 * system automatically returns to the old behavior.
 	 */
-	list_add(&p->list, &inetsw6[p->type]);
+	list_add(&p->list, last_perm);
 out:
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 	return;
