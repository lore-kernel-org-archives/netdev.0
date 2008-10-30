From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist
 termination
Date: Thu, 30 Oct 2008 17:01:26 +0100
Message-ID: <1225382486.7803.129.camel@twins>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
	 <4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:58768 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756238AbYJ3QBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 12:01:19 -0400
In-Reply-To: <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-30 at 16:40 +0100, Eric Dumazet wrote:
> 
> [PATCH] udp: Introduce special NULL pointers for hlist termination
> 
> In order to safely detect changes in chains, we would like to have different
> 'NULL' pointers. Each chain in hash table is terminated by an unique 'NULL'
> value, so that the lockless readers can detect their lookups evaded from
> their starting chain.
> 
> We introduce a new type of hlist implementation, named hlist_nulls, were
> we use the least significant bit of the 'ptr' to tell if its a "NULL" value
> or a pointer to an object. We expect to use this new hlist variant for TCP
> as well.
> 
> For UDP/UDP-Lite hash table, we use 128 different "NULL" values,
> (UDP_HTABLE_SIZE=128)
> 
> Using hlist_nulls saves memory barriers (a read barrier to fetch 'next'
> pointers *before* checking key values) we added in commit 
> 96631ed16c514cf8b28fab991a076985ce378c26
> (udp: introduce sk_for_each_rcu_safenext())
> 
> This also saves a write memory barrier in udp_lib_get_port(), between
> sk->sk_hash update and sk->next update)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/linux/list_nulls.h    |   97 ++++++++++++++++++++++++++++++++
>  include/linux/rculist.h       |   17 -----
>  include/linux/rculist_nulls.h |   55 ++++++++++++++++++
>  include/net/sock.h            |   50 ++++++++++++----
>  include/net/udp.h             |    2
>  net/ipv4/udp.c                |   40 ++++++-------
>  net/ipv6/udp.c                |   22 ++++---
>  7 files changed, 228 insertions(+), 55 deletions(-)

If we're going to do this, It'd be good to have the list_nulls stuff in
their own patch, as clearly they are not UDP specific.

Also, I think it would be very good to have some extensive comments in
the list_nulls files describing their use in clear and concise language,
because the above changelog doesn't even begin to explain things for
those not following this thread.



