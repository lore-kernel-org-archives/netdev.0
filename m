From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] packet: improve socket create/bind latency in some cases
Date: Sun, 12 Jan 2014 17:22:46 +0100
Message-ID: <1389543768-20234-2-git-send-email-dborkman@redhat.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbaALQWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 11:22:53 -0500
In-Reply-To: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
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

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - applied Dave's feedback to move assignments under bind lock
  - removed cleanup part

 net/packet/af_packet.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 279467b..85bb38c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2567,9 +2567,12 @@ static int packet_release(struct socket *sock)
  *	Attach a packet hook.
  */
 
-static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protocol)
+static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 proto)
 {
 	struct packet_sock *po = pkt_sk(sk);
+	const struct net_device *dev_curr;
+	__be16 proto_curr;
+	bool need_rehook;
 
 	if (po->fanout) {
 		if (dev)
@@ -2579,21 +2582,29 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 	}
 
 	lock_sock(sk);
-
 	spin_lock(&po->bind_lock);
-	unregister_prot_hook(sk, true);
 
-	po->num = protocol;
-	po->prot_hook.type = protocol;
-	if (po->prot_hook.dev)
-		dev_put(po->prot_hook.dev);
+	proto_curr = po->prot_hook.type;
+	dev_curr = po->prot_hook.dev;
+
+	need_rehook = proto_curr != proto || dev_curr != dev;
+
+	if (need_rehook) {
+		unregister_prot_hook(sk, true);
 
-	po->prot_hook.dev = dev;
-	po->ifindex = dev ? dev->ifindex : 0;
+		po->num = proto;
+		po->prot_hook.type = proto;
+
+		if (po->prot_hook.dev)
+			dev_put(po->prot_hook.dev);
 
-	packet_cached_dev_assign(po, dev);
+		po->prot_hook.dev = dev;
+
+		po->ifindex = dev ? dev->ifindex : 0;
+		packet_cached_dev_assign(po, dev);
+	}
 
-	if (protocol == 0)
+	if (proto == 0 || !need_rehook)
 		goto out_unlock;
 
 	if (!dev || (dev->flags & IFF_UP)) {
-- 
1.7.11.7
