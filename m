From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Sun, 08 Mar 2015 23:22:27 -0700
Message-ID: <54FD3C23.2010002@cumulusnetworks.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com> <1425619280-27492-3-git-send-email-sfeldma@gmail.com> <54F9BFCB.5030100@mojatatu.com> <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com> <54FC5D56.3090702@cumulusnetworks.com> <CAE4R7bCzV5zG5XPpgDAhO41Ym19W7Jd+97CMcJzOwwxLNOhTzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35849 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbCIGW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 02:22:29 -0400
Received: by pdbnh10 with SMTP id nh10so68977089pdb.3
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 23:22:28 -0700 (PDT)
In-Reply-To: <CAE4R7bCzV5zG5XPpgDAhO41Ym19W7Jd+97CMcJzOwwxLNOhTzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/8/15, 3:16 PM, Scott Feldman wrote:
> On Sun, Mar 8, 2015 at 7:31 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/6/15, 11:59 AM, Scott Feldman wrote:
>>>
>>> I considered passing netlink flags in to driver, but the kernel logic
>>> in fib_table_insert() already takes care of the checks required by the
>>> flags, and from the driver's perspective, only three ops are needed:
>>> add, del, and mod.  And I've combined add and mod into the same op,
>>> with the assumption the driver can know if an entry exists or not.
>>>
>>> Can it work?
>>>
>>> Let's try the various user cmds and see what happens:
>>>
>>> ip route add ...             CREATE|EXCL
>>>
>>>       if kernel FIB entry exists
>>>           return -EEXIST to user
>>>       else
>>>           call driver add op
>>>           add kernel FIB entry
>>>
>>> ip route change ...        REPLACE
>>>
>>>       if kernel FIB entry exists
>>>           call driver add op             // driver treats this as a mod
>>>           modify kernel FIB entry
>>>       else
>>>           return -ENOENT
>>>
>>> ip route replace ...         CREATE|REPLACE
>>>
>>>       if kernel FIB entry exists
>>>            call driver add op             // driver treats this as a mod
>>>            modify kernel FIB entry
>>>       else
>>>           call driver add op
>>>           add kernel FIB entry
>>>
>>> ip route prepend ...        CREATE
>>>
>>>       if kernel FIB entry exists
>>>            call driver add op             // driver treats this as a mod
>>>            prepend kernel FIB entry
>>>       else
>>>           call driver add op
>>>           add kernel FIB entry
>>>
>>> ip route append ...          CREATE|APPEND
>>>
>>>       if kernel FIB entry exists
>>>            call driver add op             // driver treats this as a mod
>>>            append kernel FIB entry
>>>       else
>>>           call driver add op
>>>           add kernel FIB entry
>>>
>>>
>>> I'm not 100% on the prepend/append cases.  Maybe don't try to offload
>>> prepend/append cases?
>> We will have to offload prepend/append cases as well (I had also raised this
>> earlier in v2).
> Can you show an working example of prepend/append case where
> programming hardware would be different than the replace case?
>
>
scott, I don't have an example of kernel vs hw right now. But, since we 
only want to know if the switch driver can figure out
the kernel route ordering in case of append vs replace, below kernel 
append and replace examples
might help (just pasting it from my notes and may contain unneeded 
information).

Thanks,
Roopa

append:

=====

#ipv4

ip route show

10.0.12.2

     nexthop via 10.0.13.2  dev dummy0 weight 1

     nexthop via 10.0.14.2  dev dummy1 weight 1


ip route append 10.0.12.2 nexthop via 10.0.15.2 dev dummy2


ip monitor route

10.0.12.2 via 10.0.15.2 dev dummy2


# A new route was appended

ip route show

10.0.12.2

     nexthop via 10.0.13.2  dev dummy0 weight 1

     nexthop via 10.0.14.2  dev dummy1 weight 1

10.0.12.2 via 10.0.15.2 dev dummy2


#ipv6


ip -6 route show

3ffe:304:124:2306::/64 via fe80::b077:f0ff:fe23:5cc7 dev dummy0 metric 1024

3ffe:304:124:2306::/64 via fe80::d850:e7ff:fe87:cf6a dev dummy1 metric 1024


ip monitor route

3ffe:304:124:2306::/64 via fe80::c26:cdff:feca:18f2 dev dummy2 metric 1024


ip -6 route append 3ffe:304:124:2306::/64 nexthop via 
fe80::c26:cdff:feca:18f2 dev dummy2


# A new nexthop was appended to the existing multipath route

ip -6 route show

3ffe:304:124:2306::/64 via fe80::b077:f0ff:fe23:5cc7 dev dummy0 metric 1024

3ffe:304:124:2306::/64 via fe80::d850:e7ff:fe87:cf6a dev dummy1 metric 1024

3ffe:304:124:2306::/64 nexthop via fe80::c26:cdff:feca:18f2 dev dummy2


replace:

=====

# ip route show

10.0.12.2

     nexthop via 10.0.13.2  dev dummy0 weight 1

     nexthop via 10.0.14.2  dev dummy1 weight 1

#ip route replace 10.0.12.2 nexthop via 10.0.15.2 dev dummy2

#ip monitor route

10.0.12.2 via 10.0.15.2 dev dummy2

# ipv4 route was replaced

ip route show

10.0.12.2 via 10.0.15.2 dev dummy2

#ipv6

ip -6 route show

3ffe:304:124:2306::/64 via fe80::b077:f0ff:fe23:5cc7 dev dummy0 metric 1024

3ffe:304:124:2306::/64 via fe80::d850:e7ff:fe87:cf6a dev dummy1 metric 1024

ip -6 route replace 3ffe:304:124:2306::/64 nexthop via 
fe80::c26:cdff:feca:18f2 dev dummy2

ip monitor route

3ffe:304:124:2306::/64 via fe80::c26:cdff:feca:18f2 dev dummy2 metric 1024

# ipv6 nexthop was replaced

ip -6 route show

3ffe:304:124:2306::/64 via fe80::c26:cdff:feca:18f2 dev dummy2 metric 1024

3ffe:304:124:2306::/64 via fe80::d850:e7ff:fe87:cf6a dev dummy1 metric 1024
