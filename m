From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Thu, 17 Aug 2017 11:58:00 -0700
Message-ID: <5995E738.9090803@gmail.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810> <20170816053247.15445.69312.stgit@john-Precision-Tower-5810> <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, tom@herbertland.com
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35666 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753355AbdHQS6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 14:58:11 -0400
Received: by mail-pg0-f65.google.com with SMTP id t80so5058196pgb.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 11:58:10 -0700 (PDT)
In-Reply-To: <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[...]


>> +
>> +static void smap_tx_work(struct work_struct *w)
>> +{
>> +    struct smap_psock *psock;
>> +    struct sk_buff *skb;
>> +    int rem, off, n;
>> +
>> +    psock = container_of(w, struct smap_psock, tx_work);
>> +
>> +    /* lock sock to avoid losing sk_socket at some point during loop */
>> +    lock_sock(psock->sock);
>> +    if (psock->save_skb) {
>> +        skb = psock->save_skb;
>> +        rem = psock->save_rem;
>> +        off = psock->save_off;
>> +        psock->save_skb = NULL;
>> +        goto start;
>> +    }
>> +
>> +    while ((skb = skb_dequeue(&psock->rxqueue))) {
>> +        rem = skb->len;
>> +        off = 0;
>> +start:
>> +        do {
>> +            if (likely(psock->sock->sk_socket))
>> +                n = skb_send_sock_locked(psock->sock,
>> +                             skb, off, rem);
> 
> so this will be hot loop ?
> Do you have perf report by any chance? Curious how it looks.

I had some old ones but lets generate some fresh ones and we can go over
them. I'll post later today/tomorrow.

> 
>> +    /* reserve BPF programs early so can abort easily on failures */
>> +    if (map_flags & BPF_SOCKMAP_STRPARSER) {
> 
> why have two 'flags' arguments and new helper just for this?
> can normal update() be used and extra bits of flag there?
> 

The new helper is needed regardless to handle consuming the skops ctx
pointer from programs attached to cgroups. This way we can attach sockets
in cgroups when they enter specified TCP states.

The map_flags arg was because I expect we may end up with a few more flags
in sockmap and thought it was reasonable to keep separate namespaces for
the two flag types, BPF_ and BPF_SOCKMAP_*. It does however have the one
issue that when doing the update via syscall the flags are not available.

If there is no objection to consuming some bits of the normal flags a small
patch could do that. I think we will need at least two more bits going forward
for additional features. I guess though the map flags is not pressed for
bit space yet though.

>> -#define BPF_PROG_ATTACH_LAST_FIELD attach_flags
>> +#define BPF_PROG_ATTACH_LAST_FIELD attach_bpf_fd2
> 
>> +    prog1 = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
>> +    if (IS_ERR(prog1)) {
>> +        fdput(f);
>> +        return PTR_ERR(prog1);
>> +    }
>> +
>> +    prog2 = bpf_prog_get_type(attr->attach_bpf_fd2, ptype);
> 
> could you add a comment to uapi on possible uses of this field
> otherwise the name is not readable.

Yep no problem. I have a couple patches queued up for selftests and
automatically pulling in STREAM_PARSER, along with couple minor other
things so I'll push this update with those.

Thanks,
John
 
