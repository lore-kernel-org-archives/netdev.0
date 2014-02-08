From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL: assertion failed at net/core/rtnetlink.c (940)
Date: Fri, 07 Feb 2014 17:21:42 -0800
Message-ID: <7882.1391822502@death.nxdomain>
References: <20140206205106.GA10488@glanzmann.de> <CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com> <30988.1391723318@death.nxdomain> <31272.1391724462@death.nxdomain> <CAHA+R7McuqYDshugsWcaeBbBsEg3QY59LiovYthcq6bH1fLTNg@mail.gmail.com> <31653.1391725983@death.nxdomain>
Cc: Cong Wang <cwang@twopensource.com>,
	Thomas Glanzmann <thomas@glanzmann.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>
To: "sfeldma@cumulusnetworks.com" <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:59802 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaBHBVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 20:21:49 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 7 Feb 2014 20:21:48 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 400B638C8047
	for <netdev@vger.kernel.org>; Fri,  7 Feb 2014 20:21:45 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s181LjM33998080
	for <netdev@vger.kernel.org>; Sat, 8 Feb 2014 01:21:45 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s181Lhgs018182
	for <netdev@vger.kernel.org>; Fri, 7 Feb 2014 20:21:44 -0500
In-reply-to: <31653.1391725983@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:

>
>Cong Wang <cwang@twopensource.com> wrote:
>
>>On Thu, Feb 6, 2014 at 2:07 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>>> Jay Vosburgh <fubar@us.ibm.com> wrote:
>>>
>>>>Cong Wang <cwang@twopensource.com> wrote:
>>>>
>>>>
>>>>       That would eliminate the warning, but is suboptimal.  Acquiring
>>>>RTNL is not necessary on the vast majority of state machine runs
>>>>(because no state changes take place, i.e., no ports are disabled or
>>>>enabled).  The above change would add 10 round trips per second to RTNL,
>>>>which seems excessive.
>>>>
>>>>       Also, we cannot unconditionally acquire RTNL in this function,
>>>>as it would race with the call to cancel_delayed_work_sync from
>>>>bond_close (via bond_work_cancel_all).
>>
>>OK.
>>
>>>
>>>         Thought of one more problem: we can't hold a regular lock while
>>> calling rtmsg_ifinfo, as it may sleep in alloc_skb.  The rtmsg_ifinfo
>>> call has to be RTNL and nothing else.
>>>
>>
>>s/GFP_KERNEL/GFP_ATOMIC/
>
>	Yah, that would help with extra locks, but not totally solve
>things.  I'm looking around, and seeing a number of other places that
>will end up at one of these rtmsg_ifinfo calls with incorrect locking:
>
>	bond_ab_arp_probe calls via bond_set_slave_active_flags and
>bond_set_slave_inactive_flags without RTNL.
>
>	bond_change_active_slave calls via bond_set_slave_inactive_flags
>and bond_set_slave_active_flags with other locks held, and maybe without
>RTNL; I'm not sure if bond_option_active_slave_set holds RTNL when it
>calls bond_select_active_slave.
>
>	bond_open calls via bond_set_slave_active_flags and
>bond_set_slave_inactive_flags with RTNL, but also with other locks held.
>
>	bond_loadbalance_arp_mon calls bond_set_active_slave and
>bond_set_backup_slave without RTNL.
>
>	This is in addition to the cases in the 802.3ad code from
>__enable_port and __disable_port calls.

	Just an update in case anybody else is looking into this, and
some questions for Scott.

	Acquiring RTNL for the __enable_port and __disable_port cases is
difficult, as those calls generally already hold the state machine lock,
and cannot unconditionally call rtnl_lock because either they already
hold RTNL (for calls via bond_3ad_unbind_slave) or due to the potential
for deadlock with bond_3ad_adapter_speed_changed,
bond_3ad_adapter_duplex_changed, bond_3ad_link_change, or
bond_3ad_update_lacp_rate.  All four of those are called with RTNL held,
and acquire the state machine lock second.  The calling contexts for
__enable_port and __disable_port already hold the state machine lock,
and may or may not need RTNL.

	Scott: you added these calls, so can you explain what they're
for?  I'm asking for two reasons:

	First, if they do not occur synchronously is it going to be a
problem?  E.g., for the 802.3ad case, if the rtmsg_ifinfo is called
either at the end of the state machine run, or for non-state machine
events, at the next run of the state machine (which is every 100 ms),
would that be a problem?  Setting a flag in the slave somewhere that an
rtmsg_ifinfo is needed should be doable for the 802.3ad case.

	Second, what do the messages mean?  That the slave is now
"active and usable"?  I'm asking because I suspect the bond_ab_arp_probe
usage wherein it adjusts the flags and curr_active_slave should not
actually call rtmsg_ifinfo, as the slave there is not really "up."
What's going on there is that the ARP monitor cycles through each slave
one by one, and tests to see if that slave works.  If it does work, then
it is set as the active elsewhere in the monitor code.  This function
adjusts the flags so that the ARP monitor will treat the "testing" slave
as "active" for purposes of determining whether or not it is up.  I
suspect this adjustment to the flags should not actually generate an
rtmsg_ifinfo.

	I think the remaining cases can be dealt with, but clarification
on the above two questions would be very helpful.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
