From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 3/3] bonding: fix bond_release_all inconsistencies
Date: Mon, 18 Feb 2013 23:13:53 +0100
Message-ID: <5122A7A1.4010803@redhat.com>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com> <1361210344-14907-3-git-send-email-nikolay@redhat.com> <21474.1361224608@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756461Ab3BRWOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 17:14:14 -0500
In-Reply-To: <21474.1361224608@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/13 22:56, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> This patch fixes the following inconsistencies in bond_release_all:
>> - IFF_BONDING flag is not stripped from slaves
>> - MTU is not restored
>> - no netdev notifiers are sent
>> Instead of trying to keep bond_release and bond_release_all in sync
>> I think we can re-use bond_release as the environment for calling it
>> is correct (RTNL is held). I have been running tests for the past
>> week and they came out successful. The only way for bond_release to fail
>> is for the slave to be attached in a different bond or to not be a slave
>> but that cannot happen as RTNL is held and no slave manipulations can be
>> achieved.
> 
> 	It might be worthwhile to add an "all" argument to bond_release
> that skips some things that don't make sense if all slaves are being
> released.  I'm thinking in particular of this block:
> 
> 	if (oldcurrent == slave) {
> 		/*
> 		 * Note that we hold RTNL over this sequence, so there
> 		 * is no concern that another slave add/remove event
> 		 * will interfere.
> 		 */
> 		write_unlock_bh(&bond->lock);
> 		read_lock(&bond->lock);
> 		write_lock_bh(&bond->curr_slave_lock);
> 
> 		bond_select_active_slave(bond);
> 
> 		write_unlock_bh(&bond->curr_slave_lock);
> 		read_unlock(&bond->lock);
> 		write_lock_bh(&bond->lock);
> 	}
> 
> 	as it's written now, for the release all case, the code may go
> to the trouble of assigning a new active slave each time one slave is
> removed (including various log messages, maybe sending IGMPs, etc).  If
> all slaves are being removed, that's pointless.  This could be something
> like:
> 
> 	if (release_all) {
> 		bond->curr_active_slave = NULL;
> 	} else if (oldcurrent == slave) {
> 		[ the current block of stuff ]
> 	}
> 
> 	it's safe here to unconditionally set curr_active_slave to NULL
> because we hold bond->lock for write.  The lock dance stuff for the
> bond_select_active_slave() call is to satisfy its locking requirements.
> 
> 	-J
I see your point and I agree. I will prepare another version that
incorporates it, although I can't add it as an argument since
bond_release is used as ndo_del_slave. I'll have to make it a global
variable.

Nik
