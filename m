From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Fri, 31 Oct 2008 20:10:56 -0700
Message-ID: <20081101031056.GA6955@linux.vnet.ibm.com>
References: <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <1225364660.7803.61.camel@twins> <49099ACC.3070600@cosmosbay.com> <20081030182513.GA6469@linux.vnet.ibm.com> <490B350E.3080401@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45075 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbYKADLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 23:11:01 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mA13AwwV026662
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 23:10:58 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA13AwVd115022
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 23:10:58 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA13AvXB029707
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 23:10:58 -0400
Content-Disposition: inline
In-Reply-To: <490B350E.3080401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 05:40:46PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Thu, Oct 30, 2008 at 12:30:20PM +0100, Eric Dumazet wrote:
>>> -		while (udp_lib_lport_inuse(net, snum, udptable, sk,
>>> -					   saddr_comp)) {
>>> +		for (;;) {
>>> +			hslot =3D &udptable->hash[udp_hashfn(net, snum)];
>>> +			spin_lock_bh(&hslot->lock);
>>> +			if (!udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
>>> +				break;
>>> +			spin_unlock_bh(&hslot->lock);
>>>  			do {
>>>  				snum =3D snum + rand;
>>>  			} while (snum < low || snum > high);
>> The above -really- confuses me, but not part of this patch.  If we a=
re
>> out of range, keep going?  Well, I guess that since it is a short, w=
e
>> cannot go very far...
>>>  			if (snum =3D=3D first)
>>>  				goto fail;
>> And I don't understand how we are guaranteed to have scanned all the
>> possible ports upon failure, but happy to leave that to you guys.
>
> Well, we have 65536(=3D2^16) possible port values, and while 'rand' i=
s=20
> random,
> it has the interesting property/bias of being odd.
>
> We know (thanks modular arithmetic / congruence relation) we will hit
> all 65356 values exactly once, after exactly 65536 iterations.

Ah, got it!  Thank you for the explanation!

I was fixating on the low..high interval.  ;-)

							Thanx, Paul
