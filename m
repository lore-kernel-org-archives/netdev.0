From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums for UDP/IPv6)
Date: Mon, 7 Apr 2014 13:44:14 -0700
Message-ID: <CA+mtBx8B00+WUVZPuVm3ntJccRDajA2VZ8zBCkNfWkGJjZVbvQ@mail.gmail.com>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
	<20140407.131633.1635128478858805272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43319 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbaDGUoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 16:44:15 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so6880787iec.32
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 13:44:15 -0700 (PDT)
In-Reply-To: <20140407.131633.1635128478858805272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 10:16 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 4 Apr 2014 17:28:24 -0700 (PDT)
>
>> RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
>> are received with a zero UDP checksum value must be dropped. RFC 6936
>> allow zero checksums to support tunnels over UDP.
>>
>> This patch adds a new socket option UDP_CHECK6_ZERO_OKAY whcih can be
>> set on a UDP socket to indicate that a zero checksum is acceptable
>> (e.g. the socket is for a tunnel). The ip6 checksum and UDP receive
>> functions were updated accordingly to deal with this.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> I see you reply to this later and say we can use sk_no_check.
>
> Are you really sure?  This might create a surprise for someone
> inadvertantly setting that now and expecting it to have a very
> specific effect only for ipv4 UDP sockets.
>
> The safest thing to do is to create the new option, then there
> is no discrepancy.

The semantics of sk_no_check are a little muddled since it is a
boolean that's not a boolean :-). It looks like:

1) If sk_no_check == UDP_CSUM_NOXMIT, we want to send zero csums.
Logically, I think this implies willingness to receive zero checksum
in UDP/IPV6 for the socket.
2) If sk_no_check is set l2tp_verify_checksum accepts bad checksums
(ironically, UDP/IPv6 checksum of zero is rejected before this point).
This seems like a really bad idea. The git log mentions this was done
because of "L2TP over localhost issue with incorrect checksums being
reported"-- so why not fix TX side to set correct csum or send zero
csums?
2) If sk_no_check == UDP_CSUM_NORCV, I assume this is intended to
disable RX csums to some extent (maybe allow zero csum?). The only
effect I see i the above mentioned l2tp interaction. The only code
that sets this is net/sunrpc/xprtsock.c, and I'm not sure what that is
trying to accomplish.

If we really need the mode of accepting zero csum but not sending it,
then UDP_CSUM_NORCV and a new socket option might have meaning. But if
we don't need that, sk_no_check and SO_NO_CHECK might be good enough
(assuming xprtsock use case is resolved) also sk_no_check could go
back to being a boolean. Since the zero checksum is only allowed for
tunnels, I think the latter might be right. In any case, I don't think
we want to allow the ability to accept packets with bad checksums on a
UDP socket like l2tp would do!

Tom
