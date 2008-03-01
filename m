From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Sat, 01 Mar 2008 14:53:00 +0100
Message-ID: <47C95FBC.1010703@cosmosbay.com>
References: <47BDBC23.10605@cosmosbay.com>	<Pine.LNX.4.64.0802271158100.1790@schroedinger.engr.sgi.com> <20080227122451.6a3b5565.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <clameter@sgi.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yanmin_zhang@linux.intel.com, travis@sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:42227
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756379AbYCANxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 08:53:30 -0500
In-Reply-To: <20080227122451.6a3b5565.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton a =E9crit :
> On Wed, 27 Feb 2008 11:59:32 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
>=20
>> Any decision made on what to do about this one? Mike or I can=20
>> repost the per cpu allocator against mm? The fix by Eric could be us=
ed=20
>> in the interim for 2.6.24?
>>
>=20
> I suppose I'll merge Eric's patch when I've tested it fully (well, as=
 fully
> as I test stuff).
>=20
> It'd be nice to get that cache_line_size()/L1_CACHE_BYTES/L1_CACHE_AL=
IGN()
> mess sorted out.  If it's a mess - I _think_ it is?

Just coming back from hollidays, sorry for the delay.

I can provide a patch so that L1_CACHE_BYTES is not anymore a compile t=
ime=20
constant if you want, but I am not sure it is worth the trouble ? (and =
this=20
certainly not 2.6.{24|25} stuff :) )

Current situation :

L1_CACHE_BYTES is known at compile time, and can be quite large (128 by=
tes),=20
while cache_line_size() gives the real cache line size selected at boot=
 time=20
given the hardware capabilities.

If L1_CACHE_BYTES is not anymore a constant, compiler will also uses pl=
ain=20
divides to compute L1_CACHE_ALIGN()

Maybe uses of L1_CACHE_ALIGN() in fastpath would 'force' us to not only=
=20
declare a cache_line_size() but also a cache_line_size_{mask|shift}() s=
o that=20
x86 could use :

#define L1_CACHE_ALIGN(x) ((((x)+cache_line_mask())) >> cache_line_shif=
t())

#define L1_CACHE_BYTES (cache_line_size())

But I am not sure we want to play these games (we must also make sure n=
othing=20
in the tree wants a constant L1_CACHE_BYTES and replace by SMP_CACHE_BY=
TES)


