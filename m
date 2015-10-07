From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix cb access in socket filter programs
Date: Wed, 07 Oct 2015 15:09:11 +0200
Message-ID: <56151977.10302@iogearbox.net>
References: <1444184292-17500-1-git-send-email-ast@plumgrid.com> <5614E84E.2010806@iogearbox.net>
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
Received: from www62.your-server.de ([213.133.104.62]:41000 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbbJGNJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 09:09:24 -0400
In-Reply-To: <5614E84E.2010806@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2015 11:39 AM, Daniel Borkmann wrote:
> On 10/07/2015 04:18 AM, Alexei Starovoitov wrote:
>> eBPF socket filter programs may see junk in 'u32 cb[5]' area,
>> since it could have been used by protocol layers earlier.
>>
>> On the receive path the af_packet sees clean skb->cb.
>> On the xmit the dev_queue_xmit_nit() delivers cloned skb, so we can
>> conditionally clean 20 bytes of skb->cb that could be used by the program.
>
> Having slept over this one night, I think this assumption is not
> always correct :/, more below ...
>
>> For programs attached to TCP/UDP sockets we need to save/restore
>> these 20 bytes, since it's used by protocol layers.
> ...
>> +static inline u32 bpf_prog_run_save_cb(const struct bpf_prog *prog,
>> +                       struct sk_buff *skb)
>> +{
>> +    u8 *cb_data = qdisc_skb_cb(skb)->data;
>> +    u8 saved_cb[QDISC_CB_PRIV_LEN];
>> +    u32 res;
>> +
>> +    BUILD_BUG_ON(FIELD_SIZEOF(struct __sk_buff, cb) !=
>> +             QDISC_CB_PRIV_LEN);
>> +
>> +    if (unlikely(prog->cb_access)) {
>> +        memcpy(saved_cb, cb_data, sizeof(saved_cb));
>> +        memset(cb_data, 0, sizeof(saved_cb));
>> +    }
>> +
>> +    res = BPF_PROG_RUN(prog, skb);
>> +
>> +    if (unlikely(prog->cb_access))
>> +        memcpy(cb_data, saved_cb, sizeof(saved_cb));
>> +
>> +    return res;
>> +}
>> +
>> +static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
>> +                    struct sk_buff *skb)
>> +{
>> +    u8 *cb_data = qdisc_skb_cb(skb)->data;
>> +
>> +    if (unlikely(prog->cb_access) && skb->pkt_type == PACKET_OUTGOING)
>> +        memset(cb_data, 0, QDISC_CB_PRIV_LEN);
>> +    return BPF_PROG_RUN(prog, skb);
>> +}
>> +
>>   static inline unsigned int bpf_prog_size(unsigned int proglen)
>>   {
>>       return max(sizeof(struct bpf_prog),
>
> bpf_prog_run_clear_cb() wouldn't work on dev_forward_skb() as
> skb->pkt_type is then being scrubbed to PACKET_HOST, so on the
> receive path, AF_PACKET might not always see clean skbs->cb[]
> as assumed ... I think that the skb->pkt_type part needs to be
> dropped, no?

Thinking a bit more about this part, which only accounts for
fanout_demux_bpf() and run_filter(), so AF_PACKET only, this
logic still needs to be slightly different:

You currently can have eBPF on packet fanout as a demux and behind
that eBPF on the actual packet socket. So, for some reason, fanout
could transfer some state to the socket along the way, which could
break when cleared as-is via bpf_prog_run_clear_cb().

So we need to make sure to only clear this once, either in front
of fanout, or when not present, in front of the socket filter.

Thanks,
Daniel
