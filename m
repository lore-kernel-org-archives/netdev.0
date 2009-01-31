From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 10:17:44 +0100
Message-ID: <49841738.7050605@cosmosbay.com>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34633 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbZAaJSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 04:18:25 -0500
In-Reply-To: <20090131083724.GB26897@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Fri, Jan 30, 2009 at 06:52:24PM -0800, Stephen Hemminger (shemming=
er@vyatta.com) wrote:
>> My working hypothesis is:
>>   1. Something about Evgeniy's patch makes IPV6 (actually IPV4 in IP=
V6) be
>>      preferred over plain IPV4.
>>   2. Vino server (VNC) doesn't think ::ffff::127.0.0.1 is really the=
 localhost
>>   3. protocol gets screwed up after that.
>>
>> It is probably reproducible with other services that support IPV6.
>=20
> getaddrinfo() returns list of addresses and IPv6 was the first one ii=
rc.
> Previously it bailed out, but with my change it will try again withou=
t
> reason for doing this. With the patch I sent based on Eric's observat=
ion
> things should be fine.
>=20

Problem is your patch is wrong Evgeniy, please think about it litle bit=
 more
and resubmit it.=20

Take the time to run this $0.02 program, before and after your upcoming=
 fix :


$ cat size.c
#include <net/inet_hashtables.h>
extern int printf(const char *, ...);
int main(int argc, char *argv[])
{
        printf("offsetof(struct inet_hashinfo, bsockets)=3D0x%x\n",
                offsetof(struct inet_hashinfo, bsockets));
        return 0;
}
$ make size.o ; gcc -o size size.o ; ./size
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CALL    scripts/checksyscalls.sh
  CC      size.o
offsetof(struct inet_hashinfo, bsockets)=3D0x18


offset of bsockets being 0x18 or 0x20 is same result : bad because in
same cache line than ehash, ehash_locks, ehash_size, ehash_locks_mask,
bhash, bhash_size, unless your cpu is a Pentium.

Also, I suggest you change bsockets to something more appropriate, eg a
percpu counter.

Thank you.
Eric

