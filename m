From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Fix locking of ax25 protocol function list.
Date: Tue, 11 Jul 2006 00:09:43 +0100
Message-ID: <20060710230943.GA8350@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:1420 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1422794AbWGJXJl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 19:09:41 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delivery of AX.25 frame to the layer 3 protocols happens in softirq context
so locking needs to be bh-proof.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/ax25/ax25_iface.c b/net/ax25/ax25_iface.c
index 77ba07c..07ac020 100644
--- a/net/ax25/ax25_iface.c
+++ b/net/ax25/ax25_iface.c
@@ -66,10 +66,10 @@ #endif
 	protocol->pid  = pid;
 	protocol->func = func;
 
-	write_lock(&protocol_list_lock);
+	write_lock_bh(&protocol_list_lock);
 	protocol->next = protocol_list;
 	protocol_list  = protocol;
-	write_unlock(&protocol_list_lock);
+	write_unlock_bh(&protocol_list_lock);
 
 	return 1;
 }
@@ -80,16 +80,16 @@ void ax25_protocol_release(unsigned int 
 {
 	struct protocol_struct *s, *protocol;
 
-	write_lock(&protocol_list_lock);
+	write_lock_bh(&protocol_list_lock);
 	protocol = protocol_list;
 	if (protocol == NULL) {
-		write_unlock(&protocol_list_lock);
+		write_unlock_bh(&protocol_list_lock);
 		return;
 	}
 
 	if (protocol->pid == pid) {
 		protocol_list = protocol->next;
-		write_unlock(&protocol_list_lock);
+		write_unlock_bh(&protocol_list_lock);
 		kfree(protocol);
 		return;
 	}
@@ -98,14 +98,14 @@ void ax25_protocol_release(unsigned int 
 		if (protocol->next->pid == pid) {
 			s = protocol->next;
 			protocol->next = protocol->next->next;
-			write_unlock(&protocol_list_lock);
+			write_unlock_bh(&protocol_list_lock);
 			kfree(s);
 			return;
 		}
 
 		protocol = protocol->next;
 	}
-	write_unlock(&protocol_list_lock);
+	write_unlock_bh(&protocol_list_lock);
 }
 
 EXPORT_SYMBOL(ax25_protocol_release);
@@ -266,13 +266,13 @@ int ax25_protocol_is_registered(unsigned
 	struct protocol_struct *protocol;
 	int res = 0;
 
-	read_lock(&protocol_list_lock);
+	read_lock_bh(&protocol_list_lock);
 	for (protocol = protocol_list; protocol != NULL; protocol = protocol->next)
 		if (protocol->pid == pid) {
 			res = 1;
 			break;
 		}
-	read_unlock(&protocol_list_lock);
+	read_unlock_bh(&protocol_list_lock);
 
 	return res;
 }
