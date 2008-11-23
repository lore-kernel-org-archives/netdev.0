From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
Date: Sun, 23 Nov 2008 11:17:56 -0800
Message-ID: <20081123191756.GC7932@linux.vnet.ibm.com>
References: <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C2873.60004@cosmosbay.com> <49292368.2060201@cosmosbay.com> <20081123155932.GB7932@linux.vnet.ibm.com> <4929A406.4070103@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
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
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:44102 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbYKWTR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 14:17:56 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mANJHefk025130
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 14:17:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mANJHtPr164582
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 14:17:55 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mANKI2c8023229
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 15:18:04 -0500
Content-Disposition: inline
In-Reply-To: <4929A406.4070103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2008 at 07:42:14PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
>> On Sun, Nov 23, 2008 at 10:33:28AM +0100, Eric Dumazet wrote:
>>> Hi David
>>>
>>> Please find patch to convert TCP/DCCP listening hash tables
>>> to RCU.
>>>
>>> A followup patch will cleanup all sk_node fields and macros
>>> that are not used anymore.
>>>
>>> Thanks
>>>
>>> [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
>>>
>>> This is the last step to be able to perform full RCU lookups
>>> in __inet_lookup() : After established/timewait tables, we
>>> add RCU lookups to listening hash table.
>>>
>>> The only trick here is that a socket of a given type (TCP ipv4,
>>> TCP ipv6, ...) can now flight between two different tables
>>> (established and listening) during a RCU grace period, so we
>>> must use different 'nulls' end-of-chain values for two tables.
>>>
>>> We define a large value :
>>>
>>> #define LISTENING_NULLS_BASE (1U << 29)
>> I do like this use of the full set up upper bits!  However, wouldn't=
 it
>> be a good idea to use a larger base value for 64-bit systems, perhap=
s
>> using CONFIG_64BIT to choose?  500M entries might not seem like that
>> many in a few years time...
>
> Well, this value is correct up to 2^29 slots, and a hash table of 2^3=
2=20
> bytes
> (8 bytes per pointer)
>
> A TCP socket uses about 1472 bytes on 64bit arches, so 2^29 sessions
> would need 800 GB of ram, not counting dentries, inodes, ...
>
> I really doubt a machine, even with 4096 cpus should/can handle so ma=
ny
> tcp sessions :)

200MB per CPU, right?

But yes, now that you mention it, 800GB of memory dedicated to TCP
connections sounds almost as ridiculous as did 640K of memory in the
late 1970s.  ;-)

Nevertheless, I don't have an overwhelming objection to the current
code.  Easy enough to change should it become a problem, right?

						Thanx, Paul
