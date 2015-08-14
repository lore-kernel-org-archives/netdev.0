From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 15:27:21 -0400
Message-ID: <CA+FuTSd1Ltxp-kcZtEjM41F7MaNXJZw4ruKnFPnhub9pMeeEcA@mail.gmail.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
 <1439567427-19504-3-git-send-email-willemb@google.com> <55CE1F54.7090109@plumgrid.com>
 <55CE3B11.40406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:36354 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752236AbbHNT1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 15:27:51 -0400
Received: by ykfw73 with SMTP id w73so23986247ykf.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 12:27:51 -0700 (PDT)
In-Reply-To: <55CE3B11.40406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [ @Willem: RH email doesn't exist anymore, I took it out, otherwise
>   every reply gets a bounce. ;) ]

Sorry for using the wrong address, Daniel.

>> Also instead of:
>>   #define PACKET_FANOUT_BPF        6
>>   #define PACKET_FANOUT_EBPF        7
>>
>> I would call them FANOUT_CBPF and FANOUT_EBPF to be unambiguous.
>> This is how bpf manpage distinguishes them.
>
> We have SO_ATTACH_FILTER and SO_ATTACH_BPF, could also be
> analogous for fanout, if we want to be consistent with the API?
>
> But C/E prefix seems okay too, how you want ...

I don't feel very strongly, either. But CBPF/EBPF is a bit more
descriptive, so let's do that.

> Btw, in case someone sets sock_flag(sk, SOCK_FILTER_LOCKED),
> perhaps we should also apply it on fanout?

Good point. With classic bpf, packet access control is fully
enforced in per-socket filters, but playing with load balancing
filters could allow an adversary to infer some information
about the dropped packets*. With eBPF and maps, access
is even more direct. Let's support locking of fanout filters in
place.

I intend to test the existing socket flag. No need to add a
separate flag for the fanout group, as far as I can see.


(*) I noticed that a similar unintended effect also causes the
PACKET_FANOUT_LB selftest to be flaky: filters on the
sockets ensure that the test only reads expected packets.
But, all traffic makes it through packet_rcv_fanout. Packets
that are later dropped by sk_filter have already incremented
rr_cur. Worst case, with 2 sockets and each accepted packet
interleaved with a dropped packet, all packets are queued on
only one socket. Test flakiness is fixed, e.g., by running in a
private network namespace. The implementation behavior
may be unexpected in other, production, environments.
