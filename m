From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL: assertion failed at net/core/rtnetlink.c (940)
Date: Thu, 06 Feb 2014 14:33:03 -0800
Message-ID: <31653.1391725983@death.nxdomain>
References: <20140206205106.GA10488@glanzmann.de> <CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com> <30988.1391723318@death.nxdomain> <31272.1391724462@death.nxdomain> <CAHA+R7McuqYDshugsWcaeBbBsEg3QY59LiovYthcq6bH1fLTNg@mail.gmail.com>
Cc: Thomas Glanzmann <thomas@glanzmann.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"sfeldma@cumulusnetworks.com" <sfeldma@cumulusnetworks.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41098 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbaBFWdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 17:33:08 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Feb 2014 17:33:07 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5A53C6E8047
	for <netdev@vger.kernel.org>; Thu,  6 Feb 2014 17:33:01 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s16MX5T264028892
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 22:33:05 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s16MX48E010984
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 17:33:05 -0500
In-reply-to: <CAHA+R7McuqYDshugsWcaeBbBsEg3QY59LiovYthcq6bH1fLTNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cong Wang <cwang@twopensource.com> wrote:

>On Thu, Feb 6, 2014 at 2:07 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>> Jay Vosburgh <fubar@us.ibm.com> wrote:
>>
>>>Cong Wang <cwang@twopensource.com> wrote:
>>>
>>>
>>>       That would eliminate the warning, but is suboptimal.  Acquiring
>>>RTNL is not necessary on the vast majority of state machine runs
>>>(because no state changes take place, i.e., no ports are disabled or
>>>enabled).  The above change would add 10 round trips per second to RTNL,
>>>which seems excessive.
>>>
>>>       Also, we cannot unconditionally acquire RTNL in this function,
>>>as it would race with the call to cancel_delayed_work_sync from
>>>bond_close (via bond_work_cancel_all).
>
>OK.
>
>>
>>         Thought of one more problem: we can't hold a regular lock while
>> calling rtmsg_ifinfo, as it may sleep in alloc_skb.  The rtmsg_ifinfo
>> call has to be RTNL and nothing else.
>>
>
>s/GFP_KERNEL/GFP_ATOMIC/

	Yah, that would help with extra locks, but not totally solve
things.  I'm looking around, and seeing a number of other places that
will end up at one of these rtmsg_ifinfo calls with incorrect locking:

	bond_ab_arp_probe calls via bond_set_slave_active_flags and
bond_set_slave_inactive_flags without RTNL.

	bond_change_active_slave calls via bond_set_slave_inactive_flags
and bond_set_slave_active_flags with other locks held, and maybe without
RTNL; I'm not sure if bond_option_active_slave_set holds RTNL when it
calls bond_select_active_slave.

	bond_open calls via bond_set_slave_active_flags and
bond_set_slave_inactive_flags with RTNL, but also with other locks held.

	bond_loadbalance_arp_mon calls bond_set_active_slave and
bond_set_backup_slave without RTNL.

	This is in addition to the cases in the 802.3ad code from
__enable_port and __disable_port calls.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
