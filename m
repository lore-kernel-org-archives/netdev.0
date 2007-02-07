From: ahendry <ahendry@tusc.com.au>
Subject: [PATCH 2/3] X.25: Adds /proc/sys/net/x25/x25_forward to control
	forwarding.
Date: Thu, 08 Feb 2007 10:14:31 +1100
Message-ID: <1170890071.5189.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux-x25@vger.kernel.org, eis@baty.hanse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ricci.tusc.com.au ([203.2.177.24]:14070 "EHLO ricci.tusc.com.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161481AbXBGXOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 18:14:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

echo "1" > /proc/sys/net/x25/x25_forward 
To turn on x25_forwarding, defaults to off
Requires the previous patch.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>


diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla/include/linux/sysctl.h linux-2.6.20/include/linux/sysctl.h
--- linux-2.6.20-vanilla/include/linux/sysctl.h	2007-02-07 14:28:13.000000000 +1100
+++ linux-2.6.20/include/linux/sysctl.h	2007-02-07 15:01:20.000000000 +1100
@@ -699,7 +699,8 @@ enum {
 	NET_X25_CALL_REQUEST_TIMEOUT=2,
 	NET_X25_RESET_REQUEST_TIMEOUT=3,
 	NET_X25_CLEAR_REQUEST_TIMEOUT=4,
-	NET_X25_ACK_HOLD_BACK_TIMEOUT=5
+	NET_X25_ACK_HOLD_BACK_TIMEOUT=5,
+	NET_X25_FORWARD=6
 };
 
 /* /proc/sys/net/token-ring */
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla/include/net/x25.h linux-2.6.20/include/net/x25.h
--- linux-2.6.20-vanilla/include/net/x25.h	2007-02-07 14:28:14.000000000 +1100
+++ linux-2.6.20/include/net/x25.h	2007-02-07 15:02:06.000000000 +1100
@@ -180,6 +180,7 @@ extern int  sysctl_x25_call_request_time
 extern int  sysctl_x25_reset_request_timeout;
 extern int  sysctl_x25_clear_request_timeout;
 extern int  sysctl_x25_ack_holdback_timeout;
+extern int  sysctl_x25_forward;
 
 extern int  x25_addr_ntoa(unsigned char *, struct x25_address *,
 			  struct x25_address *);
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla/net/x25/af_x25.c linux-2.6.20/net/x25/af_x25.c
--- linux-2.6.20-vanilla/net/x25/af_x25.c	2007-02-07 14:29:43.000000000 +1100
+++ linux-2.6.20/net/x25/af_x25.c	2007-02-07 15:03:27.000000000 +1100
@@ -63,6 +63,7 @@ int sysctl_x25_call_request_timeout    =
 int sysctl_x25_reset_request_timeout   = X25_DEFAULT_T22;
 int sysctl_x25_clear_request_timeout   = X25_DEFAULT_T23;
 int sysctl_x25_ack_holdback_timeout    = X25_DEFAULT_T2;
+int sysctl_x25_forward                 = 0;
 
 HLIST_HEAD(x25_list);
 DEFINE_RWLOCK(x25_list_lock);
@@ -884,7 +885,8 @@ int x25_rx_call_request(struct sk_buff *
 	 */
 	if (sk == NULL) {
 		skb_push(skb, addr_len + X25_STD_MIN_LEN);
-		if (x25_forward_call(&dest_addr, nb, skb, lci) > 0)
+		if (sysctl_x25_forward &&
+				x25_forward_call(&dest_addr, nb, skb, lci) > 0)
 		{
 			/* Call was forwarded, dont process it any more */
 			kfree_skb(skb);
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla/net/x25/sysctl_net_x25.c linux-2.6.20/net/x25/sysctl_net_x25.c
--- linux-2.6.20-vanilla/net/x25/sysctl_net_x25.c	2007-02-07 14:29:43.000000000 +1100
+++ linux-2.6.20/net/x25/sysctl_net_x25.c	2007-02-07 15:03:58.000000000 +1100
@@ -73,6 +73,14 @@ static struct ctl_table x25_table[] = {
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
+	{
+		.ctl_name =	NET_X25_FORWARD,
+		.procname =	"x25_forward",
+		.data = 	&sysctl_x25_forward,
+		.maxlen = 	sizeof(int),
+		.mode = 	0644,
+		.proc_handler = &proc_dointvec,
+	},
 	{ 0, },
 };
 

