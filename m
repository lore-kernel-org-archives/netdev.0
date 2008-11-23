From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
Date: Sun, 23 Nov 2008 21:18:17 +0100
Message-ID: <4929BA89.2050501@cosmosbay.com>
References: <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C2873.60004@cosmosbay.com> <49292368.2060201@cosmosbay.com> <20081123155932.GB7932@linux.vnet.ibm.com> <4929A406.4070103@cosmosbay.com> <20081123191756.GC7932@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37260 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbYKWUTK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 15:19:10 -0500
In-Reply-To: <20081123191756.GC7932@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Sun, Nov 23, 2008 at 07:42:14PM +0100, Eric Dumazet wrote:
>> Paul E. McKenney a =E9crit :
>>> On Sun, Nov 23, 2008 at 10:33:28AM +0100, Eric Dumazet wrote:
>>>> Hi David
>>>>
>>>> Please find patch to convert TCP/DCCP listening hash tables
>>>> to RCU.
>>>>
>>>> A followup patch will cleanup all sk_node fields and macros
>>>> that are not used anymore.
>>>>
>>>> Thanks
>>>>
>>>> [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
>>>>
>>>> This is the last step to be able to perform full RCU lookups
>>>> in __inet_lookup() : After established/timewait tables, we
>>>> add RCU lookups to listening hash table.
>>>>
>>>> The only trick here is that a socket of a given type (TCP ipv4,
>>>> TCP ipv6, ...) can now flight between two different tables
>>>> (established and listening) during a RCU grace period, so we
>>>> must use different 'nulls' end-of-chain values for two tables.
>>>>
>>>> We define a large value :
>>>>
>>>> #define LISTENING_NULLS_BASE (1U << 29)
>>> I do like this use of the full set up upper bits!  However, wouldn'=
t it
>>> be a good idea to use a larger base value for 64-bit systems, perha=
ps
>>> using CONFIG_64BIT to choose?  500M entries might not seem like tha=
t
>>> many in a few years time...
>> Well, this value is correct up to 2^29 slots, and a hash table of 2^=
32=20
>> bytes
>> (8 bytes per pointer)
>>
>> A TCP socket uses about 1472 bytes on 64bit arches, so 2^29 sessions
>> would need 800 GB of ram, not counting dentries, inodes, ...
>>
>> I really doubt a machine, even with 4096 cpus should/can handle so m=
any
>> tcp sessions :)
>=20
> 200MB per CPU, right?
>=20
> But yes, now that you mention it, 800GB of memory dedicated to TCP
> connections sounds almost as ridiculous as did 640K of memory in the
> late 1970s.  ;-)

;)

>=20
> Nevertheless, I don't have an overwhelming objection to the current
> code.  Easy enough to change should it become a problem, right?

Sure. By that time, cpus might be 128 bits or 256 bits anyway :)


