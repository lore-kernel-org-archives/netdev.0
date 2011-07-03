From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] netfilter: nfqueue: batch verdict support
Date: Sun, 03 Jul 2011 12:24:15 +0200
Message-ID: <1309688655.2523.16.camel@edumazet-laptop>
References: <1307657659-30266-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>
To: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44871 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296Ab1GCKYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 06:24:23 -0400
In-Reply-To: <1307657659-30266-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 00:14 +0200, Florian Westphal a =C3=A9c=
rit :
> Introduces a new nfnetlink type that applies a given
> verdict to all queued packets with an id <=3D the id in the verdict
> message.
>=20
> If a mark is provided it is applied to all matched packets.
>=20
> This reduces the number of verdicts that have to be sent.
> Applications that make use of this feature need to maintain
> a timeout to send a batchverdict periodically to avoid starvation.
>=20
> Signed-off-by: Florian Westphal <fw@strlen.de>

The real question hidden here is : "Should packet ids be monotonic" in
current implementation and all future ones ?

Before we accept this patch, we should make sure packets id are
monotonic, and I am afraid its not the case right now.

I suggest following patch then.

[PATCH] netfilter: nfqueue: assert monotonic packet ids

Packet identifier is currently setup in nfqnl_build_packet_message(),
using one atomic_inc_return().

Problem is that since several cpus might concurrently call
nfqnl_enqueue_packet() for the same queue, we can deliver packets to
consumer in non monotonic way (packet N+1 being delivered after packet
N)

This patch moves the packet id setup from nfqnl_build_packet_message()
to nfqnl_enqueue_packet() to guarantee correct delivery order.

This also removes one atomic operation.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Florian Westphal <fw@strlen.de>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
CC: Eric Leblond <eric@regit.org>
---
 net/netfilter/nfnetlink_queue.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_=
queue.c
index fdd2faf..bccaf3b 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -58,7 +58,7 @@ struct nfqnl_instance {
  */
 	spinlock_t	lock;
 	unsigned int	queue_total;
-	atomic_t	id_sequence;		/* 'sequence' of pkt ids */
+	unsigned int	id_sequence;		/* 'sequence' of pkt ids */
 	struct list_head queue_list;		/* packets in queue */
 };
=20
@@ -213,13 +213,15 @@ nfqnl_flush(struct nfqnl_instance *queue, nfqnl_c=
mpfn cmpfn, unsigned long data)
=20
 static struct sk_buff *
 nfqnl_build_packet_message(struct nfqnl_instance *queue,
-			   struct nf_queue_entry *entry)
+			   struct nf_queue_entry *entry,
+			   __be32 **packet_id_ptr)
 {
 	sk_buff_data_t old_tail;
 	size_t size;
 	size_t data_len =3D 0;
 	struct sk_buff *skb;
-	struct nfqnl_msg_packet_hdr pmsg;
+	struct nlattr *nla;
+	struct nfqnl_msg_packet_hdr *pmsg;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct sk_buff *entskb =3D entry->skb;
@@ -272,12 +274,11 @@ nfqnl_build_packet_message(struct nfqnl_instance =
*queue,
 	nfmsg->version =3D NFNETLINK_V0;
 	nfmsg->res_id =3D htons(queue->queue_num);
=20
-	entry->id =3D atomic_inc_return(&queue->id_sequence);
-	pmsg.packet_id 		=3D htonl(entry->id);
-	pmsg.hw_protocol	=3D entskb->protocol;
-	pmsg.hook		=3D entry->hook;
-
-	NLA_PUT(skb, NFQA_PACKET_HDR, sizeof(pmsg), &pmsg);
+	nla =3D __nla_reserve(skb, NFQA_PACKET_HDR, sizeof(*pmsg));
+	pmsg =3D nla_data(nla);
+	pmsg->hw_protocol	=3D entskb->protocol;
+	pmsg->hook		=3D entry->hook;
+	*packet_id_ptr		=3D &pmsg->packet_id;
=20
 	indev =3D entry->indev;
 	if (indev) {
@@ -389,6 +390,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, =
unsigned int queuenum)
 	struct sk_buff *nskb;
 	struct nfqnl_instance *queue;
 	int err =3D -ENOBUFS;
+	__be32 *packet_id_ptr;
=20
 	/* rcu_read_lock()ed by nf_hook_slow() */
 	queue =3D instance_lookup(queuenum);
@@ -402,7 +404,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, =
unsigned int queuenum)
 		goto err_out;
 	}
=20
-	nskb =3D nfqnl_build_packet_message(queue, entry);
+	nskb =3D nfqnl_build_packet_message(queue, entry, &packet_id_ptr);
 	if (nskb =3D=3D NULL) {
 		err =3D -ENOMEM;
 		goto err_out;
@@ -421,6 +423,8 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, =
unsigned int queuenum)
 				 queue->queue_total);
 		goto err_out_free_nskb;
 	}
+	entry->id =3D ++queue->id_sequence;
+	*packet_id_ptr =3D htonl(entry->id);
=20
 	/* nfnetlink_unicast will either free the nskb or add it to a socket =
*/
 	err =3D nfnetlink_unicast(nskb, &init_net, queue->peer_pid, MSG_DONTW=
AIT);
@@ -870,7 +874,7 @@ static int seq_show(struct seq_file *s, void *v)
 			  inst->peer_pid, inst->queue_total,
 			  inst->copy_mode, inst->copy_range,
 			  inst->queue_dropped, inst->queue_user_dropped,
-			  atomic_read(&inst->id_sequence), 1);
+			  inst->id_sequence, 1);
 }
=20
 static const struct seq_operations nfqnl_seq_ops =3D {


