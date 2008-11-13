From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 3/3] net: Convert TCP & DCCP hash tables to use RCU /
 hlist_nulls
Date: Thu, 13 Nov 2008 14:34:25 +0100
Message-ID: <1226583265.7685.4797.camel@twins>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
	 <4909D551.9080309@cosmosbay.com>  <491C2873.60004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
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
Received: from viefep18-int.chello.at ([213.46.255.22]:63487 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbYKMNep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:34:45 -0500
In-Reply-To: <491C2873.60004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 14:15 +0100, Eric Dumazet wrote:
> +begin:
> +       sk_nulls_for_each_rcu(sk, node, &head->chain) {
>                 if (INET_MATCH(sk, net, hash, acookie,
> +                                       saddr, daddr, ports, dif)) {
> +                       if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
> +                               goto begintw;
> +                       if (unlikely(!INET_MATCH(sk, net, hash, acookie,
> +                               saddr, daddr, ports, dif))) {
> +                               sock_put(sk);
> +                               goto begin;
> +                       }

This is the validation step that verifies the race opened by using
SLAB_DESTROY_BY_RCU, right?

Does it make sense to add a little comment to these validation steps to
keep people on their toes and aware of the trickery?

> +                       goto out;
> +               }
>         }
> +       /*
> +        * if the nulls value we got at the end of this lookup is
> +        * not the expected one, we must restart lookup.
> +        * We probably met an item that was moved to another chain.
> +        */
> +       if (get_nulls_value(node) != slot)
> +               goto begin;
>  

