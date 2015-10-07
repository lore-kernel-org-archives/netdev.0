From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix cb access in socket filter programs
Date: Wed, 07 Oct 2015 11:39:26 +0200
Message-ID: <5614E84E.2010806@iogearbox.net>
References: <1444184292-17500-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46572 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbbJGJjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 05:39:37 -0400
In-Reply-To: <1444184292-17500-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2015 04:18 AM, Alexei Starovoitov wrote:
> eBPF socket filter programs may see junk in 'u32 cb[5]' area,
> since it could have been used by protocol layers earlier.
>
> On the receive path the af_packet sees clean skb->cb.
> On the xmit the dev_queue_xmit_nit() delivers cloned skb, so we can
> conditionally clean 20 bytes of skb->cb that could be used by the program.

Having slept over this one night, I think this assumption is not
always correct :/, more below ...

> For programs attached to TCP/UDP sockets we need to save/restore
> these 20 bytes, since it's used by protocol layers.
...
> +static inline u32 bpf_prog_run_save_cb(const struct bpf_prog *prog,
> +				       struct sk_buff *skb)
> +{
> +	u8 *cb_data = qdisc_skb_cb(skb)->data;
> +	u8 saved_cb[QDISC_CB_PRIV_LEN];
> +	u32 res;
> +
> +	BUILD_BUG_ON(FIELD_SIZEOF(struct __sk_buff, cb) !=
> +		     QDISC_CB_PRIV_LEN);
> +
> +	if (unlikely(prog->cb_access)) {
> +		memcpy(saved_cb, cb_data, sizeof(saved_cb));
> +		memset(cb_data, 0, sizeof(saved_cb));
> +	}
> +
> +	res = BPF_PROG_RUN(prog, skb);
> +
> +	if (unlikely(prog->cb_access))
> +		memcpy(cb_data, saved_cb, sizeof(saved_cb));
> +
> +	return res;
> +}
> +
> +static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
> +					struct sk_buff *skb)
> +{
> +	u8 *cb_data = qdisc_skb_cb(skb)->data;
> +
> +	if (unlikely(prog->cb_access) && skb->pkt_type == PACKET_OUTGOING)
> +		memset(cb_data, 0, QDISC_CB_PRIV_LEN);
> +	return BPF_PROG_RUN(prog, skb);
> +}
> +
>   static inline unsigned int bpf_prog_size(unsigned int proglen)
>   {
>   	return max(sizeof(struct bpf_prog),

bpf_prog_run_clear_cb() wouldn't work on dev_forward_skb() as
skb->pkt_type is then being scrubbed to PACKET_HOST, so on the
receive path, AF_PACKET might not always see clean skbs->cb[]
as assumed ... I think that the skb->pkt_type part needs to be
dropped, no?

Thanks,
Daniel
