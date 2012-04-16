From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Netlink, route monitoring, =?UTF-8?Q?RTM=5FDELROUTE=20not=20i?=
 =?UTF-8?Q?ssued=20for=20ppp=20peer=20address=2E=20Bug=20or=20feature=3F?=
Date: Mon, 16 Apr 2012 19:48:21 +0300
Message-ID: <9c375f4b88835bcde92bf3ba8f3434cc@visp.net.lb>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
 <023e01cd197d$a9faba40$fdf02ec0$@no>
 <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
 <20120416081954.1bb994db@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stian Skjelstad <stian@nixia.no>, <eric.dumazet@gmail.com>,
	<stephen.hemminger@vyatta.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:49932 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297Ab2DPQsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 12:48:25 -0400
In-Reply-To: <20120416081954.1bb994db@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-04-16 18:19, Stephen Hemminger wrote:
> On Mon, 16 Apr 2012 13:37:14 +0300
> Denys Fedoryshchenko <denys@visp.net.lb> wrote:
>
>> After digging the code, i came to conclusion:
>> fib_del_ifaddr, will check if deleted address are exist as prefsrc 
>> or
>> interface are shut down, they will do fi->fib_flags |= RTNH_F_DEAD;
>> Then fib_flush -> fib_table_flush -> trie_flush_leaf -> 
>> trie_flush_list
>> will delete such routes.
>> But trie_flush_list won't notify over netlink that route are 
>> deleted.
>>
>> So the only solution is to fetch first, then keep full routing table 
>> in
>> userspace also, and keep tracking if local addresses deleted, and do 
>> the
>> same in userspace and check for prefsrc...
>>
>> Maybe it should be fixed? E.g. netlink message sent when any route 
>> are
>> deleted, even over the flush
>>
>> On 2012-04-13 16:59, Stian Skjelstad wrote:
>> > I've seen the same issue, and got no response so far to that very
>> > same question. Have you tested this on older kernels? I have 
>> worked
>> > around this issue by testing my local copy of routing entries that
>> > use
>> > 'via'. If they are not routable when after the RTM_DELROUTE event, 
>> I
>> > autoremove them from my local copy.
>> >
>> > Stian Skjelstad
>> >
>
>
> Looking at Quagga, it knows that deleting interface address
> removes connected routes and silently cleans up.
>
> You have to be really careful here making any changes to not break
> applications that expect existing behavior.
It looks like "correct" behavior should not harm existing programs that 
much (just there will be netlink message to delete route that are 
already deleted by program, e.g. quagga), but looking to code, 
implementing this feature will make significant overhead and in some 
cases it can be harmful.
For example if full view BGP interface dropped, it is hundreds of 
thousands netlink messages. So seems better i will listen to 
address/link changes also and keep routing table in memory.
So better seems to keep as is.
