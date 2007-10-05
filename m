From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/5] cleanup 3rd argument in netlink_sendskb
Date: Fri, 5 Oct 2007 18:46:23 +0400
Message-ID: <20071005144623.GA7085@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org,
	containers@lists.osdl.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:64663 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756307AbXJEOo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 10:44:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netlink_sendskb does not use third argument. Clean it and save a couple of
bytes.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

--- ./include/linux/netlink.h.nlk5	2007-08-26 19:30:37.000000000 +0400
+++ ./include/linux/netlink.h	2007-10-02 11:53:09.000000000 +0400
@@ -194,7 +194,7 @@ struct sock *netlink_getsockbyfilp(struc
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
 		long timeo, struct sock *ssk);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
-int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
+int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
--- ./ipc/mqueue.c.nlk5	2007-08-26 19:30:37.000000000 +0400
+++ ./ipc/mqueue.c	2007-10-02 11:52:27.000000000 +0400
@@ -521,8 +521,7 @@ static void __do_notify(struct mqueue_in
 			break;
 		case SIGEV_THREAD:
 			set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
-			netlink_sendskb(info->notify_sock,
-					info->notify_cookie, 0);
+			netlink_sendskb(info->notify_sock, info->notify_cookie);
 			break;
 		}
 		/* after notification unregisters process */
@@ -568,7 +567,7 @@ static void remove_notification(struct m
 	if (info->notify_owner != NULL &&
 	    info->notify.sigev_notify == SIGEV_THREAD) {
 		set_cookie(info->notify_cookie, NOTIFY_REMOVED);
-		netlink_sendskb(info->notify_sock, info->notify_cookie, 0);
+		netlink_sendskb(info->notify_sock, info->notify_cookie);
 	}
 	put_pid(info->notify_owner);
 	info->notify_owner = NULL;
--- ./net/netlink/af_netlink.c.nlk5	2007-10-02 11:43:09.000000000 +0400
+++ ./net/netlink/af_netlink.c	2007-10-02 11:50:19.000000000 +0400
@@ -796,7 +796,7 @@ int netlink_attachskb(struct sock *sk, s
 	return 0;
 }
 
-int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
+int netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 {
 	int len = skb->len;
 
@@ -858,7 +858,7 @@ retry:
 	if (err)
 		return err;
 
-	return netlink_sendskb(sk, skb, ssk->sk_protocol);
+	return netlink_sendskb(sk, skb);
 }
 
 int netlink_has_listeners(struct sock *sk, unsigned int group)
