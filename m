From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix for too early rmmod
Date: Wed, 03 Feb 2010 18:14:44 -0800 (PST)
Message-ID: <20100203.181444.177937887.davem@davemloft.net>
References: <20100130200505.GA5318@x200>
	<4B683CDD.4050804@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756062Ab0BDCOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:14:31 -0500
In-Reply-To: <4B683CDD.4050804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 02 Feb 2010 15:55:25 +0100

> Alexey Dobriyan wrote:
>> Netlink code does module autoload if protocol userspace is asking for is
>> not ready. However, module can dissapear right after it was autoloaded.
>> Example: modprobe/rmmod stress-testing and xfrm_user.ko providing NETLINK_XFRM.
>> 
>> netlink_create() in such situation _will_ create userspace socket and
>> _will_not_ pin module. Now if module was removed and we're going to call
>> ->netlink_rcv into nothing:
>> 
>> BUG: unable to handle kernel paging request at ffffffffa02f842a
>> 					       ^^^^^^^^^^^^^^^^
>> 	modules are loaded near these addresses here
>> 
>> ...
>> 
>> If module was quickly removed after autoloading, return -E.
>> 
>> Return -EPROTONOSUPPORT if module was quickly removed after autoloading.
>> 
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>> ---
>> 
>> 	NOTE: due to commit 513c25000005257e5474f261bf27d4a3c1dff1e3
>> 	"[NETLINK]: Don't prevent creating sockets when no kernel socket is registered"
>> 	error should probably be -ENOENT, but I have no idea what this
>> 	pam-audit thing is.
> 
> Quoting from the thread back then (couldn't find a public reference):
> 
>> FC4 includes a pam-0.77-audit.patch which adds a pam module that
>> uses libaudit to probe for audit availability. It calls audit_open
>> and ignores connection refused but returns an pam error for all
>> other errors.
> 
> The current version of libaudit properly checks for EPROTONOSUPPORT,
> but I don't know when this was fixed and whether we can assume the
> broken code is not used anymore.

In any event, the EPROTONOSUPPORT is being returned now in a case
that has been OOPS'ing.  So I think it's safe to apply Alexey's
fix as-is, and that is what I have just done in net-2.6 :-)

Thanks!
