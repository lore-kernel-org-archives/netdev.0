From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 11 Jul 2016 18:17:39 -0300
Message-ID: <CAB9dFdv8zzODKMr2Ane8jSKxNhJdDMyPZ8YaYJqL1cW0TFOO4g@mail.gmail.com>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc> <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc> <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
 <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
 <20160705122803.GA26862@salvia> <CAB9dFdv_ShA2cSez7Ut31XnW7OWufV59bfG-zN4Z0K3CgPvwuA@mail.gmail.com>
 <20160711162642.GA5462@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Thorsten Leemhuis <regressions@leemhuis.info>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33424 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbcGKVRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:17:45 -0400
In-Reply-To: <20160711162642.GA5462@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 1:26 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Sun, Jul 10, 2016 at 04:48:26PM -0300, Marc Dionne wrote:
>> An update here since I've had some interactions with Pablo off list.
>>
>> Further testing shows that the underlying cause of the different test
>> results is a udp packet that has a bogus source port number.  In the
>> test the server process tries to send an ack to the bogus port and the
>> flow is disrupted.
>>
>> Notes:
>> - The packet with the bad source port is from a sendmsg() call that
>> has hit the connection tracker clash code introduced by 71d8c47fc653
>> - Packets are successfully sent after the bad one, from the same
>> socket, with the correct source port number
>> - The problem does not reproduce with 71d8c47fc653 reverted, or
>> without nf_conntrack loaded
>> - The bogus port numbers start at 1024, bumping up by 1 every few
>> times the problem occurs (1025, 1026, etc.)
>> - The patch above does not change the behaviour
>> - Enabling lockdep does not show anything
>>
>> Our workaround for the original race was to retry sendmsg() once on
>> EPERM errors, and that had been effective.
>> I can trigger the insertion clash easily with some simple test code,
>> but I have not been able so far to reproduce the packets with bad
>> source port numbers with some simpler code that I could share.
>
> The NAT nul-binding is triggering the source port mangling, even if
> there is no NAT rules in place. The following patch skips the clash
> resolution for NAT by now since we don't see a simple solution for
> this case at the moment.
>
> Could you give a try to this patch in these two cases?
>
> 1) No NAT in place: Make sure iptable_nat module is not there. Or if
>    you're using nf_tables, just make sure you have no nat chains at
>    all.
>
> 2) With NAT in place, you hit back the EPERM errors that you've
>    observed so far.
>
> Please, test both scenarios and report back. Thanks.

Hi Pablo,

Testing out your patch:

1) With no NAT in place, the clash resolution happens, with no side
effects.  No EPERM errors are seen.

2) With ip(6)table_nat loaded, the clash resolution fails and I get
some EPERM errors from sendmsg(), same as before 71d8c47fc653.

Turns out that even though I have no NAT rules in my iptables config,
the system also had firewalld active and that caused the modules to be
loaded.

So the bottom line is that the patch looks good to me..

Thanks,
Marc
