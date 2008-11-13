From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] net: Convert TCP & DCCP hash tables to use RCU /
 hlist_nulls
Date: Thu, 13 Nov 2008 14:51:49 +0100
Message-ID: <491C30F5.4070904@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>	 <4909D551.9080309@cosmosbay.com>  <491C2873.60004@cosmosbay.com> <1226583265.7685.4797.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
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
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58299 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbYKMNxB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:53:01 -0500
In-Reply-To: <1226583265.7685.4797.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =E9crit :
> On Thu, 2008-11-13 at 14:15 +0100, Eric Dumazet wrote:
>> +begin:
>> +       sk_nulls_for_each_rcu(sk, node, &head->chain) {
>>                 if (INET_MATCH(sk, net, hash, acookie,
>> +                                       saddr, daddr, ports, dif)) {
>> +                       if (unlikely(!atomic_inc_not_zero(&sk->sk_re=
fcnt)))
>> +                               goto begintw;
>> +                       if (unlikely(!INET_MATCH(sk, net, hash, acoo=
kie,
>> +                               saddr, daddr, ports, dif))) {
>> +                               sock_put(sk);
>> +                               goto begin;
>> +                       }
>=20
> This is the validation step that verifies the race opened by using
> SLAB_DESTROY_BY_RCU, right?

The atomic_inc_not_zero() is not related to SLAB_DESTROY_BY_RCU but
classic RCU lookup. A writer can delete the item right before we try to=
 use it.

Next step is necessary in case the deleted item was re-allocated and in=
serted
in a hash chain (this one or another one, it doesnt matter). In this ca=
se,
previous atomic_inc_not_zero test will succeed. So we must check again =
the item
we selected (and refcounted) is the one we were searching.

So yes, this bit should be documented, since SLAB_DESTROY_BY_RCU is
not really used in linux kernel at this moment.


>=20
> Does it make sense to add a little comment to these validation steps =
to
> keep people on their toes and aware of the trickery?

Yes, you are right.

Thanks


