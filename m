From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 15:18:59 +0100
Message-ID: <20090323141858.6808.50788.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51105 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755555AbZCWOT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 10:19:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the NETLINK_NO_ENOBUFS socket flag. This flag can
be used by unicast and broadcast listeners to avoid receiving
ENOBUFS errors.

Generally speaking, ENOBUFS errors are useful to notify two things
to the listener:

a) You may increase the receiver buffer size via setsockopt().
b) You have lost messages, you may be out of sync.

In some cases, ignoring ENOBUFS errors can be useful. For example:

a) nfnetlink_queue: this subsystem does not have any sort of resync
method and you can decide to ignore ENOBUFS once you have set a
given buffer size.

b) ctnetlink: you can use this together with the socket flag
NETLINK_BROADCAST_SEND_ERROR to stop getting ENOBUFS errors as
you do not need to resync (packets whose event are not delivered
are drop to provide reliable logging and state-synchronization).

Moreover, the use of NETLINK_NO_ENOBUFS also reduces a "go up, go down"
effect in terms of performance which is due to the netlink congestion
control when the listener cannot back off. The effect is the following:

1) throughput rate goes up and netlink messages are inserted in the
receiver buffer.
2) Then, netlink buffer fills and overruns (set on nlk->state bit 0).
3) While the listener empties the receiver buffer, netlink keeps
dropping messages. Thus, throughput goes dramatically down.
4) Then, once the listener has emptied the buffer (nlk->state
bit 0 is set off), goto step 1.

This effect is easy to trigger with netlink broadcast under heavy
load, and it is more noticeable when using a big receiver buffer.
You can find some results in [1] that show this problem.

[1] http://1984.lsi.us.es/linux/netlink/

This patch also includes the use of sk_drop to account the number of
netlink messages drop due to overrun. This value is shown in
/proc/net/netlink.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   38 ++++++++++++++++++++++++++++++++------
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 1e6bf99..5ba398e 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -104,6 +104,7 @@ struct nlmsgerr
 #define NETLINK_DROP_MEMBERSHIP	2
 #define NETLINK_PKTINFO		3
 #define NETLINK_BROADCAST_ERROR	4
+#define NETLINK_NO_ENOBUFS	5
 
 struct nl_pktinfo
 {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index dc93836..f669a38 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -86,6 +86,7 @@ struct netlink_sock {
 #define NETLINK_KERNEL_SOCKET	0x1
 #define NETLINK_RECV_PKTINFO	0x2
 #define NETLINK_BROADCAST_SEND_ERROR	0x4
+#define NETLINK_RECV_NO_ENOBUFS	0x8
 
 static inline struct netlink_sock *nlk_sk(struct sock *sk)
 {
@@ -717,10 +718,15 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 
 static void netlink_overrun(struct sock *sk)
 {
-	if (!test_and_set_bit(0, &nlk_sk(sk)->state)) {
-		sk->sk_err = ENOBUFS;
-		sk->sk_error_report(sk);
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (!(nlk->flags & NETLINK_RECV_NO_ENOBUFS)) {
+		if (!test_and_set_bit(0, &nlk_sk(sk)->state)) {
+			sk->sk_err = ENOBUFS;
+			sk->sk_error_report(sk);
+		}
 	}
+	atomic_inc(&sk->sk_drops);
 }
 
 static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
@@ -1183,6 +1189,15 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			nlk->flags &= ~NETLINK_BROADCAST_SEND_ERROR;
 		err = 0;
 		break;
+	case NETLINK_NO_ENOBUFS:
+		if (val) {
+			nlk->flags |= NETLINK_RECV_NO_ENOBUFS;
+			clear_bit(0, &nlk->state);
+			wake_up_interruptible(&nlk->wait);
+		} else
+			nlk->flags &= ~NETLINK_RECV_NO_ENOBUFS;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -1225,6 +1240,16 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		err = 0;
 		break;
+	case NETLINK_NO_ENOBUFS:
+		if (len < sizeof(int))
+			return -EINVAL;
+		len = sizeof(int);
+		val = nlk->flags & NETLINK_RECV_NO_ENOBUFS ? 1 : 0;
+		if (put_user(len, optlen) ||
+		    put_user(val, optval))
+			return -EFAULT;
+		err = 0;
+		break;
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -1881,12 +1906,12 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
 			 "sk       Eth Pid    Groups   "
-			 "Rmem     Wmem     Dump     Locks\n");
+			 "Rmem     Wmem     Dump     Locks     Drops\n");
 	else {
 		struct sock *s = v;
 		struct netlink_sock *nlk = nlk_sk(s);
 
-		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %d\n",
+		seq_printf(seq, "%p %-3d %-6d %08x %-8d %-8d %p %-8d %-8d\n",
 			   s,
 			   s->sk_protocol,
 			   nlk->pid,
@@ -1894,7 +1919,8 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 			   atomic_read(&s->sk_rmem_alloc),
 			   atomic_read(&s->sk_wmem_alloc),
 			   nlk->cb,
-			   atomic_read(&s->sk_refcnt)
+			   atomic_read(&s->sk_refcnt),
+			   atomic_read(&s->sk_drops)
 			);
 
 	}

