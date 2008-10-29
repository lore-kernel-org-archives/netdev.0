From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 12:22:45 -0500
Message-ID: <49089BE5.3090705@acm.org>
References: <20081008.114527.189056050.davem@davemloft.net>
 <49077918.4050706@cosmosbay.com> <490795FB.2000201@cosmosbay.com>
 <20081028.220536.183082966.davem@davemloft.net>
 <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com>
 <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
 <20081029163739.GB6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:61598 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbYJ2RXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 13:23:08 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0K9I00COFG9ZNLY2@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Oct 2008 12:22:48 -0500 (CDT)
In-reply-to: <20081029163739.GB6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> On Wed, Oct 29, 2008 at 05:09:53PM +0100, Eric Dumazet wrote:
>  =20
>> Corey Minyard a =E9crit :
>>    =20
>>> Eric Dumazet wrote:
>>>      =20
>>>> Corey Minyard found a race added in commit=20
>>>> 271b72c7fa82c2c7a795bc16896149933110672d
>>>> (udp: RCU handling for Unicast packets.)
>>>>
>>>> "If the socket is moved from one list to another list in-between t=
he time=20
>>>>  the hash is calculated and the next field is accessed, and the so=
cket =20
>>>> has moved to the end of the new list, the traversal will not compl=
ete =20
>>>> properly on the list it should have, since the socket will be on t=
he end =20
>>>> of the new list and there's not a way to tell it's on a new list a=
nd =20
>>>> restart the list traversal.  I think that this can be solved by =20
>>>> pre-fetching the "next" field (with proper barriers) before checki=
ng the =20
>>>> hash."
>>>>
>>>> This patch corrects this problem, introducing a new=20
>>>> sk_for_each_rcu_safenext()
>>>> macro.
>>>>        =20
>>> You also need the appropriate smp_wmb() in udp_lib_get_port() after=
=20
>>> sk_hash is set, I think, so the next field is guaranteed to be chan=
ged=20
>>> after the hash value is changed.
>>>      =20
>> Not sure about this one Corey.
>>
>> If a reader catches previous value of item->sk_hash, two cases are t=
o be=20
>> taken into :
>>
>> 1) its udp_hashfn(net, sk->sk_hash) is !=3D hash   -> goto begin : R=
eader=20
>> will redo its scan
>>
>> 2) its udp_hashfn(net, sk->sk_hash) is =3D=3D hash
>>  -> next pointer is good enough : it points to next item in same has=
h=20
>> chain.
>>     No need to rescan the chain at this point.
>>     Yes we could miss the fact that a new port was bound and this UD=
P=20
>> message could be lost.
>>    =20
>
> 3) its udp_hashfn(net, sk-sk_hash) is =3D=3D hash, but only because i=
t was
> removed, freed, reallocated, and then readded with the same hash valu=
e,
> possibly carrying the reader to a new position in the same list.
>  =20
If I understand this, without the smp_wmb(), it is possible that the=20
next field can be written to main memory before the hash value is=20
written.  If that happens, the following can occur:

  CPU1                    CPU2
  next is set to NULL (end of new list)
                          fetch next
                          calculate hash and compare to sk_hash
  sk_hash is set to new value

So I think in the above cases, your case #2 is not necessarily valid=20
without the barrier.

And another possible issue.  If sk_hash is written before next, and CPU=
1=20
is interrupted before CPU2, CPU2 will continually spin on the list unti=
l=20
CPU1 comes back and moves it to the new list.  Note sure if that is an=20
issue.

-corey
