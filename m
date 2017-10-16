From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv4: mark expected switch fall-throughs
Date: Mon, 16 Oct 2017 15:48:55 -0500
Message-ID: <20171016204855.GA7470@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in some cases I placed the "fall through" comment
on its own line, which is what GCC is expecting to find.

Addresses-Coverity-ID: 115108
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/ipv4/af_inet.c                       | 3 ++-
 net/ipv4/arp.c                           | 1 +
 net/ipv4/devinet.c                       | 1 +
 net/ipv4/ipmr.c                          | 1 +
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 3 ++-
 net/ipv4/tcp_input.c                     | 2 ++
 net/ipv4/tcp_ipv4.c                      | 3 ++-
 7 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 43a1bbe..ce4aa82 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -827,6 +827,7 @@ int inet_shutdown(struct socket *sock, int how)
 		err = -ENOTCONN;
 		/* Hack to wake up other listeners, who can poll for
 		   POLLHUP, even on eg. unconnected UDP sockets -- RR */
+		/* fall through */
 	default:
 		sk->sk_shutdown |= how;
 		if (sk->sk_prot->shutdown)
@@ -840,7 +841,7 @@ int inet_shutdown(struct socket *sock, int how)
 	case TCP_LISTEN:
 		if (!(how & RCV_SHUTDOWN))
 			break;
-		/* Fall through */
+		/* fall through */
 	case TCP_SYN_SENT:
 		err = sk->sk_prot->disconnect(sk, O_NONBLOCK);
 		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7c45b88..a8d7c5a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1180,6 +1180,7 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCSARP:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
+		/* fall through */
 	case SIOCGARP:
 		err = copy_from_user(&r, arg, sizeof(struct arpreq));
 		if (err)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7ce22a2..d1aee7a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1522,6 +1522,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		if (inetdev_valid_mtu(dev->mtu))
 			break;
 		/* disable IP when MTU is not enough */
+		/* fall through */
 	case NETDEV_UNREGISTER:
 		inetdev_destroy(in_dev);
 		break;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b3ee01b..40a43ad 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1528,6 +1528,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
 		parent = -1;
+		/* fall through */
 	case MRT_ADD_MFC_PROXY:
 	case MRT_DEL_MFC_PROXY:
 		if (optlen != sizeof(mfc)) {
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index a0f37b2..0443ca4 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -276,7 +276,8 @@ nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 			else
 				return NF_ACCEPT;
 		}
-		/* Fall thru... (Only ICMPs can be IP_CT_IS_REPLY) */
+		/* Only ICMPs can be IP_CT_IS_REPLY: */
+		/* fall through */
 	case IP_CT_NEW:
 		/* Seen it before?  This can happen for loopback, retrans,
 		 * or local packets.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d0682ce..b2390bf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2885,6 +2885,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		      (*ack_flag & FLAG_LOST_RETRANS)))
 			return;
 		/* Change state if cwnd is undone or retransmits are lost */
+		/* fall through */
 	default:
 		if (tcp_is_reno(tp)) {
 			if (flag & FLAG_SND_UNA_ADVANCED)
@@ -6044,6 +6045,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 	case TCP_LAST_ACK:
 		if (!before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
 			break;
+		/* fall through */
 	case TCP_FIN_WAIT1:
 	case TCP_FIN_WAIT2:
 		/* RFC 793 says to queue data in these states,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5418ecf..ecee4dd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1779,8 +1779,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 			refcounted = false;
 			goto process;
 		}
-		/* Fall through to ACK */
 	}
+		/* to ACK */
+		/* fall through */
 	case TCP_TW_ACK:
 		tcp_v4_timewait_ack(sk, skb);
 		break;
-- 
2.7.4
