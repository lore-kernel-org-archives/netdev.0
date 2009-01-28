From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Wed, 28 Jan 2009 18:07:13 +0100
Message-ID: <498090C1.5020400@cosmosbay.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37050 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZA1RHW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 12:07:22 -0500
In-Reply-To: <49808708.3050502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Rick Jones a =E9crit :
>>> Anyhow, the spread on trans/s/netperf is now 600 to 500 or 6000, wh=
ich
>>> does represent an improvement.
>>>
>>
>> Yes indeed you have a speedup, tcp conntracking is OK.
>>
>> You now hit the nf_conntrack_lock spinlock we have in generic
>> conntrack code (net/netfilter/nf_conntrack_core.c)
>>
>> nf_ct_refresh_acct() for instance has to lock it.
>>
>> We really want some finer locking here.
>=20
> That looks more complicated since it requires to take multiple locks
> occasionally (f.i. hash insertion, potentially helper-related and
> expectation-related stuff), and there is the unconfirmed_list, where
> fine-grained locking can't really be used without changing it to
> a hash.
>

Yes its more complicated, but look what we did in 2.6.29 for tcp/udp
 sockets, using RCU to have lockless lookups.
Yes, we still take a lock when doing an insert or delete at socket
bind/unbind time.

We could keep a central nf_conntrack_lock to guard insertions/deletes
from hash and unconfirmed_list.

But *normal* packets that only need to change state of one particular
connection could use RCU (without spinlock) to locate the conntrack,
then lock the found conntrack to perform all state changes.


