From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Slow OOM in netif_RX function
Date: Fri, 01 Feb 2008 14:16:42 +0100
Message-ID: <47A31BBA.8040307@cosmosbay.com>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Ivan Dichev <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.21]:44072 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641AbYBANQ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:16:56 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2529.orange.fr (SMTP Server) with ESMTP id D94A01C2D330
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2008 14:16:49 +0100 (CET)
In-Reply-To: <47A315DC.3070101@obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Dichev a =E9crit :
> Arnaldo Carvalho de Melo wrote:
>  =20
>> Em Fri, Jan 25, 2008 at 02:21:08PM +0100, Andi Kleen escreveu:
>>  =20
>>    =20
>>> "Ivan H. Dichev" <idichev@obs.bg> writes:
>>>    =20
>>>      =20
>>>> What could happen if I put different Lan card in every slot?
>>>> In ex. to-private -> 3com
>>>>       to-inet    -> VIA
>>>>       to-dmz     -> rtl8139
>>>> And then to look which RX function is consuming the memory.
>>>> (boomerang_rx, rtl8139_rx, ... etc)=20
>>>>      =20
>>>>        =20
>>> The problem is unlikely to be in the driver (these are both
>>> well tested ones) but more likely your complicated iptables setup s=
omehow
>>> triggers a skb leak.
>>>
>>> There are unfortunately no shrink wrapped debug mechanisms in the k=
ernel
>>> for leaks like this (ok you could enable CONFIG_NETFILTER_DEBUG=20
>>> and see if it prints something interesting, but that's a long shot)=
=2E
>>>
>>> If you wanted to write a custom debugging patch I would do somethin=
g like this:
>>>
>>> - Add two new integer fields to struct sk_buff: a time stamp and a =
integer field
>>> - Fill the time stamp with jiffies in alloc_skb and clear the integ=
er field
>>> - In __kfree_skb clear the time stamp
>>> - For all the ipt target modules in net/ipv4/netfilter/*.c you use =
change their=20
>>> ->target functions to put an unique value into the integer field yo=
u added.
>>> - Do the same for the pkt_to_tuple functions for all conntrack modu=
les
>>>
>>> Then when you observe the leak take a crash dump using kdump on the=
 router=20
>>> and then use crash to dump all the slab objects for the sk_head_cac=
he.
>>> Then look for any that have an old time stamp and check what value =
they
>>> have in the integer field. Then the netfilter function who set that=
 unique value=20
>>> likely triggered the leak somehow.
>>>    =20
>>>      =20
>> I wrote some systemtap scripts that do parts of what you suggest, an=
d at
>> least for the timestamp there was no need to add a new field to stru=
ct
>> sk_buff, I just reuse skb->timestamp, as it is only used when we use=
 a
>> packet sniffer. Here it is for reference, but it needs some tapsets =
I
>> wrote, so I'll publish this git repo in git.kernel.org, perhaps it c=
an
>> be useful in this case as a starting point. Find another unused fiel=
d
>> (hint: I know that at least 4 bytes on 64 bits is present as a hole)=
 and
>> you're done, no need to rebuild the kernel :)
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/acme/nettaps.git
>>
>> - Arnaldo
>>  =20
>>    =20
> Thanks to everyone for the given ideas.
> I am not kernel guru so writing patch is difficult. This is a product=
ion
> server and it is quite difficult to debug (only at night)
> I removed some iptables exotics -  recent , ulog, string , but no eff=
ect.
> Since we can reach OOM most of the memory is going to be filled with =
the
> leak, and we are thinking to try to dump and analyze it.
> We have looked at the "crash" tool, and we will see what we can do wi=
th
> it. Meanwhile do you have any hint/ideas ?
> Thanks a lot.
>
>  =20
I understand you dont want to tell us exact firewall rules you have.

Maybe you could post at least following infos :

# cat /proc/slabinfo
# lsmod




