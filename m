From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 22:28:52 -0400
Message-ID: <CA+FuTSeJ8krk3b8R==BwvdLH8Cw6k3f9mQT=CMKm70Sh4dsX3w@mail.gmail.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
 <1439567427-19504-3-git-send-email-willemb@google.com> <55CE1F54.7090109@plumgrid.com>
 <55CE3B11.40406@iogearbox.net> <CA+FuTSd1Ltxp-kcZtEjM41F7MaNXJZw4ruKnFPnhub9pMeeEcA@mail.gmail.com>
 <55CE459C.9030800@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33774 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbbHOC3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 22:29:22 -0400
Received: by ykll84 with SMTP id l84so20995110ykl.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 19:29:22 -0700 (PDT)
In-Reply-To: <55CE459C.9030800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 3:46 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/14/2015 09:27 PM, Willem de Bruijn wrote:
> ...
>>>
>>> Btw, in case someone sets sock_flag(sk, SOCK_FILTER_LOCKED),
>>> perhaps we should also apply it on fanout?
>>
>>
>> Good point. With classic bpf, packet access control is fully
>> enforced in per-socket filters, but playing with load balancing
>> filters could allow an adversary to infer some information
>> about the dropped packets*. With eBPF and maps, access
>> is even more direct. Let's support locking of fanout filters in
>> place.
>
>
> Right, a process could share a map between the fanout lb filter
> and actual sk filter, i.e. to look up how much actually passed
> through on the later sk level filter, and use that information
> in addition for its lb decisions.
>
>> I intend to test the existing socket flag. No need to add a
>> separate flag for the fanout group, as far as I can see.
>
>
> Agreed, should be okay.

Great. Thanks for the suggestion, Daniel! I'll send a v2 the
three suggested changes in a minute.

>
> Thanks Willem!
>
>> (*) I noticed that a similar unintended effect also causes the
>> PACKET_FANOUT_LB selftest to be flaky: filters on the
>> sockets ensure that the test only reads expected packets.
>> But, all traffic makes it through packet_rcv_fanout. Packets
>> that are later dropped by sk_filter have already incremented
>> rr_cur. Worst case, with 2 sockets and each accepted packet
>> interleaved with a dropped packet, all packets are queued on
>> only one socket. Test flakiness is fixed, e.g., by running in a
>> private network namespace. The implementation behavior
>> may be unexpected in other, production, environments.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
