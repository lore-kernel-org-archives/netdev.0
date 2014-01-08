From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: improve socket create/bind latency in some cases
Date: Wed,  8 Jan 2014 17:12:41 +0100
Message-ID: <1389197561-20419-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbaAHQMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 11:12:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most people acquire PF_PACKET sockets with a protocol argument in
the socket call, e.g. libpcap does so with htons(ETH_P_ALL) for
all its sockets. Most likely, at some point in time a subsequent
bind() call will follow, e.g. in libpcap with ...

  memset(&sll, 0, sizeof(sll));
  sll.sll_family          = AF_PACKET;
  sll.sll_ifindex         = ifindex;
  sll.sll_protocol        = htons(ETH_P_ALL);

... as arguments. What happens in the kernel is that already
in socket() syscall, we install a proto hook via register_prot_hook()
if our protocol argument is != 0. Yet, in bind() we're almost
doing the same work by doing a unregister_prot_hook() with an
expensive synchronize_net() call in case during socket() the proto
was != 0, plus follow-up register_prot_hook() with a bound device
to it this time, in order to limit traffic we get.

In the case when the protocol and user supplied device index (== 0)
does not change from socket() to bind(), we can spare us doing
the same work twice. Similarly for re-binding to the same device
and protocol. For these scenarios, we can decrease create/bind
latency from ~7447us (sock-bind-2 case) to ~89us (sock-bind-1 case)
with this patch.

Alternatively, for the first case, if people care, they should
simply create their sockets with proto == 0 argument and define
the protocol during bind() as this saves a call to synchronize_net()
as well (sock-bind-3 case).

In all other cases, we're tied to user space behaviour we must not
change, also since a bind() is not strictly required. Thus, we need
the synchronize_net() to make sure no asynchronous packet processing
paths still refer to the previous elements of po->prot_hook.

In case of mmap()ed sockets, the workflow that includes bind() is
socket() -> setsockopt(<ring>) -> bind(). In that case, a pair of
{__unregister, register}_prot_hook is being called from setsockopt()
in order to install the new protocol receive handler. Thus, when
we call bind and can skip a re-hook, we have already previously
installed the new handler. For fanout, this is handled different
entirely, so we should be good.

Timings on an i7-3520M machine:

  * sock-bind-1:   89 us
  * sock-bind-2: 7447 us
  * sock-bind-3:   75 us

sock-bind-1:
  socket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP)) = 3
  bind(3, {sa_family=AF_PACKET, proto=htons(ETH_P_IP), if=all(0),
           pkttype=PACKET_HOST, addr(0)={0, }, 20) = 0

sock-bind-2:
  socket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP)) = 3
  bind(3, {sa_family=AF_PACKET, proto=htons(ETH_P_IP), if=lo(1),
           pkttype=PACKET_HOST, addr(0)={0, }, 20) = 0

sock-bind-3:
  socket(PF_PACKET, SOCK_RAW, 0) = 3
  bind(3, {sa_family=AF_PACKET, proto=htons(ETH_P_IP), if=lo(1),
           pkttype=PACKET_HOST, addr(0)={0, }, 20) = 0

While at it, also make it a bit more readable.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 279467b..a65f5b0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2567,9 +2567,12 @@ static int packet_release(struct socket *sock)
  *	Attach a packet hook.
  */
 
-static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protocol)
+static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 proto)
 {
 	struct packet_sock *po = pkt_sk(sk);
+	__be16 proto_curr = po->prot_hook.type;
+	const struct net_device *dev_curr = po->prot_hook.dev;
+	bool need_rehook = proto_curr != proto || dev_curr != dev;
 
 	if (po->fanout) {
 		if (dev)
@@ -2579,21 +2582,24 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 	}
 
 	lock_sock(sk);
-
 	spin_lock(&po->bind_lock);
-	unregister_prot_hook(sk, true);
 
-	po->num = protocol;
-	po->prot_hook.type = protocol;
-	if (po->prot_hook.dev)
-		dev_put(po->prot_hook.dev);
+	if (need_rehook) {
+		unregister_prot_hook(sk, true);
+
+		po->num = proto;
+		po->prot_hook.type = proto;
+
+		if (po->prot_hook.dev)
+			dev_put(po->prot_hook.dev);
 
-	po->prot_hook.dev = dev;
-	po->ifindex = dev ? dev->ifindex : 0;
+		po->prot_hook.dev = dev;
 
-	packet_cached_dev_assign(po, dev);
+		po->ifindex = dev ? dev->ifindex : 0;
+		packet_cached_dev_assign(po, dev);
+	}
 
-	if (protocol == 0)
+	if (proto == 0 || !need_rehook)
 		goto out_unlock;
 
 	if (!dev || (dev->flags & IFF_UP)) {
@@ -2693,22 +2699,22 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	err = -ENOBUFS;
 	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
-	if (sk == NULL)
+	if (unlikely(sk == NULL))
 		goto out;
 
 	sock->ops = &packet_ops;
-	if (sock->type == SOCK_PACKET)
+	if (unlikely(sock->type == SOCK_PACKET))
 		sock->ops = &packet_ops_spkt;
 
 	sock_init_data(sock, sk);
 
 	po = pkt_sk(sk);
-	sk->sk_family = PF_PACKET;
 	po->num = proto;
 	po->xmit = dev_queue_xmit;
 
 	packet_cached_dev_reset(po);
 
+	sk->sk_family = PF_PACKET;
 	sk->sk_destruct = packet_sock_destruct;
 	sk_refcnt_debug_inc(sk);
 
@@ -2718,9 +2724,9 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	spin_lock_init(&po->bind_lock);
 	mutex_init(&po->pg_vec_lock);
-	po->prot_hook.func = packet_rcv;
 
-	if (sock->type == SOCK_PACKET)
+	po->prot_hook.func = packet_rcv;
+	if (unlikely(sock->type == SOCK_PACKET))
 		po->prot_hook.func = packet_rcv_spkt;
 
 	po->prot_hook.af_packet_priv = sk;
-- 
1.8.3.1
