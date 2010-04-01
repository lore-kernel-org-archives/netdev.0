From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] bonding: fix potential deadlock in bond_uninit()
Date: Thu, 01 Apr 2010 10:49:05 +0800
Message-ID: <4BB409A1.7090701@redhat.com>
References: <20100331105559.5607.38643.sendpatchset@localhost.localdomain> <m1d3ykzq5a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab0DACpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 22:45:32 -0400
In-Reply-To: <m1d3ykzq5a.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
> 
>> bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
>> which will potentially flush all works in this workqueue, if we hold rtnl_lock
>> again in the work function, it will deadlock.
>>
>> So unlock rtnl_lock before calling destroy_workqueue().
> 
> Ouch.  That seems rather rude to our caller, and likely very
> dangerous.


This is reasonable, because workqueue flush functions will potentially
call all the work functions which could take the same lock taken before
the flush call, thus deadlock.

> 
> Is this a deadlock you actually hit, or is this something lockdep
> warned about?

It's only a lockdep warning.

> 
> My gut feel says we need to move the destroy_workqueue into
> the network device destructor.
> 

Oh, this seems a better idea, as long as the destructor are not called
with any locks holding.

Thanks!
