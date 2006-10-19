From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 07:12:58 +0200
Message-ID: <4537095A.9010705@cosmosbay.com>
References: <45345999.4000300@psc.edu>
 <20061016.223513.35356292.davem@davemloft.net>
 <200610171458.37636.dada1@cosmosbay.com>
 <20061018.203109.63997999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:27062 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1422784AbWJSFM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 01:12:59 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7D001U2AHMWQW0@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 19 Oct 2006 07:12:58 +0200 (CEST)
In-reply-to: <20061018.203109.63997999.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet Hi <dada1@cosmosbay.com>
> Date: Tue, 17 Oct 2006 14:58:37 +0200
>=20
>> reqsk_queue_alloc() goal is to use a power of two size for the whole
>> listen_sock structure, to avoid wasting memory for large backlogs,
>> meaning the hash table nr_table_entries is not anymore a power of
>> two. (Hence one AND (nr_table_entries - 1) must be replaced by
>> MODULO nr_table_entries)
>=20
> Modulus can be very expensive for some small/slow cpus.  Please round
> down to a power-of-2 instead of up if you think the wastage really
> matters.
>=20
> Thanks.

I am not sure I understand your points. Rounding up or down still need =
the=20
modulus. Only the size changes by a two factor. I feel you want me to r=
emove=20
the modulus, thats unrelated to rounding.

A 66 MHz 486 can perform 1.000.000 divisions per second. Is it a 'slow'=
 cpu ?

If we stay with a power-of-two, say 2^X hash slots, using (2^X)*sizeof(=
void*),=20
the extra bits added by struct listen_sock will *need* the same amount =
of=20
memory, because of kmalloc() alignment to next power-of-two. That basic=
ally=20
wastes half of the ram taken by struct listen_sock allocation, unless w=
e add=20
yet another pointer to hash table and do two kmallocs(), one for pure=20
power-of-two hash table, one for struct listen_sock. If we keep current=
=20
scheme, the current max kmalloc size of 131072 bytes would limit us to =
65536=20
bytes for the hash table itself, so 8192 slots on 64bits platforms. I w=
as=20
expecting to use a 16380 slots hash size instead.

The modulus is done on two places :

inet_csk_search_req() : called from tcp_v4_err()/dccp_v4_err() only aft=
er=20
checks. Frequency of such events is rather low.

tcp_v4_hnd_req() : called from tcp_v4_do_rcv() for TCP_LISTEN state. Fr=
equency=20
of such events is rather low, especially on machines driven by small/sl=
ow cpus...

inet_csk_reqsk_queue_hash_add()called from tcp_v4_conn_request() when a=
 new=20
connection attempt is stored in hash table.

Thats in normal conditions two modulus done per new tcp/dccp sessions=20
establishments. In DOS situation, I doubt the extra cycles will do any =
difference.

So... what do you prefer :

1) Keep the modulus
2) allocate two blocks of ram (powser-of -two hash size, but one extra=20
indirection)
3) waste near half of ram because one block allocated, and power-of-two=
 hash size.

Thank you

Eric
