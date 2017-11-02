From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Bond recovery from BOND_LINK_FAIL state not working
Date: Wed, 1 Nov 2017 22:37:26 -0400
Message-ID: <a6b9c9bc-a3e7-60fb-4a44-cc8b641f308c@redhat.com>
References: <f9a6457e-f575-e9c1-2519-7694e30c474f@hpe.com>
 <28118.1509572045@famine> <10968.1509582913@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
        Alex Sidorenko <alexandre.sidorenko@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751628AbdKBCh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 22:37:27 -0400
In-Reply-To: <10968.1509582913@famine>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-11-01 8:35 PM, Jay Vosburgh wrote:
> Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> 
>> Alex Sidorenko <alexandre.sidorenko@hpe.com> wrote:
>>
>>> The problem has been found while trying to deploy RHEL7 on HPE Synergy
>>> platform, it is seen both in customer's environment and in HPE test lab.
>>>
>>> There are several bonds configured in TLB mode and miimon=100, all other
>>> options are default. Slaves are connected to VirtualConnect
>>> modules. Rebooting a VC module should bring one bond slave (ens3f0) down
>>> temporarily, but not another one (ens3f1). But what we see is
>>>
>>> Oct 24 10:37:12 SYDC1LNX kernel: bond0: link status up again after 0 ms for interface ens3f1
> 
> 	In net-next, I don't see a path in the code that will lead to
> this message, as it would apparently require entering
> bond_miimon_inspect in state BOND_LINK_FAIL but with downdelay set to 0.
> If downdelay is 0, the code will transition to BOND_LINK_DOWN and not
> remain in _FAIL state.

The kernel in question is laden with a fair bit of additional debug 
spew, as we were going back and forth, trying to isolate where things 
were going wrong.  That was indeed from the BOND_LINK_FAIL state in 
bond_miimon_inspect, inside the if (link_state) clause though, so after 
commit++, there's a continue, which ... does what now? Doesn't it take 
us back to the top of the bond_for_each_slave_rcu() loop, so we bypass 
the next few lines of code that would have led to a transition to 
BOND_LINK_DOWN?

...
>> 	Your patch does not apply to net-next, so I'm not absolutely
>> sure where this is, but presuming that this is in the BOND_LINK_FAIL
>> case of the switch, it looks like both BOND_LINK_FAIL and BOND_LINK_BACK
>> will have the issue that if the link recovers or fails, respectively,
>> within the delay window (for down/updelay > 0) it won't set a
>> slave->new_link.
>>
>> 	Looks like this got lost somewhere along the line, as originally
>> the transition back to UP (or DOWN) happened immediately, and that has
>> been lost somewhere.
>>
>> 	I'll have to dig out when that broke, but I'll see about a test
>> patch this afternoon.
> 
> 	The case I was concerned with was moved around; the proposed
> state is committed in bond_mii_monitor.  But to commit to _FAIL state,
> the downdelay would have to be > 0.  I'm not seeing any errors in
> net-next; can you reproduce your erroneous behavior on net-next?

I can try to get a net-next-ish kernel into their hands, but the bonding 
driver we're working with here is quite close to current net-next 
already, so I'm fairly confident the same thing will happen.

-- 
Jarod Wilson
jarod@redhat.com
