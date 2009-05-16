From: Chase Douglas <chasedouglas.lists@gmail.com>
Subject: Re: neigh_params_release() usage in net/ipv6/addrconf.c
Date: Sat, 16 May 2009 18:57:22 -0400
Message-ID: <1A56FDAE-2ECF-4D1C-BAC4-D59594BFB62A@gmail.com>
References: <8A0B031A-1483-49FD-A4AD-CA4EA87E9359@gmail.com> <4A0F3B0F.2070209@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:21776 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbZEPW5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 18:57:25 -0400
Received: by qw-out-2122.google.com with SMTP id 5so2050419qwd.37
        for <netdev@vger.kernel.org>; Sat, 16 May 2009 15:57:26 -0700 (PDT)
In-Reply-To: <4A0F3B0F.2070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 16, 2009, at 6:15 PM, Jarek Poplawski wrote:
> Chase Douglas wrote, On 05/15/2009 06:33 PM:
>
>> I'm debugging an issue I'm seeing when I use vlan with IPv6 support.
>> After bringing up the device, I'm unable to bring it down and
>> unregister it. I put some debug statements around dev_hold() and
>> dev_put() to see what was going on:
>>
>> dev_hold() called on lo.2, new refcnt: 1 (net/core/dev.c:4162)
>> dev_hold() called on lo.2, new refcnt: 2 (net/core/neighbour.c:1357)
>> dev_hold() called on lo.2, new refcnt: 3 (net/ipv4/devinet.c:178)
>> dev_hold() called on lo.2, new refcnt: 4 (net/core/neighbour.c:1357)
>> dev_hold() called on lo.2, new refcnt: 5 (net/8021q/vlan.c:266)
>> dev_hold() called on lo.2, new refcnt: 6 (net/core/link_watch.c:219)
>> dev_put()  called on lo.2, new refcnt: 5 (net/core/link_watch.c:191)
>> dev_hold() called on lo.2, new refcnt: 6 (net/core/dev.c:684)
>> dev_put()  called on lo.2, new refcnt: 5 (net/ipv4/fib_semantics.c: 
>> 149)
>> dev_hold() called on lo.2, new refcnt: 6 (net/core/dev.c:684)
>> dev_hold() called on lo.2, new refcnt: 7 (net/ipv4/fib_frontend.c: 
>> 173)
>> dev_put()  called on lo.2, new refcnt: 6 (net/ipv4/route.c:2453)
>> dev_put()  called on lo.2, new refcnt: 5 (net/ipv4/fib_semantics.c: 
>> 149)
>> dev_put()  called on lo.2, new refcnt: 4 (net/core/neighbour.c:1393)
>> dev_put()  called on lo.2, new refcnt: 3 (net/ipv4/devinet.c:151)
>> dev_put()  called on lo.2, new refcnt: 2 (net/core/dev.c:4010)
>> dev_put()  called on lo.2, new refcnt: 1 (net/8021q/vlan.c:182)
>> unregister_netdevice: waiting for lo.2 to become free. Usage count  
>> = 2
>>
>> The fourth dev_hold() is in neigh_parms_alloc(), called by
>> ipv6_add_dev(). The only place I see neigh_parms_release() called in
>> addrconf.c is if ipv6_add_dev() fails later on, or when taking the
>> device down in addrconf_ifdown(). Unfortunately, when I bring the  
>> vlan
>> dev down I never see addrconf_ifdown() called with the how parameter
>> set to 1, which is the only instance where neigh_parms_release()  
>> would
>> be called.
>
> You write about ipv6, but the log is ipv4 only or I miss something.

It doesn't look like there's any ipv6, but I also did a dump_stack()  
each time, and that's how I figured out that ipv6_add_dev() was  
calling neigh_parms_alloc().

> Anyway, it seems you do this vlan on the loopback. If so, there is:
>
>         if ((dev->flags & IFF_LOOPBACK) && how == 1)
>                 how = 0;
>
> at least before 2.6.29 kernels, and vlans copy most of the flags.
> Otherwise, how == 1 should work OK.

I did see that as well. I didn't think that was a fix because I put a  
printk in there to determine if I was hitting it. Unfortunately, I  
forgot to copy the new module over before I retested, so I didn't see  
the message at first. That block was the culprit though.

I grabbed the git commit that included the change to remove the block.  
So far my patched kernel seems to be working correctly with the patch.

>
>> PS: I am running my tests using a slightly modified SLES 11 kernel. I
>
> Generally, it's better to give the kernel number, because everybody
> uses Debian here. ...Not! ;-)

The reason I'm hesitant to do that can be seen in the case of SLES 10  
SP 2. Even though it's 2.6.16, it has so many fixes and backports and  
SuSE changes that it ends up very different from a stock 2.6.16  
kernel. Either way, the SLES 11 kernel is based on 2.6.27.

Thanks for your help!
