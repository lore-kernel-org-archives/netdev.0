From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 0/5] net-timestamp: additional sw tstamps and
Date: Fri, 1 Aug 2014 09:44:32 -0400
Message-ID: <CA+FuTSfX6ZSYQP+rhJp+sBemsDrRWjOQhpOrVYwy7kwTK7YtZQ@mail.gmail.com>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
 <20140731.134330.1615160836103431950.davem@davemloft.net> <CA+FuTSe1T4-CtK88rBrm_yymer5iEPR7f8p-+bYHSW_4zMpAUg@mail.gmail.com>
 <20140731.223502.1817836164659773906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:52679 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHANpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 09:45:04 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so5700844qga.29
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 06:45:03 -0700 (PDT)
In-Reply-To: <20140731.223502.1817836164659773906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At the time we were discussing the removal syststamp, the intention
> was to use that space for a new value that can be use to match up
> timestamps properly with the packets they are for.
>
> Originally you wanted to use skb->mark for this and then we discussed
> all of the drawbacks and shortcoming of that.
>
> What happened to those plans?

Before skb->mark, in v1, I returned this stored seqno for that purpose.
Leaking the raw seqno is not ideal, and hard to work with in userspace
without the initial seqno.

An option that avoids this problem is to store the initial seqno in
sock and return the offset, to give a natural byte index into the stream.
For datagrams, the same field in skb_shared_info can store a packet
index, incremented on each timestamp request, in which case the
field in sock stores the timestamp counter.

> Also, there might be 4 bytes available in tcp_skb_cb.

I'll look into that. If the field stores the key to return to
userspace, it has to persist across GSO and into skb_tstamp_tx,
where skb->cb can longer be trusted to hold tcp_skb_cb.

A minor variation is to always return the simple counter, for both datagram
and bytestream sockets, in which case seqno is not used for this purpose,
never exposed, nor needed beyond GSO. In that case, I can try to store
this u32 in tcp_skb_cb and store the separate u16 counter in
skb_shared_info (a separate patch).

I prefer the first variant, using the same field for both purposes and
returning a byte index for bytestreams and packet index for datagram
sockets.
