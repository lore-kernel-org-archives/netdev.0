From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 21:46:36 +0200
Message-ID: <55CE459C.9030800@iogearbox.net>
References: <1439567427-19504-1-git-send-email-willemb@google.com> <1439567427-19504-3-git-send-email-willemb@google.com> <55CE1F54.7090109@plumgrid.com> <55CE3B11.40406@iogearbox.net> <CA+FuTSd1Ltxp-kcZtEjM41F7MaNXJZw4ruKnFPnhub9pMeeEcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53253 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbHNTql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 15:46:41 -0400
In-Reply-To: <CA+FuTSd1Ltxp-kcZtEjM41F7MaNXJZw4ruKnFPnhub9pMeeEcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2015 09:27 PM, Willem de Bruijn wrote:
...
>> Btw, in case someone sets sock_flag(sk, SOCK_FILTER_LOCKED),
>> perhaps we should also apply it on fanout?
>
> Good point. With classic bpf, packet access control is fully
> enforced in per-socket filters, but playing with load balancing
> filters could allow an adversary to infer some information
> about the dropped packets*. With eBPF and maps, access
> is even more direct. Let's support locking of fanout filters in
> place.

Right, a process could share a map between the fanout lb filter
and actual sk filter, i.e. to look up how much actually passed
through on the later sk level filter, and use that information
in addition for its lb decisions.

> I intend to test the existing socket flag. No need to add a
> separate flag for the fanout group, as far as I can see.

Agreed, should be okay.

Thanks Willem!

> (*) I noticed that a similar unintended effect also causes the
> PACKET_FANOUT_LB selftest to be flaky: filters on the
> sockets ensure that the test only reads expected packets.
> But, all traffic makes it through packet_rcv_fanout. Packets
> that are later dropped by sk_filter have already incremented
> rr_cur. Worst case, with 2 sockets and each accepted packet
> interleaved with a dropped packet, all packets are queued on
> only one socket. Test flakiness is fixed, e.g., by running in a
> private network namespace. The implementation behavior
> may be unexpected in other, production, environments.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
