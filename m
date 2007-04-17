From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet addresses
Date: Tue, 17 Apr 2007 23:24:36 +0200
Message-ID: <46253B14.8030401@cosmosbay.com>
References: <4625263D.1000709@linux-foundation.org>	<20070417.130929.59470175.davem@davemloft.net>	<20070417133723.00031f82@mini> <20070417.140941.41631883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, xemul@sw.ru,
	netdev@vger.kernel.org, bridge@lists.osdl.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50048 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbXDQVZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 17:25:34 -0400
In-Reply-To: <20070417.140941.41631883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 17 Apr 2007 13:37:23 -0700
>=20
>> The previous patch relied on the bridge id being aligned by
>> the compiler (which happens as a side effect). So please use
>> this instead.
>>
>> compare_ether_addr() implicitly requires that the addresses
>> passed are 2-bytes aligned in memory.
>>
>> This is not true for br_stp_change_bridge_id() and
>> br_stp_recalculate_bridge_id() in which one of the addresses
>> is unsigned char *, and thus may not be 2-bytes aligned.
>>
>> Signed-off-by: Evgeny Kravtsunov <emkravts@openvz.org>
>> Signed-off-by: Kirill Korotaev <dev@openvz.org>
>> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>=20
> bridge_id would be aligned by luck, because it is composed of char's
> there is no explicit reason it should be aligned on at least an
> unsigned short boundary.
>=20
> I like the other patch much better, it provided explicit alignment an=
d
> is guarenteed to get rid of the problem.
>=20
> Indeed, I wrote a test program on 32-bit Sparc to validate this:
>=20
> struct bridge_id {
> 	unsigned char a[6];
> 	unsigned char b[6];
> };
>=20
> extern void bar(unsigned char *, unsigned char *);
>=20
> void foo(void)
> {
> 	unsigned char a;
> 	struct bridge_id b;
>=20
> 	bar(&b.a[0], &a);
> }
>=20
> foo() gets compiled like this:
>=20
> foo:
> 	save	%sp, -120, %sp
> 	add	%fp, -21, %o0
> 	call	bar, 0
> 	 add	%fp, -9, %o1
> 	jmp	%i7+8
> 	 restore
>=20
> See?  The bridge_id (passed in via %o0) is on an odd byte boundary
> on the stack.
>=20
> So your patch isn't fixing the bug at all.
>=20
> I'm going to apply the original patch, because that one will
> actually fix the problem and was actually tested on a system
> that saw the problem.

I suspect you missed part of Stephen patch :

(maybe some mailer problem...)

--- linux-2.6.orig/net/bridge/br_private.h	2007-04-17
13:26:48.000000000 -0700 +++ linux-2.6/net/bridge/br_private.h
2007-04-17 13:30:29.000000000 -0700 @@ -36,7 +36,7 @@
  {
  	unsigned char	prio[2];
  	unsigned char	addr[6];
-};
+} __attribute__((aligned(8)));

  struct mac_addr
  {

