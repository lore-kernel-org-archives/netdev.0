From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 17:07:37 +0200
Message-ID: <48EB7B39.1020607@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org> <20081007143346.GA6384@linux.vnet.ibm.com> <48EB7617.3060304@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:35518 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbYJGPHq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:07:46 -0400
In-Reply-To: <48EB7617.3060304@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Paul E. McKenney wrote:
>=20
>> But care is required -- SLAB_DESTROY_BY_RCU permits objects to be fr=
eed
>> and reallocated while a reader holds a reference.  The only guarante=
e is
>> that the -type- of the data structure will not change while a reader=
 holds
>> a reference.  With something like UDP, this might well be sufficient=
=2E
>=20
> Right so after the hash lookup operation you are not assured that the=
 object
> has not been freed or even reallocated for a different purpose. So af=
ter
> finding the pointer to the object two things need to happen (under rc=
u_lock):
>=20
> 1. Verify that the object is still in use
> 2. Verify that the object is matching the hash
>=20
> If not then the operation needs to be redone because we have a stale =
hash pointer.

OK... so restart full lookup at the begining of hash chain if we detect
points 1 or 2 invalid.

Not that expensive since everything should be cache hot :)

One has to take care to group all components (keys to compute the hash,=
=20
and the *next* pointer) in one cache line to minimize cache misses,
since we now need to access them all to compute/check hash value.

Now if a freed object is re-inserted with same hash value,=20
same hash chain, we'll also restart the lookup, but it is harmless.




