From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/3] [TCP] Dump SYN_RECV sockets in tcpdiag
Date: Fri, 15 Oct 2004 07:35:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014213517.GC18433@gondor.apana.org.au>
References: <4164F60C.6080807@cosmosbay.com> <E1CFTUz-0007V6-00@gondolin.me.apana.org.au> <20041014213030.GA18433@gondor.apana.org.au> <20041014213347.GB18433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+nBD6E3TurpgldQp"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <20041014213347.GB18433@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Finally this patch adds the code to list SYN_RECV sockets.  A future
enhancement would be to do this for the GET operation as well.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p3

===== net/ipv4/tcp_diag.c 1.21 vs edited =====
--- 1.21/net/ipv4/tcp_diag.c	2004-10-14 21:15:04 +10:00
+++ edited/net/ipv4/tcp_diag.c	2004-10-14 23:09:14 +10:00
@@ -18,6 +18,7 @@
 #include <linux/random.h>
 #include <linux/cache.h>
 #include <linux/init.h>
+#include <linux/time.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -499,6 +500,141 @@
 			    cb->nlh->nlmsg_seq);
 }
 
+static int tcpdiag_fill_req(struct sk_buff *skb, struct sock *sk,
+			    struct open_request *req,
+			    u32 pid, u32 seq)
+{
+	struct inet_opt *inet = inet_sk(sk);
+	unsigned char *b = skb->tail;
+	struct tcpdiagmsg *r;
+	struct nlmsghdr *nlh;
+	long tmo;
+
+	nlh = NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
+	r = NLMSG_DATA(nlh);
+
+	r->tcpdiag_family = sk->sk_family;
+	r->tcpdiag_state = TCP_SYN_RECV;
+	r->tcpdiag_timer = 1;
+	r->tcpdiag_retrans = req->retrans;
+
+	r->id.tcpdiag_if = sk->sk_bound_dev_if;
+	r->id.tcpdiag_cookie[0] = (u32)(unsigned long)req;
+	r->id.tcpdiag_cookie[1] = (u32)(((unsigned long)req >> 31) >> 1);
+
+	tmo = req->expires - jiffies;
+	if (tmo < 0)
+		tmo = 0;
+
+	r->id.tcpdiag_sport = inet->sport;
+	r->id.tcpdiag_dport = req->rmt_port;
+	r->id.tcpdiag_src[0] = req->af.v4_req.loc_addr;
+	r->id.tcpdiag_dst[0] = req->af.v4_req.rmt_addr;
+	r->tcpdiag_expires = jiffies_to_msecs(tmo),
+	r->tcpdiag_rqueue = 0;
+	r->tcpdiag_wqueue = 0;
+	r->tcpdiag_uid = sock_i_uid(sk);
+	r->tcpdiag_inode = 0;
+#ifdef CONFIG_IPV6
+	if (r->tcpdiag_family == AF_INET6) {
+		ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_src,
+			       &req->af.v6_req.loc_addr);
+		ipv6_addr_copy((struct in6_addr *)r->id.tcpdiag_dst,
+			       &req->af.v6_req.rmt_addr);
+	}
+#endif
+	nlh->nlmsg_len = skb->tail - b;
+
+	return skb->len;
+
+nlmsg_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int tcpdiag_dump_reqs(struct sk_buff *skb, struct sock *sk,
+			     struct netlink_callback *cb)
+{
+	struct tcpdiag_entry entry;
+	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
+	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_listen_opt *lopt;
+	struct rtattr *bc = NULL;
+	struct inet_opt *inet = inet_sk(sk);
+	int j, s_j;
+	int reqnum, s_reqnum;
+	int err = 0;
+
+	s_j = cb->args[3];
+	s_reqnum = cb->args[4];
+
+	if (s_j > 0)
+		s_j--;
+
+	entry.family = sk->sk_family;
+
+	read_lock_bh(&tp->syn_wait_lock);
+
+	lopt = tp->listen_opt;
+	if (!lopt || !lopt->qlen)
+		goto out;
+
+	if (cb->nlh->nlmsg_len > 4 + NLMSG_SPACE(sizeof(*r))) {
+		bc = (struct rtattr *)(r + 1);
+		entry.sport = inet->num;
+		entry.userlocks = sk->sk_userlocks;
+	}
+
+	for (j = s_j; j < TCP_SYNQ_HSIZE; j++) {
+		struct open_request *req, *head = lopt->syn_table[j];
+
+		reqnum = 0;
+		for (req = head; req; reqnum++, req = req->dl_next) {
+			if (reqnum < s_reqnum)
+				continue;
+			if (r->id.tcpdiag_dport != req->rmt_port &&
+			    r->id.tcpdiag_dport)
+				continue;
+
+			if (bc) {
+				entry.saddr =
+#ifdef CONFIG_IPV6
+					(entry.family == AF_INET6) ?
+					req->af.v6_req.loc_addr.s6_addr32 :
+#endif
+					&req->af.v4_req.loc_addr;
+				entry.daddr = 
+#ifdef CONFIG_IPV6
+					(entry.family == AF_INET6) ?
+					req->af.v6_req.rmt_addr.s6_addr32 :
+#endif
+					&req->af.v4_req.rmt_addr;
+				entry.dport = ntohs(req->rmt_port);
+
+				if (!tcpdiag_bc_run(RTA_DATA(bc),
+						    RTA_PAYLOAD(bc), &entry))
+					continue;
+			}
+
+			err = tcpdiag_fill_req(skb, sk, req,
+					       NETLINK_CB(cb->skb).pid,
+					       cb->nlh->nlmsg_seq);
+			if (err < 0) {
+				cb->args[3] = j + 1;
+				cb->args[4] = reqnum;
+				goto out;
+			}
+		}
+
+		s_reqnum = 0;
+	}
+
+out:
+	read_unlock_bh(&tp->syn_wait_lock);
+
+	return err;
+}
+
 static int tcpdiag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int i, num;
@@ -516,27 +652,47 @@
 			struct sock *sk;
 			struct hlist_node *node;
 
-			if (i > s_i)
-				s_num = 0;
-
 			num = 0;
 			sk_for_each(sk, node, &tcp_listening_hash[i]) {
 				struct inet_opt *inet = inet_sk(sk);
-				if (num < s_num)
-					goto next_listen;
-				if (!(r->tcpdiag_states&TCPF_LISTEN) ||
-				    r->id.tcpdiag_dport)
-					goto next_listen;
+
+				if (num < s_num) {
+					num++;
+					continue;
+				}
+
 				if (r->id.tcpdiag_sport != inet->sport &&
 				    r->id.tcpdiag_sport)
 					goto next_listen;
+
+				if (!(r->tcpdiag_states&TCPF_LISTEN) ||
+				    r->id.tcpdiag_dport ||
+				    cb->args[3] > 0)
+					goto syn_recv;
+
 				if (tcpdiag_dump_sock(skb, sk, cb) < 0) {
 					tcp_listen_unlock();
 					goto done;
 				}
+
+syn_recv:
+				if (!(r->tcpdiag_states&TCPF_SYN_RECV))
+					goto next_listen;
+
+				if (tcpdiag_dump_reqs(skb, sk, cb) < 0) {
+					tcp_listen_unlock();
+					goto done;
+				}
+
 next_listen:
+				cb->args[3] = 0;
+				cb->args[4] = 0;
 				++num;
 			}
+
+			s_num = 0;
+			cb->args[3] = 0;
+			cb->args[4] = 0;
 		}
 		tcp_listen_unlock();
 skip_listen_ht:

--+nBD6E3TurpgldQp--
