From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 16:29:19 -0500
Message-ID: <4908D5AF.4060204@acm.org>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
 <20081029201759.GF6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173007pub.verizon.net ([206.46.173.7]:43984 "EHLO
	vms173007pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbYJ2V3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:29:45 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms173007.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0K9I000LIRNGZ2X4@vms173007.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Oct 2008 16:28:29 -0500 (CDT)
In-reply-to: <20081029201759.GF6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> O
..snip
>> Hum... Another way of handling all those cases and avoid memory barriers
>> would be to have different "NULL" pointers.
>>
>> Each hash chain should have a unique "NULL" pointer (in the case of UDP, it
>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>>
>> Then, when performing a lookup, a reader should check the "NULL" pointer
>> it get at the end of its lookup has is the "hash" value of its chain.
>>
>> If not -> restart the loop, aka "goto begin;" :)
>>
>> We could avoid memory barriers then.
>>
>> In the two cases Corey mentioned, this trick could let us avoid memory 
>> barriers.
>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be enough)
>>
>> What do you think ?
>>     
>
> Kinky!!!  ;-)
>   
My thought exactly ;-).

> Then the rcu_dereference() would be supplying the needed memory barriers.
>
> Hmmm...  I guess that the only confusion would be if the element got
> removed and then added to the same list.  But then if its pointer was
> pseudo-NULL, then that would mean that all subsequent elements had been
> removed, and all preceding ones added after the scan started.
>
> Which might well be harmless, but I must defer to you on this one at
> the moment.
>   
I believe that is harmless, as re-scanning the same data should be fine.

> If you need a larger hash table, another approach would be to set the
> pointer's low-order bit, allowing the upper bits to be a full-sized
> index -- or even a pointer to the list header.  Just make very sure
> to clear the pointer when freeing, or an element on the freelist
> could end up looking like a legitimate end of list...  Which again
> might well be safe, but why inflict this on oneself?
>   
Kind of my thought, too.  That's a lot of work to avoid a single 
smb_wmb() on the socket creation path.  Plus this could be extra confusing.

-corey
