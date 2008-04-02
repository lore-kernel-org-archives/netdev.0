From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] fib_trie: flush improvement
Date: Wed, 02 Apr 2008 10:01:06 +0200
Message-ID: <47F33D42.9080302@cosmosbay.com>
References: <20080401172702.094c0700@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.22]:41558 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583AbYDBIq3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 04:46:29 -0400
Received: from smtp25.orange.fr (mwinf2503 [10.232.9.25])
	by mwinf2525.orange.fr (SMTP Server) with ESMTP id AD6DA1C2C7D7
	for <netdev@vger.kernel.org>; Wed,  2 Apr 2008 10:01:47 +0200 (CEST)
In-Reply-To: <20080401172702.094c0700@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This is an attempt to fix the problem described in:
>      http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
> I can reproduce this by loading lots and lots of routes and the takin=
g
> the interface down. This causes all entries in trie to be flushed, bu=
t
> each leaf removal causes a rebalance of the trie. And since the remov=
al
> is depth first, it creates lots of needless work.
>
> Instead on flush, just walk the trie and prune as we go.
> The implementation is for description only, it probably doesn't work =
yet.
>
>  =20

I dont get it, since the bug reporter mentions with recent kernels :

=46ix inflate_threshold_root. Now=3D15 size=3D11 bits

Is it what you get with your tests ?

Pawel reports :

cat /proc/net/fib_triestat
Main: Aver depth: 2.26 Max depth: 6 Leaves: 235924
Internal nodes: 57854 1: 31632 2: 11422 3: 8475 4: 3755 5: 1676 6: 893=20
18: 1

Pointers: 609760 Null ptrs: 315983 Total size: 16240 kB

warning messages comes from rootnode that cannot be expanded, since it=20
hits MAX_ORDER (on a 32bit x86)



(sizeof(struct tnode) + (sizeof(struct node *) << bits);) is rounded to=
=20
4 << (bit + 1), ie 2 << 20

=46or larger allocations Pawel has two choices :

change MAX_ORDER from 11 to 13 or 14
If this machine is a pure router, this change wont have performance imp=
act.

Or (more difficult, but more appropriate for mainline) change fib_trie.=
c=20
to use vmalloc() for very big allocaions (for the root only), and vfree=
()

Since vfree() cannot be called from rcu callback, one has to setup a=20
struct work_struct helper.






