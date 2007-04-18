From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 4/7] [IrDA] af_irda: IRDA_ASSERT cleanups
Date: Thu, 19 Apr 2007 00:32:06 +0300
Message-ID: <20070418214751.145259810@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0005-IrDA-net-2.6.22-af_irda-IRDA_ASSERT-cleanups.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

In af_irda.c, the multiple IRDA_ASSERT() are either hiding bugs, useless, or
returning the wrong value.
Let's clean that up.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/af_irda.c |   32 +++++---------------------------
 1 files changed, 5 insertions(+), 27 deletions(-)

Index: net-2.6.22-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
+++ net-2.6.22-quilt/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
@@ -89,7 +89,6 @@
 
 	self = instance;
 	sk = instance;
-	IRDA_ASSERT(sk != NULL, return -1;);
 
 	err = sock_queue_rcv_skb(sk, skb);
 	if (err) {
@@ -306,8 +305,6 @@
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
-	IRDA_ASSERT(self != NULL, return;);
-
 	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
 			GFP_ATOMIC);
 	if (skb == NULL) {
@@ -337,7 +334,7 @@
 
 	self = instance;
 	sk = instance;
-	IRDA_ASSERT(sk != NULL, return;);
+	BUG_ON(sk == NULL);
 
 	switch (flow) {
 	case FLOW_STOP:
@@ -449,7 +446,7 @@
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
 	self = (struct irda_sock *) priv;
-	IRDA_ASSERT(self != NULL, return;);
+	BUG_ON(self == NULL);
 
 	/* Nothing for the caller */
 	self->cachelog = NULL;
@@ -546,8 +543,6 @@
 {
 	IRDA_DEBUG(2, "%s(%p, %s)\n", __FUNCTION__, self, name);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	if (self->iriap) {
 		IRDA_WARNING("%s(): busy with a previous query\n",
 			     __FUNCTION__);
@@ -635,8 +630,6 @@
 
 	IRDA_DEBUG(2, "%s(), name=%s\n", __FUNCTION__, name);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	/* Ask lmp for the current discovery log
 	 * Note : we have to use irlmp_get_discoveries(), as opposed
 	 * to play with the cachelog directly, because while we are
@@ -784,8 +777,6 @@
 	struct irda_sock *self = irda_sk(sk);
 	int err;
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
 	if (addr_len != sizeof(struct sockaddr_irda))
@@ -841,8 +832,6 @@
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	err = irda_create(newsock, sk->sk_protocol);
 	if (err)
 		return err;
@@ -889,10 +878,12 @@
 	}
 
 	newsk = newsock->sk;
+	if (newsk == NULL)
+		return -EIO;
+
 	newsk->sk_state = TCP_ESTABLISHED;
 
 	new = irda_sk(newsk);
-	IRDA_ASSERT(new != NULL, return -1;);
 
 	/* Now attach up the new socket */
 	new->tsap = irttp_dup(self->tsap, new);
@@ -1154,8 +1145,6 @@
 {
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
-	IRDA_ASSERT(self != NULL, return;);
-
 	/* Unregister with IrLMP */
 	irlmp_unregister_client(self->ckey);
 	irlmp_unregister_service(self->skey);
@@ -1274,7 +1263,6 @@
 		return -ENOTCONN;
 
 	self = irda_sk(sk);
-	IRDA_ASSERT(self != NULL, return -1;);
 
 	/* Check if IrTTP is wants us to slow down */
 
@@ -1337,8 +1325,6 @@
 
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	if ((err = sock_error(sk)) < 0)
 		return err;
 
@@ -1392,8 +1378,6 @@
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	if ((err = sock_error(sk)) < 0)
 		return err;
 
@@ -1527,7 +1511,6 @@
 		return -ENOTCONN;
 
 	self = irda_sk(sk);
-	IRDA_ASSERT(self != NULL, return -1;);
 
 	/*
 	 * Check that we don't send out too big frames. This is an unreliable
@@ -1596,7 +1579,6 @@
 	}
 
 	self = irda_sk(sk);
-	IRDA_ASSERT(self != NULL, return -1;);
 
 	/* Check if an address was specified with sendto. Jean II */
 	if (msg->msg_name) {
@@ -1670,8 +1652,6 @@
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	IRDA_DEBUG(1, "%s(%p)\n", __FUNCTION__, self);
 
 	sk->sk_state       = TCP_CLOSE;
@@ -1844,8 +1824,6 @@
 	struct ias_attrib *	ias_attr;	/* Attribute in IAS object */
 	int opt;
 
-	IRDA_ASSERT(self != NULL, return -1;);
-
 	IRDA_DEBUG(2, "%s(%p)\n", __FUNCTION__, self);
 
 	if (level != SOL_IRLMP)

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
