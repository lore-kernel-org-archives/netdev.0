From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [PATCH] (resend) fix sock_raw behaviour
Date: Fri, 10 Oct 2003 13:21:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010132157.A4188@jeroen.pe1rxq.ampr.org>
References: <20031008235150.A207@jeroen.pe1rxq.ampr.org> <20031009235338.7335b635.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com, ralf@linux-mips.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S . Miller" <davem@redhat.com>
In-Reply-To: <20031009235338.7335b635.davem@redhat.com>; from davem@redhat.com on Fri, Oct 10, 2003 at 08:53:38 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

On 2003.10.10 08:53:38 +0200 David S. Miller wrote:
> On Wed, 8 Oct 2003 23:51:50 +0200
> Jeroen Vreeken <pe1rxq@amsat.org> wrote:
> 
> > This is a resend of a patch from some weeks ago that doesn't appear to
> have
> > made it in yet...
> 
> It doesn't apply, that's why.  You patch ax25.h twice the same
> exact way which causes the patch to not apply.

I seem to have pasted that part twice...
Attached is a corrected version
 
> While we're talking about this, who is going to maintain AX25
> in 2.6.x?  I don't want to be taking bug fixes and other changes
> to AX25 from random people, I'd like to have a single contact
> that will review the AX25 patches from other people and then
> forward them off to me.

The official maintainer for ax25 and netrom is Ralf Baechle. but he seems
to have some problems fitting it into his schedule....

Jeroen

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="sock-raw.diff"

--- linux-2.6.0-test5/net/ax25/af_ax25.c.org	2003-09-23 23:26:17.000000000 +0200
+++ linux-2.6.0-test5/net/ax25/af_ax25.c	2003-09-24 23:33:32.000000000 +0200
@@ -231,42 +231,29 @@
 /*
  *	Look for any matching address - RAW sockets can bind to arbitrary names
  */
-struct sock *ax25_addr_match(ax25_address *addr)
+void ax25_send_to_raw(ax25_address *addr, struct sk_buff *skb, int proto)
 {
-	struct sock *sk = NULL;
+	struct sock *sk;
 	ax25_cb *s;
+	struct sk_buff *copy;
 	struct hlist_node *node;
 
 	spin_lock_bh(&ax25_list_lock);
 	ax25_for_each(s, node, &ax25_list) {
 		if (s->sk != NULL && ax25cmp(&s->source_addr, addr) == 0 &&
-		    s->sk->sk_type == SOCK_RAW) {
+		    s->sk->sk_type == SOCK_RAW &&
+		    s->sk->sk_protocol == proto &&
+		    (!s->ax25_dev || s->ax25_dev->dev == skb->dev)) {
 			sk = s->sk;
-			lock_sock(sk);
-			break;
+			bh_lock_sock(sk);
+			if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
+			    (copy = skb_clone(skb, GFP_ATOMIC)) != NULL)
+				if (sock_queue_rcv_skb(sk, copy) != 0)
+					kfree_skb(copy);
+			bh_unlock_sock(sk);
 		}
 	}
-
 	spin_unlock_bh(&ax25_list_lock);
-
-	return sk;
-}
-
-void ax25_send_to_raw(struct sock *sk, struct sk_buff *skb, int proto)
-{
-	struct sk_buff *copy;
-	struct hlist_node *node;
-
-	sk_for_each_from(sk, node)
-		if (sk->sk_type == SOCK_RAW &&
-		    sk->sk_protocol == proto &&
-		    atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
-			if ((copy = skb_clone(skb, GFP_ATOMIC)) == NULL)
-				return;
-
-			if (sock_queue_rcv_skb(sk, copy) != 0)
-				kfree_skb(copy);
-		}
 }
 
 /*
@@ -1633,16 +1620,16 @@
 	if (msg->msg_namelen != 0) {
 		struct sockaddr_ax25 *sax = (struct sockaddr_ax25 *)msg->msg_name;
 		ax25_digi digi;
-		ax25_address dest;
+		ax25_address src;
 
-		ax25_addr_parse(skb->mac.raw+1, skb->data-skb->mac.raw-1, NULL, &dest, &digi, NULL, NULL);
+		ax25_addr_parse(skb->mac.raw+1, skb->data-skb->mac.raw-1, &src, NULL, &digi, NULL, NULL);
 
 		sax->sax25_family = AF_AX25;
 		/* We set this correctly, even though we may not let the
 		   application know the digi calls further down (because it
 		   did NOT ask to know them).  This could get political... **/
 		sax->sax25_ndigis = digi.ndigi;
-		sax->sax25_call   = dest;
+		sax->sax25_call   = src;
 
 		if (sax->sax25_ndigis != 0) {
 			int ct;
--- linux-2.6.0-test5/include/net/ax25.h.org	2003-09-24 23:21:27.000000000 +0200
+++ linux-2.6.0-test5/include/net/ax25.h	2003-09-24 23:21:55.000000000 +0200
@@ -227,8 +227,7 @@
 struct sock *ax25_find_listener(ax25_address *, int, struct net_device *, int);
 struct sock *ax25_get_socket(ax25_address *, ax25_address *, int);
 extern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *, struct net_device *);
-extern struct sock *ax25_addr_match(ax25_address *);
-extern void ax25_send_to_raw(struct sock *, struct sk_buff *, int);
+extern void ax25_send_to_raw(ax25_address *, struct sk_buff *, int);
 extern void ax25_destroy_socket(ax25_cb *);
 extern ax25_cb *ax25_create_cb(void);
 extern void ax25_fillin_cb(ax25_cb *, ax25_dev *);

--AWniW0JNca5xppdA--
