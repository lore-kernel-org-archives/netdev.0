From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Thu, 23 Dec 2010 21:25:23 +0100
Message-ID: <20101223202523.GA1913@del.dom.local>
References: <20101222110021.GA8985@ff.dom.local>
 <4D122093.6060900@scarlet.be>
 <1293035100.3027.247.camel@edumazet-laptop>
 <4D132C5F.8090404@scarlet.be>
 <1293106348.7789.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Soete <soete.joel@scarlet.be>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60466 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab0LWUZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 15:25:32 -0500
Content-Disposition: inline
In-Reply-To: <1293106348.7789.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 23, 2010 at 01:12:28PM +0100, Eric Dumazet wrote:
> Le jeudi 23 d=E9cembre 2010 ?? 11:02 +0000, Joel Soete a =E9crit :
=2E..
> > Sorry for delay but I have good news, I am sending this answer from=
:
> > $ uname -a
> > Linux sidh2 2.6.37-rc7-amd64-t1 #1 SMP Thu Dec 23 10:30:27 GMT 2010=
 x86_64 GNU/Linux
> >=20
> > with your tips ;<) (without kernel had already died)
> >=20
> > That said how can find stuff overflowing skb head? (all I say, is t=
hat this issue started with 2.6.34-git6???)

Hi Joel,
2.6.34-git6 or 7 is almost a whole netdev batch for 2.6.35 so still
a lot of guessing. One such guess could be e.g. this one:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D18e8c134f4e984e6639e62846345192816f06d5c

I've added to Eric's patch some debugging. After taking several
warnings (might a lot) revert this patch and apply Eric's again.
Btw, could you send your pppoe config (without any personal data,
of course), and mention if there are other changes like mtu etc.

> I am taking holidays right now for about 5 days, I guess someone else
> might find the bug before me ;)

Good job, Eric, we can try. Have a nice rest!

Thanks,
Jarek P.
--- (a debugging patch, apply to clean 2.6.37-rc)

 drivers/net/pppoe.c    |    8 ++++++++
 include/linux/skbuff.h |    6 ++++++
 net/core/dev.c         |    8 ++++++++
 net/core/skbuff.c      |    9 +++++++++
 4 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index d72fb05..0d41a04 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -385,6 +385,7 @@ static int pppoe_rcv_core(struct sock *sk, struct s=
k_buff *skb)
 	 * can't change.
 	 */
=20
+	DEBUG_SKB_POISON(skb);
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
@@ -430,6 +431,7 @@ static int pppoe_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 	if (!skb)
 		goto out;
=20
+	DEBUG_SKB_POISON(skb);
 	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
 		goto drop;
=20
@@ -452,6 +454,7 @@ static int pppoe_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 	if (!po)
 		goto drop;
=20
+	DEBUG_SKB_POISON(skb);
 	return sk_receive_skb(sk_pppox(po), skb, 0);
=20
 drop:
@@ -485,6 +488,7 @@ static int pppoe_disc_rcv(struct sk_buff *skb, stru=
ct net_device *dev,
 	if (ph->code !=3D PADT_CODE)
 		goto abort;
=20
+	DEBUG_SKB_POISON(skb);
 	pn =3D pppoe_pernet(dev_net(dev));
 	po =3D get_item(pn, ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
 	if (po) {
@@ -888,6 +892,7 @@ static int pppoe_sendmsg(struct kiocb *iocb, struct=
 socket *sock,
=20
 	ph->length =3D htons(total_len);
=20
+	DEBUG_SKB_POISON(skb);
 	dev_queue_xmit(skb);
=20
 end:
@@ -921,6 +926,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_=
buff *skb)
 	if (!dev)
 		goto abort;
=20
+	DEBUG_SKB_POISON(skb);
 	/* Copy the data if there is no space for the header or if it's
 	 * read-only.
 	 */
@@ -943,6 +949,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_=
buff *skb)
 	dev_hard_header(skb, dev, ETH_P_PPP_SES,
 			po->pppoe_pa.remote, NULL, data_len);
=20
+	DEBUG_SKB_POISON(skb);
 	dev_queue_xmit(skb);
 	return 1;
=20
@@ -987,6 +994,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct=
 socket *sock,
 	m->msg_namelen =3D 0;
=20
 	if (skb) {
+		DEBUG_SKB_POISON(skb);
 		total_len =3D min_t(size_t, total_len, skb->len);
 		error =3D skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
 		if (error =3D=3D 0)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..706f182 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -187,6 +187,12 @@ enum {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+#define SKB_POISON	0xe2e4e7e5
+#define SET_SKB_POISON(skb)	skb_shinfo(skb)->poison =3D SKB_POISON
+#define DEBUG_SKB_POISON(skb)	WARN_ON(skb_shinfo(skb)->poison !=3D SKB=
_POISON)
+
+	unsigned int	poison;
+	char		filler[60];
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
diff --git a/net/core/dev.c b/net/core/dev.c
index 0dd54a6..01ca7de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1994,6 +1994,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	const struct net_device_ops *ops =3D dev->netdev_ops;
 	int rc =3D NETDEV_TX_OK;
=20
+	DEBUG_SKB_POISON(skb);
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
@@ -2026,6 +2027,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 			    __skb_linearize(skb))
 				goto out_kfree_skb;
=20
+			DEBUG_SKB_POISON(skb);
+
 			/* If packet is not checksummed and device does not
 			 * support checksumming for this protocol, complete
 			 * checksumming here.
@@ -2039,6 +2042,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 			}
 		}
=20
+		DEBUG_SKB_POISON(skb);
 		rc =3D ops->ndo_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc);
 		if (rc =3D=3D NETDEV_TX_OK)
@@ -2243,6 +2247,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc =3D -ENOMEM;
=20
+	DEBUG_SKB_POISON(skb);
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
@@ -2604,6 +2609,7 @@ int netif_rx(struct sk_buff *skb)
 {
 	int ret;
=20
+	DEBUG_SKB_POISON(skb);
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
@@ -2898,6 +2904,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
+	DEBUG_SKB_POISON(skb);
 	if (!netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
=20
@@ -3043,6 +3050,7 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
+	DEBUG_SKB_POISON(skb);
 	if (netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..b112c7d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -210,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 	shinfo =3D skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
+	SET_SKB_POISON(skb);
=20
 	if (fclone) {
 		struct sk_buff *child =3D skb + 1;
@@ -412,6 +413,7 @@ static void skb_release_all(struct sk_buff *skb)
=20
 void __kfree_skb(struct sk_buff *skb)
 {
+	DEBUG_SKB_POISON(skb);
 	skb_release_all(skb);
 	kfree_skbmem(skb);
 }
@@ -428,6 +430,7 @@ void kfree_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
+	DEBUG_SKB_POISON(skb);
 	if (likely(atomic_read(&skb->users) =3D=3D 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
@@ -449,6 +452,7 @@ void consume_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
+	DEBUG_SKB_POISON(skb);
 	if (likely(atomic_read(&skb->users) =3D=3D 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
@@ -487,11 +491,13 @@ bool skb_recycle_check(struct sk_buff *skb, int s=
kb_size)
 	if (skb_shared(skb) || skb_cloned(skb))
 		return false;
=20
+	DEBUG_SKB_POISON(skb);
 	skb_release_head_state(skb);
=20
 	shinfo =3D skb_shinfo(skb);
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
+	SET_SKB_POISON(skb);
=20
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data =3D skb->head + NET_SKB_PAD;
@@ -571,6 +577,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *=
n, struct sk_buff *skb)
=20
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned =3D 1;
+	DEBUG_SKB_POISON(skb);
=20
 	return n;
 #undef C
@@ -772,6 +779,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	bool fastpath;
=20
 	BUG_ON(nhead < 0);
+	DEBUG_SKB_POISON(skb);
=20
 	if (skb_shared(skb))
 		BUG();
@@ -836,6 +844,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	skb->hdr_len  =3D 0;
 	skb->nohdr    =3D 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+	SET_SKB_POISON(skb);
 	return 0;
=20
 nodata:
