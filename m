From: kuznet@ms2.inr.ac.ru
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Thu, 14 Nov 2002 01:35:39 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211132235.BAA13386@sex.inr.ac.ru>
References: <20021113220311.GA29358@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021113220311.GA29358@outpost.ds9a.nl> from "bert hubert" at Nov 13, 2 11:03:11 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I now see a proper soft expire, new SAs being setup, old SAs in state 'dying',
> and traffic flowing nicely. Even with soft expire and no traffic, I see a
> new SA being negotiated.

Wait for a while and you will see message sort of:

Nov 13 20:48:59 mops  [291/0/0] racoon: INFO: isakmp.c:1521:isakmp_ph1expire():
ISAKMP-SA expired 192.168.1.202[500]-192.168.1.106[500] spi:c9549e2b4f33f8a3:655bf176d4531765

Note word "ISAKMP", this SA has nothing to do with IPsec, it is to protect
exchange between IKE's.

An IPsec SA soft-expires follows this. Then new IPsec SA will _not_ be
negotiated! So, old SA will be used until final hard expire, and
the next packet will trigger all the renegotiation from the very beginning
introducing a small gap in service and losing one or more packets.

Nov 13 20:45:59 mops  [291/0/0] racoon: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired: AH/Transport 192.168.1.106->192.168.1.202 spi=21148383(0x142b2df)
Nov 13 20:45:59 mops  [291/0/0] racoon: INFO: isakmp.c:1569:isakmp_ph1delete():
ISAKMP-SA deleted 192.168.1.202[500]-192.168.1.106[500] spi:a5eb75bdffbc0e6b:6b829e67c9bcfb3c
Nov 13 20:45:59 mops  [291/0/0] racoon: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired: AH/Transport 192.168.1.202->192.168.1.106 spi=218761938(0xd0a0ad2)
Nov 13 20:45:59 mops  [291/0/0] racoon: INFO: isakmp.c:1689:isakmp_post_acquire(): IPsec-SA request for 192.168.1.106 queued due to no phase1 found.


Apparently, racoon must reconnect to peer not waiting for timeout
when it sees that this SA was used recently enough. It does not.
Well, it is bug but not serious.



> Until the old SAs die, I see linux sending with the old SPI, is that right?

No, really. We prefer new one, when reselection is requested. We can
enforce reselection when some SA becomes close to death (dying),
and, probably, we will do. Well, KAME _always_ prefers old SA
which results in real loss of packets under freebsd. It is _disgusting_,
so we considered this as a bug in freebsd and forgot that linux can
behave in the same way when doing tcp, rather not ping. :-) :-)

Alexey
