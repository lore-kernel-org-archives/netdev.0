From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce	primary_lazy
 option
Date: Tue, 25 Aug 2009 19:31:05 +0200
Message-ID: <4A941FD9.6050304@free.fr>
References: <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr> <20090818124550.GB3539@psychotron.englab.brq.redhat.com> <4A8D4427.8080004@free.fr> <20090824111619.GC4018@psychotron.englab.brq.redhat.com> <4A92ACA6.7070600@free.fr> <20090824152002.GD4018@psychotron.englab.brq.redhat.com> <697.1251135317@death.nxdomain.ibm.com> <20090825064351.GA3426@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.11]:59010 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351AbZHYRbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 13:31:07 -0400
In-Reply-To: <20090825064351.GA3426@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Mon, Aug 24, 2009 at 07:35:17PM CEST, fubar@us.ibm.com wrote:
>> 	I'm still unclear as to why it's better to add another special
>> case option to bonding instead of changing this in user space, other
>> than it'd be a change to user space (initscripts / sysconfig).
>>
>> 	The way I see it, this patch is adding a mechanism that says,
>> effectively, "make slave X the active slave, but do it only once."
>> There is already a way to do that in bonding (sysfs, as above, or
>> ifenslave -c); I am reluctant to add another without good reason.
> 
> Hello Jay.
> 
> As I already replied you once it's not only about selecting a slave at the
> start. It's also about following:
> 
> Imagine you have bond with 3 slaves:
> eth0            eth1            eth2
> UP(curr)        UP              UP
> DOWN            UP(curr)        UP
> UP              UP(curr)        UP
> UP              DOWN            UP(curr)
> 
> eth2 ends up being current active but we prefer eth0 (as primary interface).
> This is not desirable and is solved by primary_lazy option.
> 
> Jirka
> 
>> 	I'm not necessarily against the "weight" business in general.
>> For the purposes of this discussion, however, it's a big complex
>> solution to a pretty simple problem, and the "weight" system still has
>> to have special sauce added it to to handle this special case.
>>
>> 	Last, presuming for the moment that this goes forward as an
>> option to bonding, I think this should be named something along the
>> lines of "make_active" (or perhaps "make_active_once", but that's a bit
>> long).  The option has the effect of making the specified slave the
>> active slave one time, then the option setting is cleared.

Hi Jay,

 From what I understand from Jirka's needs, the exact expected behaviors are :

1/ If a slave is active, keep it active, even if the primary comes back up.
2/ If the current slave just failed, choose the new active slave, giving 
priority to the master.

Selecting the active slave at startup (by using ifenslave -c or writing into 
/sys/class/net/bond0/bonding/active_slave) would solve 1, but not 2.

Also, I suggested to change 1 in this way :

1/ If a slave is active, keep it active, even if the primary comes back up, 
*except if the speed of the primary is better than the speed of the active slave*.

Thinking about all that, I start feeling that some sort of user space system to 
select the "best" slave would be better. If we can design a NETLINK interface to 
report events (slave up, slave down...) to user space, then any user space 
daemon would be able to tell bonding what to do. Only if no process register to 
receive those events would bonding use the normal slave selection rules.

Designing such a NETLINK interface would replace my proposed weight option (at 
least for best slave selection in active-backup mode and for best aggregator 
selection in 802.3ad mode). It would also solve the problem reported by Jirka 
and so replace the proposed primary_lazy option.

Any way, NETLINK is something that is supposed to come into bonding at some 
times, because we know that the sysfs purists hate the sysfs bonding stuff and 
that NETLINK is the target to setup networking.

Any comments ?

	Nicolas.

