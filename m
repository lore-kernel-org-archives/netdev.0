From: Patrick McHardy <kaber@trash.net>
Subject: libnl: nfqueue: add nfqueue specific socket allocation function
Date: Thu, 23 Oct 2008 13:47:08 +0200
Message-ID: <4900643C.6000501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010505060907020409080504"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48304 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbYJWLrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 07:47:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010505060907020409080504
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010505060907020409080504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit e92539843a0c7e5116254382626cce226bf2135e
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Oct 23 13:46:16 2008 +0200

    libnl: nfqueue: add nfqueue specific socket allocation function
    
    nfqueue users usually send verdict messages from the receive callback.
    When waiting for ACKs, the receive callback might be called again
    recursively until the stack blows up.
    
    Add a nfqueue specific socket allocation function that automatically
    disables ACKing for the socket.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/netlink/netfilter/queue.h b/include/netlink/netfilter/queue.h
index 491b361..664610d 100644
--- a/include/netlink/netfilter/queue.h
+++ b/include/netlink/netfilter/queue.h
@@ -31,6 +31,8 @@ enum nfnl_queue_copy_mode {
 };
 
 /* General */
+extern struct nl_sock *		nfnl_queue_socket_alloc(void);
+
 extern struct nfnl_queue *	nfnl_queue_alloc(void);
 
 extern void			nfnl_queue_get(struct nfnl_queue *);
diff --git a/lib/netfilter/queue.c b/lib/netfilter/queue.c
index 8d3c7ce..ff1de0e 100644
--- a/lib/netfilter/queue.c
+++ b/lib/netfilter/queue.c
@@ -24,6 +24,16 @@
 #include <netlink/netfilter/nfnl.h>
 #include <netlink/netfilter/queue.h>
 
+struct nl_sock *nfnl_queue_socket_alloc(void)
+{
+	struct nl_sock *nlsk;
+
+	nlsk = nl_socket_alloc();
+	if (nlsk)
+		nl_socket_disable_auto_ack(nlsk);
+	return nlsk;
+}
+
 static int send_queue_request(struct nl_sock *sk, struct nl_msg *msg)
 {
 	int err;
diff --git a/src/nf-queue.c b/src/nf-queue.c
index 4e17f70..0ed9e69 100644
--- a/src/nf-queue.c
+++ b/src/nf-queue.c
@@ -47,7 +47,10 @@ int main(int argc, char *argv[])
 	int err = 1;
 	int family;
 
-	nf_sock = nlt_alloc_socket();
+	nf_sock = nfnl_queue_socket_alloc();
+	if (nf_sock == NULL)
+		fatal(ENOBUFS, "Unable to allocate netlink socket");
+
 	nl_disable_sequence_check(nf_sock);
 	nl_socket_modify_cb(nf_sock, NL_CB_VALID, NL_CB_CUSTOM, event_input, NULL);
 

--------------010505060907020409080504--
