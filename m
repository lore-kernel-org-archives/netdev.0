From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 3/3] net: Convert TCP & DCCP hash tables to use RCU /
 hlist_nulls
Date: Thu, 13 Nov 2008 15:22:28 +0100
Message-ID: <1226586148.7685.4915.camel@twins>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
		 <4909D551.9080309@cosmosbay.com> <491C2873.60004@cosmosbay.com>
	 <1226583265.7685.4797.camel@twins> <491C30F5.4070904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:53656 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYKMOWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 09:22:48 -0500
In-Reply-To: <491C30F5.4070904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 14:51 +0100, Eric Dumazet wrote:
> Peter Zijlstra a =C3=A9crit :
> > On Thu, 2008-11-13 at 14:15 +0100, Eric Dumazet wrote:
> >> +begin:
> >> +       sk_nulls_for_each_rcu(sk, node, &head->chain) {
> >>                 if (INET_MATCH(sk, net, hash, acookie,
> >> +                                       saddr, daddr, ports, dif))=
 {
> >> +                       if (unlikely(!atomic_inc_not_zero(&sk->sk_=
refcnt)))
> >> +                               goto begintw;
> >> +                       if (unlikely(!INET_MATCH(sk, net, hash, ac=
ookie,
> >> +                               saddr, daddr, ports, dif))) {
> >> +                               sock_put(sk);
> >> +                               goto begin;
> >> +                       }
> >=20
> > This is the validation step that verifies the race opened by using
> > SLAB_DESTROY_BY_RCU, right?
>=20
> The atomic_inc_not_zero() is not related to SLAB_DESTROY_BY_RCU but
> classic RCU lookup. A writer can delete the item right before we try =
to use it.

Yeah, its to stabilize the current situation.

> Next step is necessary in case the deleted item was re-allocated and =
inserted
> in a hash chain (this one or another one, it doesnt matter). In this =
case,
> previous atomic_inc_not_zero test will succeed. So we must check agai=
n the item
> we selected (and refcounted) is the one we were searching.
>=20
> So yes, this bit should be documented, since SLAB_DESTROY_BY_RCU is
> not really used in linux kernel at this moment.

We have one user, anon_vma, and one thing that is very nearly identical
the lockless pagecache.

See page_cache_get_speculative() and find_get_page(). The pagecache get=
s
away with this due to the simple fact that the page frames are never
freed.

Hmm, I once wrote a comment to go with SLAB_DESTROY_BY_RCU, which seems
to have gotten lost... /me goes dig.

=46ound it:  http://lkml.org/lkml/2008/4/2/143

I guess I'd better re-submit that..

