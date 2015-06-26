From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: netlink & rhashtable status
Date: Fri, 26 Jun 2015 13:44:04 +0300
Message-ID: <558D2CF4.5070503@yandex-team.ru>
References: <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com> <20150513062038.GA26944@gondor.apana.org.au> <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com> <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com> <20150514025333.GA3853@gondor.apana.org.au> <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com> <20150514033448.GA5080@gondor.apana.org.au> <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com> <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com> <20150514041628.GA5428@gondor.apana.org.au> <20150514042151.GA5482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:47819 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbbFZKoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 06:44:09 -0400
In-Reply-To: <20150514042151.GA5482@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.05.2015 07:21, Herbert Xu wrote:
> On Thu, May 14, 2015 at 12:16:28PM +0800, Herbert Xu wrote:
>> On Wed, May 13, 2015 at 09:13:38PM -0700, Eric Dumazet wrote:
>>>
>>> So it looks like we lost an skb or something....
>>
>> OK that sounds reasonable.  So my plan is to disable dynamic
>> rehashing and then hunt down this lookup bug.
>
> Oh wait this isn't even a lookup failure since that should return
> ECONNREFUSED.  Could it be that this hang is a separate bug that's
> not related to rhashtable?

Hang in getaddrinfo is a bug in libc: function make_request in
sysdeps/unix/sysv/linux/check_pf.c ignores NLMSG_ERROR
(as well as messsages with nlmh->nlmsg_pid != pid)

It hangs forever in case of any error or netlink pid collision.
And I've seen ECONNREFUSED in message buffer when connected to hang
process with gdb.


I've found race in v3.18 in __netlink_lookup: rhashtable_hashfn
computes hash using one table and following rhashtable_lookup_compare
dereferences ht->tbl once again and could see different table.

patch follows...

>
> If that was the case then we simply need to get rid of dynamic
> rehashing.
>
> Cheers,
>
