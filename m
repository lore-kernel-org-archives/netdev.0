From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Fri, 21 Nov 2014 10:54:11 -0800
Message-ID: <29850.1416596051@famine>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com> <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com> <546C4022.5010509@oracle.com> <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com> <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com> <1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com> <1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com> <23563.1416523985@famine> <CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Wengang <wen.gang.wang@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36021 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaKUSyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 13:54:17 -0500
In-reply-to: <CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> wrote:

>On Thu, Nov 20, 2014 at 2:53 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
>> Cong Wang <cwang@twopensource.com> wrote:
>>
>>>Also, no one seems to care about my previous question:
>>>why only bonding has the problem?
>>
>>         Bonding has the problem because it stashes a pointer to a data
>> structure (the header_ops) from another module, and when that module is
>> unloaded the dangling pointer may be dereferenced if it's not either
>> cleared or made to never go away.
>
>I knew, please re-read my question, I was asking why ONLY bonding
>has the problem, i.e. why not neigh or whatever else calling
>header_ops->foo()? :)
>
>As I said, I may miss some try_get_module() somewhere of course.
>Needs more digging.

	My explanation is why only bonding has the problem; it's keeping
a pointer (in bond_dev->header_ops) that is copied from the slave
device's ->header_ops, and clearing that stashed pointer is (a) not
correctly synchronized with the removal of the slave device, and (b)
trying to simply clear the pointer has a check then use race in
dev_hard_header.

	8021q, for example, uses a "passthru" header_ops to call the
underlying device's header_ops, but 8021q is only for ethernet, and the
eth_header_ops are static in vmlinux, so it won't see these problems.

	Actually, now that I think about it, when the last ipoib slave
is released, the bonding master device is theoretically supposed to be
removed to avoid the sort of problem we're discussing here.

	That apparently isn't happening, unless Wengang is running
pktgen and simultaneously removing the ipoib module (racing the transmit
against the removal), or maybe something else is going on (perhaps
pktgen holds a reference to the bonding master, preventing its removal).

	Also, curiously, looking at pkgten, pktgen_setup_dev appears to
only accept devices of type ARPHRD_ETHER, but bonding with an ipoib
slave would be ARPHRD_INFINIBAND.  I'm therefore not sure how Wengang
configured pktgen over an ipoib bond.

	Wengang, what kernel are you using, and is your kernel modified
to change pktgen_setup_dev?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
