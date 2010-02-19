From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] net: Fix sysctl restarts...
Date: Fri, 19 Feb 2010 15:35:27 -0800
Message-ID: <m1ocjksssg.fsf@fess.ebiederm.org>
References: <m14olcu7xo.fsf@fess.ebiederm.org>
	<20100219.152954.39315470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58313 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab0BSXfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:35:32 -0500
In-Reply-To: <20100219.152954.39315470.davem@davemloft.net> (David Miller's message of "Fri\, 19 Feb 2010 15\:29\:54 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 19 Feb 2010 15:22:59 -0800
>
>> 
>> Yuck.  It turns out that when we restart sysctls we were restarting
>> with the values already changed.  Which unfortunately meant that
>> the second time through we thought there was no change and skipped
>> all kinds of work, despite the fact that there was indeed a change.
>> 
>> I have fixed this the simplest way possible by restoring the changed
>> values when we restart the sysctl write.
>> 
>> One of my coworkers spotted this bug when after disabling forwarding
>> on an interface pings were still forwarded.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> What commit added this bug?

When we I fixed the deadlock that can happen if you write to forwarding
while removing the device.  The deadlock was fixed, the restart worked
but I somehow missed the fact that proc_dointvec modifies state and so
defeated the change detection.  *embarrassing*

commit 9b8adb5ea005fe73acd5dd58f9bd47eafa74c9d1
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Wed May 13 16:59:21 2009 +0000

    net: Fix devinet_sysctl_forward
    
    sysctls are unregistered with the rntl_lock held making
    it unsafe to unconditionally grab the the rtnl_lock.  Instead
    we need to call rtnl_trylock and restart the system call
    if we can not grab it.  Otherwise we could deadlock at unregistration
    time.
    
    Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>




