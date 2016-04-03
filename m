From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Sun, 3 Apr 2016 19:03:09 -0400
Message-ID: <CAF=yD-LUaxsJMZiGXQdEDh-6UE11ApL89rjt=13oLK3FM1rerQ@mail.gmail.com>
References: <20160329224043.GY3784@sliepen.org> <CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
 <20160331.172050.1423948167839485574.davem@davemloft.net> <20160331222857.GH3771@sliepen.org>
 <20160331163932.3617e7cd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guus Sliepen <guus@tinc-vpn.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Network Development <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:36529 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbcDCXDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:03:51 -0400
Received: by mail-lb0-f178.google.com with SMTP id qe11so135244903lbc.3
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:03:50 -0700 (PDT)
In-Reply-To: <20160331163932.3617e7cd@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 7:39 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 1 Apr 2016 00:28:57 +0200
> Guus Sliepen <guus@tinc-vpn.org> wrote:
>
>> On Thu, Mar 31, 2016 at 05:20:50PM -0400, David Miller wrote:
>>
>> > >> I'm trying to reduce system call overhead when reading/writing to/from a
>> > >> tun device in userspace. [...] What would be the right way to do this?
>> > >>
>> > > Personally I think tun could benefit greatly if it were implemented as
>> > > a socket instead of character interface. One thing that could be much
>> > > better is sending/receiving of meta data attached to skbuf. For
>> > > instance GSO data could be in ancillary data in a socket instead of
>> > > inline with packet data as tun seems to be doing now.
>> >
>> > Agreed.
>>
>> Ok. So how should the userspace API work? Creating an AF_PACKET socket
>> and then using a tun ioctl to create a tun interface and bind it to the
>> socket?
>>
>> int fd = socket(AF_PACKET, ...)
>> struct ifreq ifr = {...};
>> ioctl(fd, TUNSETIFF, &ifr);
>>
>
> Rather than bodge AF_PACKET onto TUN, why not just create a new device type
> and control it from something modern like netlink.

Depending on the use-case, it may be sufficient to extend AF_PACKET
with limited tap functionality:

- add a po->xmit mode that reinjects into the kernel receive path,
  analogous to pktgen's M_NETIF_RECEIVE mode.

- optionally drop packets in __netif_receive_skb_core and xmit_one
  if any of the registered packet sockets accepted the packet and has
  a new intercept feature flag enabled.

This can be applied to a dummy device, but much more interesting
is to interpose on the flow of a normal nic. It is clearly not a drop-in
replacement for a tap (let alone tun) device. I have some preliminary
code.
