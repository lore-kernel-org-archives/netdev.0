From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5 2.6.21-rc7] l2tp: pppol2tp core
Date: Tue, 24 Apr 2007 18:01:29 +0200
Message-ID: <462E29D9.8000600@trash.net>
References: <200704231601.l3NG13TN030167@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42373 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623AbXDXQBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 12:01:51 -0400
In-Reply-To: <200704231601.l3NG13TN030167@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> +static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
> +{
> +	struct sk_buff *skb;
> +	struct sk_buff *tmp;
> +
> +	/* If the pkt at the head of the queue has the nr that we
> +	 * expect to send up next, dequeue it and any other
> +	 * in-sequence packets behind it.
> +	 */
> +	spin_lock(&session->reorder_q.lock);
> +	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
> +		spin_unlock(&session->reorder_q.lock);
> +
> +		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
> +			session->stats.rx_seq_discards++;
> +			session->stats.rx_errors++;
> +			PRINTK(session->debug, PPPOL2TP_MSG_SEQ, KERN_DEBUG,
> +			       "%s: oos pkt %hu len %d discarded (too old), "
> +			       "waiting for %hu, reorder_q_len=%d\n",
> +			       session->name, PPPOL2TP_SKB_CB(skb)->ns,
> +			       PPPOL2TP_SKB_CB(skb)->length, session->nr,
> +			       skb_queue_len(&session->reorder_q));
> +			skb_unlink(skb, &session->reorder_q);
> +			kfree_skb(skb);


Since you drop the lock above, what prevents this from running
concurrently on two CPUs and freeing the skb twice?

> +static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
> +{
> +	struct pppol2tp_session *session = NULL;
> +	struct pppol2tp_tunnel *tunnel;
> +	unsigned char *ptr;
> +	u16 hdrflags;
> +	u16 tunnel_id, session_id;
> +	int length;
> +
> +	tunnel = pppol2tp_sock_to_tunnel(sock);
> +	if (tunnel == NULL)
> +		goto error;
> +
> +	/* Short packet? */
> +	if (skb->len < sizeof(struct udphdr)) {
> +		PRINTK(tunnel->debug, PPPOL2TP_MSG_DATA, KERN_INFO,
> +		       "%s: recv short packet (len=%d)\n", tunnel->name, skb->len);
> +		goto error;
> +	}
> +
> +	/* Point to L2TP header */
> +	ptr = skb->data + sizeof(struct udphdr);
> +
> +	/* Get L2TP header flags */
> +	hdrflags = ntohs(*(u16*)ptr);


__be16 here and elsewhere please.

> +/* The data_ready hook on the UDP socket. Scan the incoming packet list for
> + * packets to process. Only control or bad data packets are delivered to
> + * userspace.
> + */
> +static void pppol2tp_data_ready(struct sock *sk, int len)
> +{
> +	struct pppol2tp_tunnel *tunnel;
> +	struct sk_buff *skb;
> +
> +	tunnel = pppol2tp_sock_to_tunnel(sk);
> +	if (tunnel == NULL)
> +		goto end;
> +
> +	PRINTK(tunnel->debug, PPPOL2TP_MSG_DATA, KERN_DEBUG,
> +	       "%s: received %d bytes\n", tunnel->name, len);
> +
> +	skb = skb_dequeue(&sk->sk_receive_queue);
> +	if (skb != NULL) {
> +		if (pppol2tp_recv_core(sk, skb)) {
> +			skb_queue_head(&sk->sk_receive_queue, skb);
> +			tunnel->old_data_ready(sk, len);


Still the ugly old_data_ready/old_sk_destruct and pppol2tp_fget hacks.
What prevents you from using encapsulation sockets to get rid of this
stuff and have ppp_generic filter out non-data frames for userspace
as for other ppp drivers?

> +static int pppol2tp_proc_open(struct inode *inode, struct file *file);
> +static int pppol2tp_proc_release(struct inode *inode, struct file *file);
> +static void *pppol2tp_seq_start(struct seq_file *m, loff_t *_pos);
> +static void *pppol2tp_seq_next(struct seq_file *p, void *v, loff_t *pos);
> +static void pppol2tp_seq_stop(struct seq_file *p, void *v);
> +static int pppol2tp_seq_show(struct seq_file *m, void *v);


Please avoid these by reordering the code.

> +/* Used by sort()
> + */
> +static void pppol2tp_seq_swap(void *a, void *b, int size)
> +{
> +	struct pppol2tp_seq_data tmp;
> +	struct pppol2tp_seq_data *left = a;
> +	struct pppol2tp_seq_data *right = b;
> +
> +	tmp = *left;
> +	*left = *right;
> +	*right = tmp;
> +}
> +
> +/* Used by sort()
> + */
> +static int pppol2tp_seq_cmp(const void *a, const void *b)
> +{
> +	const struct pppol2tp_seq_data *left = a;
> +	const struct pppol2tp_seq_data *right = b;
> +
> +	if (left->tunnel_id < right->tunnel_id)
> +		return -1;
> +	if (left->tunnel_id > right->tunnel_id)
> +		return 1;
> +	if (left->session_id < right->session_id)
> +		return -1;
> +	if (left->session_id > right->session_id)
> +		return 1;
> +	return 0;
> +}


Why is this needed? Can't userspace sort them itself in case it really
needs some defined ordering?

> +static void pppol2tp_seq_tunnel_show(struct seq_file *m, void *v)
> +{
> +	struct pppol2tp_tunnel *tunnel = v;
> +
> +	seq_printf(m, "\nTUNNEL '%s', %c %d MAGIC %s\n",
> +		   tunnel->name,
> +		   (tunnel == tunnel->sock->sk_user_data) ? 'Y':'N',
> +		   atomic_read(&tunnel->ref_count) - 1,
> +		   (tunnel->magic == L2TP_TUNNEL_MAGIC) ? "OK" : "BAD");
> +	seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
> +		   tunnel->debug,
> +		   tunnel->stats.tx_packets, tunnel->stats.tx_bytes,
> +		   tunnel->stats.tx_errors,
> +		   tunnel->stats.rx_packets, tunnel->stats.rx_bytes,
> +		   tunnel->stats.rx_errors);


Still no return value checks.
