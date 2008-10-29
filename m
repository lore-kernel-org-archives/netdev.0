From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 14:58:12 -0700
Message-ID: <20081029215812.GH6732@linux.vnet.ibm.com>
References: <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908D5AF.4060204@acm.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:40475 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668AbYJ2V6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 17:58:14 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9TLskd5032648
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 17:54:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TLwDhr124510
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 17:58:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TLwBGq026316
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 17:58:13 -0400
Content-Disposition: inline
In-Reply-To: <4908D5AF.4060204@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 04:29:19PM -0500, Corey Minyard wrote:
> Paul E. McKenney wrote:
>> O
> ..snip
>>> Hum... Another way of handling all those cases and avoid memory barriers
>>> would be to have different "NULL" pointers.
>>>
>>> Each hash chain should have a unique "NULL" pointer (in the case of UDP, 
>>> it
>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>>
>>> Then, when performing a lookup, a reader should check the "NULL" pointer
>>> it get at the end of its lookup has is the "hash" value of its chain.
>>>
>>> If not -> restart the loop, aka "goto begin;" :)
>>>
>>> We could avoid memory barriers then.
>>>
>>> In the two cases Corey mentioned, this trick could let us avoid memory 
>>> barriers.
>>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)
>>>
>>> What do you think ?
>>>     
>>
>> Kinky!!!  ;-)
>>   
> My thought exactly ;-).
>
>> Then the rcu_dereference() would be supplying the needed memory barriers.
>>
>> Hmmm...  I guess that the only confusion would be if the element got
>> removed and then added to the same list.  But then if its pointer was
>> pseudo-NULL, then that would mean that all subsequent elements had been
>> removed, and all preceding ones added after the scan started.
>>
>> Which might well be harmless, but I must defer to you on this one at
>> the moment.
>>   
> I believe that is harmless, as re-scanning the same data should be fine.
>
>> If you need a larger hash table, another approach would be to set the
>> pointer's low-order bit, allowing the upper bits to be a full-sized
>> index -- or even a pointer to the list header.  Just make very sure
>> to clear the pointer when freeing, or an element on the freelist
>> could end up looking like a legitimate end of list...  Which again
>> might well be safe, but why inflict this on oneself?
>>   
> Kind of my thought, too.  That's a lot of work to avoid a single smb_wmb() 
> on the socket creation path.  Plus this could be extra confusing.

Just to be clear, I was fulminating against any potential failure to
clear the pseudo-NULL pointer, not against the pseudo-pointer itself.
This sort of trick is already used in some of the RCU-protected trees
(for example, FIB tree, IIRC), so I would look a bit funny fulminating
too hard against it.  ;-)

The only other high-level approach I have come up with thus far is to
maintain separate hash tables for the long-lived UDP sockets (protected
by RCU) and for the short-lived UDP sockets (protected by locking).
Given the usual bimodal traffic pattern, most of the sockets are short
lived, but most of the data is transmitted over long-lived sockets.  If a
socket receives more than N packets (10? 50? 100?), it is moved from the
short-lived table to the long-lived table.  Sockets on the short-lived
table may be freed directly, while sockets on the long-lived table must
be RCU freed -- but this added overhead should be in the noise for a
long-lived connection.  Lookups hit the RCU-protected table, then the lock
protected table, then the RCU-protected table again, but still holding
the lock.  (Clearly, only search until you find the desired socket.)

However, I am not certain that this short-term/long-term approach is
better than the approach that Eric is proposing.  It might in fact be
worse.  But I throw it out anyway on the off-chance that it is helpful
as a comparison or as a solution to some future problem.

							Thanx, Paul
