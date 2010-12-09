From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 09 Dec 2010 11:22:56 -0800
Message-ID: <m1ipz2699r.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org> <m1ipz3d46m.fsf@fess.ebiederm.org>
	<m1mxofa8dg.fsf_-_@fess.ebiederm.org> <4D00F58A.2050307@hp.com>
	<20101209082703.6e5519e7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55568 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab0LITXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:23:02 -0500
In-Reply-To: <20101209082703.6e5519e7@nehalam> (Stephen Hemminger's message of
	"Thu, 9 Dec 2010 08:27:03 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Thu, 09 Dec 2010 10:28:10 -0500
> Brian Haley <brian.haley@hp.com> wrote:
>
>> On 12/08/2010 11:16 PM, Eric W. Biederman wrote:

>> 		/* If just doing link down, and address is permanent
>> 		   and not link-local, then retain it. */
>> 		if (!how &&
>> 		    (ifa->flags&IFA_F_PERMANENT) &&
>> 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
>> 			list_move_tail(&ifa->if_list, &keep_list);
>> 
>> 			/* If not doing DAD on this address, just keep it. */
>> 			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
>> 			    idev->cnf.accept_dad <= 0 ||
>> 			    (ifa->flags & IFA_F_NODAD))
>
> I think the problem is on coming back up, not on the down step.

Oh it is.  All addresses that you keep break if you down the loopback
interface, no matter which interface those addresses are on.

Stephen the cause of the regression in 2.6.34-rc1 that you introduced
that breaks the disable_ipv6 functionality in practice is removing
the loopback address from the loopback interface.  So I sent
a partial revert.

It is safe to do a partial revert because the loopback address is always
reprogrammed when we bring the interface back up.  But that
reprogramming only works if it doesn't error out with -EEXIST.

So by all means properly fix the ancient bug that breaks usage of all
local ipv6 addresses when the loopback interface is brought down,
and we can remove the regression fix.

However complaining about a partial revert to fix a regression you
introduced because it fixes a problem deep within the ipv6 networking
stack that the smallest modicum of testing would have revealed on your
part before you broke things seems inappropriate.

Please let's get the disable_ipv6 functionality working again (where 
in practice we don't care about preserving addresses).  Then let's
take our time and tack and fix whatever this is properly.

Eric

