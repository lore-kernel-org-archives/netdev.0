From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Fri, 31 Oct 2008 17:40:46 +0100
Message-ID: <490B350E.3080401@cosmosbay.com>
References: <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <1225364660.7803.61.camel@twins> <49099ACC.3070600@cosmosbay.com> <20081030182513.GA6469@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34116 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbYJaQr7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 12:47:59 -0400
In-Reply-To: <20081030182513.GA6469@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Thu, Oct 30, 2008 at 12:30:20PM +0100, Eric Dumazet wrote:
>> -		while (udp_lib_lport_inuse(net, snum, udptable, sk,
>> -					   saddr_comp)) {
>> +		for (;;) {
>> +			hslot =3D &udptable->hash[udp_hashfn(net, snum)];
>> +			spin_lock_bh(&hslot->lock);
>> +			if (!udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
>> +				break;
>> +			spin_unlock_bh(&hslot->lock);
>>  			do {
>>  				snum =3D snum + rand;
>>  			} while (snum < low || snum > high);
>=20
> The above -really- confuses me, but not part of this patch.  If we ar=
e
> out of range, keep going?  Well, I guess that since it is a short, we
> cannot go very far...
>=20
>>  			if (snum =3D=3D first)
>>  				goto fail;
>=20
> And I don't understand how we are guaranteed to have scanned all the
> possible ports upon failure, but happy to leave that to you guys.

Well, we have 65536(=3D2^16) possible port values, and while 'rand' is =
random,
it has the interesting property/bias of being odd.

We know (thanks modular arithmetic / congruence relation) we will hit
all 65356 values exactly once, after exactly 65536 iterations.

