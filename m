From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/3] [TCP] Create tcpdiag_dump_sock
Date: Fri, 15 Oct 2004 07:30:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014213030.GA18433@gondor.apana.org.au>
References: <4164F60C.6080807@cosmosbay.com> <E1CFTUz-0007V6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <E1CFTUz-0007V6-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 07, 2004 at 06:19:41PM +1000, Herbert Xu wrote:
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> >
> > Of course, /proc/net/tcp on such machine is not an option (never 
> > completes), so I cant list all connections for this machine. I really 
> > *need* a working ss command.
> > 
> > Are they known problems ?
> 
> They are known now :) I'm working on a fix to these problems so
> stay tuned.

OK, this series of patches should solve your problems.

The first one move tcpdiag_bc_run calls into one place so that we can
change its parameters next.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p1

===== net/ipv4/tcp_diag.c 1.19 vs 1.20 =====
--- 1.19/net/ipv4/tcp_diag.c	2004-10-06 15:01:14 +10:00
+++ 1.20/net/ipv4/tcp_diag.c	2004-10-14 21:11:20 +10:00
@@ -466,16 +466,26 @@
 	return len == 0 ? 0 : -EINVAL;
 }
 
+static int tcpdiag_dump_sock(struct sk_buff *skb, struct sock *sk,
+			     struct netlink_callback *cb)
+{
+	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
+
+	if (cb->nlh->nlmsg_len > 4 + NLMSG_SPACE(sizeof(*r))) {
+		struct rtattr *bc = (struct rtattr *)(r + 1);
+		if (!tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
+			return 0;
+	}
+
+	return tcpdiag_fill(skb, sk, r->tcpdiag_ext, NETLINK_CB(cb->skb).pid,
+			    cb->nlh->nlmsg_seq);
+}
 
 static int tcpdiag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int i, num;
 	int s_i, s_num;
 	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
-	struct rtattr *bc = NULL;
-
-	if (cb->nlh->nlmsg_len > 4+NLMSG_SPACE(sizeof(struct tcpdiagreq)))
-		bc = (struct rtattr*)(r+1);
 
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
@@ -502,11 +512,7 @@
 				if (r->id.tcpdiag_sport != inet->sport &&
 				    r->id.tcpdiag_sport)
 					goto next_listen;
-				if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-					goto next_listen;
-				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
-						 NETLINK_CB(cb->skb).pid,
-						 cb->nlh->nlmsg_seq) <= 0) {
+				if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
 					tcp_listen_unlock();
 					goto done;
 				}
@@ -546,11 +552,7 @@
 				goto next_normal;
 			if (r->id.tcpdiag_dport != inet->dport && r->id.tcpdiag_dport)
 				goto next_normal;
-			if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-				goto next_normal;
-			if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
-					 NETLINK_CB(cb->skb).pid,
-					 cb->nlh->nlmsg_seq) <= 0) {
+			if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
 				read_unlock_bh(&head->lock);
 				goto done;
 			}
@@ -571,11 +573,7 @@
 				if (r->id.tcpdiag_dport != inet->dport &&
 				    r->id.tcpdiag_dport)
 					goto next_dying;
-				if (bc && !tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
-					goto next_dying;
-				if (tcpdiag_fill(skb, sk, r->tcpdiag_ext,
-						 NETLINK_CB(cb->skb).pid,
-						 cb->nlh->nlmsg_seq) <= 0) {
+				if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
 					read_unlock_bh(&head->lock);
 					goto done;
 				}

--xHFwDpU9dbj6ez1V--
