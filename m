From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] af_packet: Allow for > 8 byte hardware
	addresses.
Date: Sat, 10 Sep 2005 11:25:27 -0600
Message-ID: <m164t8ltrs.fsf_-_@ebiederm.dsl.xmission.com>
References: <1123786117.4403.5835.camel@hal.voltaire.com>
	<20050811.124916.77057824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050811.124916.77057824.davem@davemloft.net> (David S.
	Miller's message of "Thu, 11 Aug 2005 12:49:16 -0700 (PDT)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Does this approach look sound?

The convention it adopts is that longer addresses will simply extend
the hardeware address byte arrays at the end of sockaddr_ll and
packet_mreq.

In making this change a small information leak was also closed.
The code only initializes the hardware address bytes that are
used, but all of struct sockaddr_ll was copied to userspace.
Now we just copy sockaddr_ll to the last byte of the hardware
address used.  

Hopefully for the common case of ethernet returning a value that is 
2 bytes smaller than sockaddr_ll won't break anything.  Given that it
simplifies the code and removes an information leak I thought
the small chance of breakage was worth it.  If not this can
be easily fixed.

For error checking larger structures than our internal
maximums continue to be allowed but an error is signaled if we can
not fit the hardware address into our internal structure.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


---

 net/packet/af_packet.c |   64 +++++++++++++++++++++++++++++++++++-------------
 1 files changed, 47 insertions(+), 17 deletions(-)

39a41e0363bab6661f40f24b404416b99de0c15a
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -36,6 +36,11 @@
  *	Michal Ostrowski        :       Module initialization cleanup.
  *         Ulises Alonso        :       Frame number limit removal and 
  *                                      packet_set_ring memory leak.
+ *		Eric Biederman	:	Allow for > 8 byte hardware addresses.
+ *					The convention is that longer addresses
+ *					will simply extend the hardware address
+ *					byte arrays at the end of sockaddr_ll 
+ *					and packet_mreq.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -161,7 +166,17 @@ struct packet_mclist
 	int			count;
 	unsigned short		type;
 	unsigned short		alen;
-	unsigned char		addr[8];
+	unsigned char		addr[MAX_ADDR_LEN];
+};
+/* identical to struct packet_mreq except it has
+ * a longer address field.
+ */
+struct packet_mreq_max
+{
+	int		mr_ifindex;
+	unsigned short	mr_type;
+	unsigned short	mr_alen;
+	unsigned char	mr_address[MAX_ADDR_LEN];
 };
 #endif
 #ifdef CONFIG_PACKET_MMAP
@@ -716,6 +731,8 @@ static int packet_sendmsg(struct kiocb *
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
 			goto out;
+		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_ll, sll_addr)))
+			goto out;
 		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
@@ -744,6 +761,12 @@ static int packet_sendmsg(struct kiocb *
 	if (dev->hard_header) {
 		int res;
 		err = -EINVAL;
+		if (saddr) {
+			if (saddr->sll_halen != dev->addr_len)
+				goto out_free;
+			if (saddr->sll_hatype != dev->type)
+				goto out_free;
+		}
 		res = dev->hard_header(skb, dev, ntohs(proto), addr, NULL, len);
 		if (sock->type != SOCK_DGRAM) {
 			skb->tail = skb->data;
@@ -1045,6 +1068,7 @@ static int packet_recvmsg(struct kiocb *
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int copied, err;
+	struct sockaddr_ll *sll;
 
 	err = -EINVAL;
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
@@ -1057,16 +1081,6 @@ static int packet_recvmsg(struct kiocb *
 #endif
 
 	/*
-	 *	If the address length field is there to be filled in, we fill
-	 *	it in now.
-	 */
-
-	if (sock->type == SOCK_PACKET)
-		msg->msg_namelen = sizeof(struct sockaddr_pkt);
-	else
-		msg->msg_namelen = sizeof(struct sockaddr_ll);
-
-	/*
 	 *	Call the generic datagram receiver. This handles all sorts
 	 *	of horrible races and re-entrancy so we can forget about it
 	 *	in the protocol layers.
@@ -1087,6 +1101,17 @@ static int packet_recvmsg(struct kiocb *
 		goto out;
 
 	/*
+	 *	If the address length field is there to be filled in, we fill
+	 *	it in now.
+	 */
+
+	sll = (struct sockaddr_ll*)skb->cb;
+	if (sock->type == SOCK_PACKET)
+		msg->msg_namelen = sizeof(struct sockaddr_pkt);
+	else
+		msg->msg_namelen = sll->sll_halen + offsetof(struct sockaddr_ll, sll_addr);
+
+	/*
 	 *	You lose any data beyond the buffer you gave. If it worries a
 	 *	user program they can ask the device for its MTU anyway.
 	 */
@@ -1166,7 +1191,7 @@ static int packet_getname(struct socket 
 		sll->sll_hatype = 0;	/* Bad: we have no ARPHRD_UNSPEC */
 		sll->sll_halen = 0;
 	}
-	*uaddr_len = sizeof(*sll);
+	*uaddr_len = offsetof(struct sockaddr_ll, sll_addr) + sll->sll_halen;
 
 	return 0;
 }
@@ -1199,7 +1224,7 @@ static void packet_dev_mclist(struct net
 	}
 }
 
-static int packet_mc_add(struct sock *sk, struct packet_mreq *mreq)
+static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 {
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_mclist *ml, *i;
@@ -1249,7 +1274,7 @@ done:
 	return err;
 }
 
-static int packet_mc_drop(struct sock *sk, struct packet_mreq *mreq)
+static int packet_mc_drop(struct sock *sk, struct packet_mreq_max *mreq)
 {
 	struct packet_mclist *ml, **mlp;
 
@@ -1315,11 +1340,16 @@ packet_setsockopt(struct socket *sock, i
 	case PACKET_ADD_MEMBERSHIP:	
 	case PACKET_DROP_MEMBERSHIP:
 	{
-		struct packet_mreq mreq;
-		if (optlen<sizeof(mreq))
+		struct packet_mreq_max mreq;
+		int len = optlen;
+		if (len < sizeof(struct packet_mreq))
 			return -EINVAL;
-		if (copy_from_user(&mreq,optval,sizeof(mreq)))
+		if (len > sizeof(mreq))
+			len = sizeof(mreq);
+		if (copy_from_user(&mreq,optval,len))
 			return -EFAULT;
+		if (len < (mreq.mr_alen + offsetof(struct packet_mreq, mr_address)))
+			return -EINVAL;
 		if (optname == PACKET_ADD_MEMBERSHIP)
 			ret = packet_mc_add(sk, &mreq);
 		else
