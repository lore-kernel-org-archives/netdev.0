From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 3/3] bonding: fix bond_release_all inconsistencies
Date: Mon, 18 Feb 2013 15:17:59 -0800
Message-ID: <23939.1361229479@death.nxdomain>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com> <1361210344-14907-3-git-send-email-nikolay@redhat.com> <21474.1361224608@death.nxdomain> <5122A7A1.4010803@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50296 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3BRXSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 18:18:45 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 18 Feb 2013 16:18:45 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B22763E4003E
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:18:34 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1INIYTS146640
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:18:34 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1INI14u008312
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:18:03 -0700
In-reply-to: <5122A7A1.4010803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>On 18/02/13 22:56, Jay Vosburgh wrote:
>> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> 
>>> This patch fixes the following inconsistencies in bond_release_all:
>>> - IFF_BONDING flag is not stripped from slaves
>>> - MTU is not restored
>>> - no netdev notifiers are sent
>>> Instead of trying to keep bond_release and bond_release_all in sync
>>> I think we can re-use bond_release as the environment for calling it
>>> is correct (RTNL is held). I have been running tests for the past
>>> week and they came out successful. The only way for bond_release to fail
>>> is for the slave to be attached in a different bond or to not be a slave
>>> but that cannot happen as RTNL is held and no slave manipulations can be
>>> achieved.
>> 
>> 	It might be worthwhile to add an "all" argument to bond_release
>> that skips some things that don't make sense if all slaves are being
>> released.  I'm thinking in particular of this block:
>> 
>> 	if (oldcurrent == slave) {
>> 		/*
>> 		 * Note that we hold RTNL over this sequence, so there
>> 		 * is no concern that another slave add/remove event
>> 		 * will interfere.
>> 		 */
>> 		write_unlock_bh(&bond->lock);
>> 		read_lock(&bond->lock);
>> 		write_lock_bh(&bond->curr_slave_lock);
>> 
>> 		bond_select_active_slave(bond);
>> 
>> 		write_unlock_bh(&bond->curr_slave_lock);
>> 		read_unlock(&bond->lock);
>> 		write_lock_bh(&bond->lock);
>> 	}
>> 
>> 	as it's written now, for the release all case, the code may go
>> to the trouble of assigning a new active slave each time one slave is
>> removed (including various log messages, maybe sending IGMPs, etc).  If
>> all slaves are being removed, that's pointless.  This could be something
>> like:
>> 
>> 	if (release_all) {
>> 		bond->curr_active_slave = NULL;
>> 	} else if (oldcurrent == slave) {
>> 		[ the current block of stuff ]
>> 	}
>> 
>> 	it's safe here to unconditionally set curr_active_slave to NULL
>> because we hold bond->lock for write.  The lock dance stuff for the
>> bond_select_active_slave() call is to satisfy its locking requirements.
>> 
>> 	-J
>I see your point and I agree. I will prepare another version that
>incorporates it, although I can't add it as an argument since
>bond_release is used as ndo_del_slave. I'll have to make it a global
>variable.

	No, just rename the current bond_release to __bond_release_one,
add the extra argument, and create a new bond_release .ndo_del_slave
that calls __bond_release_one with "all=0".  Then, bond_release_all
calls __bond_release_one with all=1.

	Also, there's only one caller of bond_release_all, and since the
new & improved bond_release_all is trivial, it could be open coded into
bond_uninit, eliminating bond_release_all as a function.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
