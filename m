From: James Chapman <jchapman@katalix.com>
Subject: [PATCH v2 04/12] l2tp: Add ppp device name to L2TP ppp session data
Date: Mon, 29 Mar 2010 10:57:01 +0100
Message-ID: <20100329095700.30460.31630.stgit@bert.katalix.com>
References: <20100329095639.30460.30496.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60432 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab0C2J4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 05:56:44 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 3CCA8A620A3
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 10:57:01 +0100 (BST)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2IoDciJasJoB for <netdev@vger.kernel.org>;
	Mon, 29 Mar 2010 10:57:01 +0100 (BST)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 1CCF0A62087
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 10:57:01 +0100 (BST)
In-Reply-To: <20100329095639.30460.30496.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dumping L2TP PPP sessions using /proc/net/l2tp, get
the assigned PPP device name from PPP using ppp_dev_name().

Signed-off-by: James Chapman <jchapman@katalix.com>
Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/l2tp/l2tp_ppp.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 03195ab..8f78c27 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -608,6 +608,20 @@ out:
 	return error;
 }
 
+#ifdef CONFIG_PROC_FS
+static void pppol2tp_show(struct seq_file *m, void *arg)
+{
+	struct l2tp_session *session = arg;
+	struct pppol2tp_session *ps = l2tp_session_priv(session);
+
+	if (ps) {
+		struct pppox_sock *po = pppox_sk(ps->sock);
+		if (po)
+			seq_printf(m, "   interface %s\n", ppp_dev_name(&po->chan));
+	}
+}
+#endif
+
 /* connect() handler. Attach a PPPoX socket to a tunnel UDP socket
  */
 static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
@@ -697,6 +711,9 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	session->recv_skb	= pppol2tp_recv;
 	session->session_close	= pppol2tp_session_close;
+#ifdef CONFIG_PROC_FS
+	session->show		= pppol2tp_show;
+#endif
 
 	/* We need to know each time a skb is dropped from the reorder
 	 * queue.

