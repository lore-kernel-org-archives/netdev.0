From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Wed, 16 Aug 2017 22:40:06 -0700
Message-ID: <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
 <20170816053247.15445.69312.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <tom@herbertland.com>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37778 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750903AbdHQFkb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 01:40:31 -0400
In-Reply-To: <20170816053247.15445.69312.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/17 10:32 PM, John Fastabend wrote:
> +
> +static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
> +{
> +	struct sock *sock;
> +	int rc;
> +
> +	/* Because we use per cpu values to feed input from sock redirect
> +	 * in BPF program to do_sk_redirect_map() call we need to ensure we
> +	 * are not preempted. RCU read lock is not sufficient in this case
> +	 * with CONFIG_PREEMPT_RCU enabled so we must be explicit here.
> +	 */
> +	preempt_disable();
> +	rc = smap_verdict_func(psock, skb);
> +	switch (rc) {
> +	case SK_REDIRECT:
> +		sock = do_sk_redirect_map();
> +		preempt_enable();
> +		if (likely(sock)) {
> +			struct smap_psock *peer = smap_psock_sk(sock);
> +
> +			if (likely(peer &&
> +				   test_bit(SMAP_TX_RUNNING, &peer->state) &&
> +				   sk_stream_memory_free(peer->sock))) {
> +				peer->sock->sk_wmem_queued += skb->truesize;
> +				sk_mem_charge(peer->sock, skb->truesize);
> +				skb_queue_tail(&peer->rxqueue, skb);
> +				schedule_work(&peer->tx_work);
> +				break;
> +			}
> +		}
> +	/* Fall through and free skb otherwise */
> +	case SK_DROP:
> +	default:
> +		preempt_enable();
> +		kfree_skb(skb);

two preempt_enable() after single preempt_disable()?

> +
> +static void smap_tx_work(struct work_struct *w)
> +{
> +	struct smap_psock *psock;
> +	struct sk_buff *skb;
> +	int rem, off, n;
> +
> +	psock = container_of(w, struct smap_psock, tx_work);
> +
> +	/* lock sock to avoid losing sk_socket at some point during loop */
> +	lock_sock(psock->sock);
> +	if (psock->save_skb) {
> +		skb = psock->save_skb;
> +		rem = psock->save_rem;
> +		off = psock->save_off;
> +		psock->save_skb = NULL;
> +		goto start;
> +	}
> +
> +	while ((skb = skb_dequeue(&psock->rxqueue))) {
> +		rem = skb->len;
> +		off = 0;
> +start:
> +		do {
> +			if (likely(psock->sock->sk_socket))
> +				n = skb_send_sock_locked(psock->sock,
> +							 skb, off, rem);

so this will be hot loop ?
Do you have perf report by any chance? Curious how it looks.

> +	/* reserve BPF programs early so can abort easily on failures */
> +	if (map_flags & BPF_SOCKMAP_STRPARSER) {

why have two 'flags' arguments and new helper just for this?
can normal update() be used and extra bits of flag there?

> -#define BPF_PROG_ATTACH_LAST_FIELD attach_flags
> +#define BPF_PROG_ATTACH_LAST_FIELD attach_bpf_fd2

> +	prog1 = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
> +	if (IS_ERR(prog1)) {
> +		fdput(f);
> +		return PTR_ERR(prog1);
> +	}
> +
> +	prog2 = bpf_prog_get_type(attr->attach_bpf_fd2, ptype);

could you add a comment to uapi on possible uses of this field
otherwise the name is not readable.
