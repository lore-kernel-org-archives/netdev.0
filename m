From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 06:36:40 -0700
Message-ID: <1369229800.3301.332.camel@edumazet-glaptop>
References: <519B38EC.90401@yandex-team.ru>
	  <20130521120906.GD3578@linux.vnet.ibm.com>
	  <1369143885.3301.221.camel@edumazet-glaptop>
	  <519B8908.9080007@yandex-team.ru>
	  <1369150693.3301.233.camel@edumazet-glaptop>
	  <519BB90B.6080706@yandex-team.ru>
	  <1369188080.3301.268.camel@edumazet-glaptop>
	 <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru>
	 <1369225837.3301.324.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roman Gushchin <klamm@yandex-team.ru>, paulmck@linux.vnet.ibm.com,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:54665 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab3EVNgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 09:36:43 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 14:27 +0100, David Laight wrote:
> > So yes, the patch appears to fix the bug, but it sounds not logical to
> > me.
> 
> I was confused because the copy of the code I found was different
> (it has some checks for reusaddr - which force a function call in the
> loop).
> 
> The code being compiled is:
> 
> begin:
> 	result = NULL;
> 	badness = -1;
> 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {

Here this loops begin by

 someptr = rcu_dereference(somelocation);

May claim is rcu_dereference() should force the compiler to read again
somelocation. Its done thanks to ACCESS_ONCE(). But apparently in the
specific case of &hslot->head, it doesnt work.

When using head directly (ie the same value), the ACCESS_ONCE() does
correctly its job.


> 		score = compute_score2(sk, net, saddr, sport,
> 				      daddr, hnum, dif);
> 		if (score > badness) {
> 			result = sk;
> 			badness = score;
> 			if (score == SCORE2_MAX)
> 				goto exact_match;
> 		}
> 	}
> 	/*
> 	 * if the nulls value we got at the end of this lookup is
> 	 * not the expected one, we must restart lookup.
> 	 * We probably met an item that was moved to another chain.
> 	 */
> 	if (get_nulls_value(node) != slot2)
> 		goto begin;
> 
> Which is entirely inlined - so the compiler is allowed to assume
> that no other code modifies any of the data.

You missed the rcu_dereference()/ACCESS_ONCE() we have in this loop.
