From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: (no subject)
Date: Mon, 12 Apr 2004 16:23:42 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404121623.42558.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ehpeAQktxORaQ/f"
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_ehpeAQktxORaQ/f
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

According to my measurements,

ip_vs_control_add() (from include/net/ip_vs.h) is called twice
and
sock_queue_rcv_skb() (from=A0include/net/sock.h) is called 19 times
from various kernel .c files.

Both these includes generate more than 500 bytes of code on x86.

These patches uninline them. Please apply.
=2D-
vda

--Boundary-00=_ehpeAQktxORaQ/f
Content-Type: text/x-diff;
  charset="us-ascii";
  name="net_inline1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="net_inline1.patch"

diff -urN linux-2.6.5.orig/include/net/ip_vs.h linux-2.6.5.net_inline/include/net/ip_vs.h
--- linux-2.6.5.orig/include/net/ip_vs.h	Mon Apr 12 15:42:10 2004
+++ linux-2.6.5.net_inline/include/net/ip_vs.h	Mon Apr 12 15:46:43 2004
@@ -766,53 +766,8 @@
 extern void ip_vs_random_dropentry(void);
 extern int ip_vs_conn_init(void);
 extern void ip_vs_conn_cleanup(void);
-
-static inline void ip_vs_control_del(struct ip_vs_conn *cp)
-{
-	struct ip_vs_conn *ctl_cp = cp->control;
-	if (!ctl_cp) {
-		IP_VS_ERR("request control DEL for uncontrolled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
-		return;
-	}
-
-	IP_VS_DBG(7, "DELeting control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
-
-	cp->control = NULL;
-	if (atomic_read(&ctl_cp->n_control) == 0) {
-		IP_VS_ERR("BUG control DEL with n=0 : "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
-		return;
-	}
-	atomic_dec(&ctl_cp->n_control);
-}
-
-static inline void
-ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
-{
-	if (cp->control) {
-		IP_VS_ERR("request control ADD for already controlled: "
-			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
-			  NIPQUAD(cp->caddr),ntohs(cp->cport),
-			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
-		ip_vs_control_del(cp);
-	}
-
-	IP_VS_DBG(7, "ADDing control for: "
-		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
-		  NIPQUAD(cp->caddr),ntohs(cp->cport),
-		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
-
-	cp->control = ctl_cp;
-	atomic_inc(&ctl_cp->n_control);
-}
+extern void ip_vs_control_del(struct ip_vs_conn *cp);
+extern void ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp);
 
 
 /*
diff -urN linux-2.6.5.orig/net/ipv4/ipvs/ip_vs_core.c linux-2.6.5.net_inline/net/ipv4/ipvs/ip_vs_core.c
--- linux-2.6.5.orig/net/ipv4/ipvs/ip_vs_core.c	Sun Apr  4 06:36:13 2004
+++ linux-2.6.5.net_inline/net/ipv4/ipvs/ip_vs_core.c	Mon Apr 12 15:59:10 2004
@@ -199,6 +199,57 @@
 	return 1;
 }
 
+
+void
+ip_vs_control_del(struct ip_vs_conn *cp)
+{
+	struct ip_vs_conn *ctl_cp = cp->control;
+	if (!ctl_cp) {
+		IP_VS_ERR("request control DEL for uncontrolled: "
+			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			  NIPQUAD(cp->caddr),ntohs(cp->cport),
+			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		return;
+	}
+
+	IP_VS_DBG(7, "DELeting control for: "
+		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
+		  NIPQUAD(cp->caddr),ntohs(cp->cport),
+		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+
+	cp->control = NULL;
+	if (atomic_read(&ctl_cp->n_control) == 0) {
+		IP_VS_ERR("BUG control DEL with n=0 : "
+			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			  NIPQUAD(cp->caddr),ntohs(cp->cport),
+			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		return;
+	}
+	atomic_dec(&ctl_cp->n_control);
+}
+
+
+void
+ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
+{
+	if (cp->control) {
+		IP_VS_ERR("request control ADD for already controlled: "
+			  "%d.%d.%d.%d:%d to %d.%d.%d.%d:%d\n",
+			  NIPQUAD(cp->caddr),ntohs(cp->cport),
+			  NIPQUAD(cp->vaddr),ntohs(cp->vport));
+		ip_vs_control_del(cp);
+	}
+
+	IP_VS_DBG(7, "ADDing control for: "
+		  "cp.dst=%d.%d.%d.%d:%d ctl_cp.dst=%d.%d.%d.%d:%d\n",
+		  NIPQUAD(cp->caddr),ntohs(cp->cport),
+		  NIPQUAD(ctl_cp->caddr),ntohs(ctl_cp->cport));
+
+	cp->control = ctl_cp;
+	atomic_inc(&ctl_cp->n_control);
+}
+
+
 /*
  *  IPVS persistent scheduling function
  *  It creates a connection entry according to its template if exists,

--Boundary-00=_ehpeAQktxORaQ/f
Content-Type: text/x-diff;
  charset="us-ascii";
  name="net_inline2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="net_inline2.patch"

diff -urN linux-2.6.5.orig/include/net/sock.h linux-2.6.5.net_inline2/include/net/sock.h
--- linux-2.6.5.orig/include/net/sock.h	Sun Apr  4 06:37:37 2004
+++ linux-2.6.5.net_inline2/include/net/sock.h	Mon Apr 12 16:05:03 2004
@@ -898,45 +898,7 @@
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 }
 
-static inline int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
-{
-	int err = 0;
-	int skb_len;
-
-	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
-	   number of warnings when compiling with -W --ANK
-	 */
-	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
-	    (unsigned)sk->sk_rcvbuf) {
-		err = -ENOMEM;
-		goto out;
-	}
-
-	/* It would be deadlock, if sock_queue_rcv_skb is used
-	   with socket lock! We assume that users of this
-	   function are lock free.
-	*/
-	err = sk_filter(sk, skb, 1);
-	if (err)
-		goto out;
-
-	skb->dev = NULL;
-	skb_set_owner_r(skb, sk);
-
-	/* Cache the SKB length before we tack it onto the receive
-	 * queue.  Once it is added it no longer belongs to us and
-	 * may be freed by other threads of control pulling packets
-	 * from the queue.
-	 */
-	skb_len = skb->len;
-
-	skb_queue_tail(&sk->sk_receive_queue, skb);
-
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb_len);
-out:
-	return err;
-}
+int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
 static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 {
diff -urN linux-2.6.5.orig/net/core/sock.c linux-2.6.5.net_inline2/net/core/sock.c
--- linux-2.6.5.orig/net/core/sock.c	Sun Apr  4 06:37:37 2004
+++ linux-2.6.5.net_inline2/net/core/sock.c	Mon Apr 12 16:05:39 2004
@@ -1138,6 +1138,46 @@
 	atomic_set(&sk->sk_refcnt, 1);
 }
 
+int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int err = 0;
+	int skb_len;
+
+	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
+	   number of warnings when compiling with -W --ANK
+	 */
+	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
+	    (unsigned)sk->sk_rcvbuf) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	/* It would be deadlock, if sock_queue_rcv_skb is used
+	   with socket lock! We assume that users of this
+	   function are lock free.
+	*/
+	err = sk_filter(sk, skb, 1);
+	if (err)
+		goto out;
+
+	skb->dev = NULL;
+	skb_set_owner_r(skb, sk);
+
+	/* Cache the SKB length before we tack it onto the receive
+	 * queue.  Once it is added it no longer belongs to us and
+	 * may be freed by other threads of control pulling packets
+	 * from the queue.
+	 */
+	skb_len = skb->len;
+
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, skb_len);
+out:
+	return err;
+}
+
 void lock_sock(struct sock *sk)
 {
 	might_sleep();

--Boundary-00=_ehpeAQktxORaQ/f--
