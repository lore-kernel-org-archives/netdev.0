From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: fix for too early rmmod
Date: Tue, 02 Feb 2010 15:55:25 +0100
Message-ID: <4B683CDD.4050804@trash.net>
References: <20100130200505.GA5318@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64195 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab0BBOz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 09:55:27 -0500
In-Reply-To: <20100130200505.GA5318@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Netlink code does module autoload if protocol userspace is asking for is
> not ready. However, module can dissapear right after it was autoloaded.
> Example: modprobe/rmmod stress-testing and xfrm_user.ko providing NETLINK_XFRM.
> 
> netlink_create() in such situation _will_ create userspace socket and
> _will_not_ pin module. Now if module was removed and we're going to call
> ->netlink_rcv into nothing:
> 
> BUG: unable to handle kernel paging request at ffffffffa02f842a
> 					       ^^^^^^^^^^^^^^^^
> 	modules are loaded near these addresses here
> 
> ...
> 
> If module was quickly removed after autoloading, return -E.
> 
> Return -EPROTONOSUPPORT if module was quickly removed after autoloading.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
> 	NOTE: due to commit 513c25000005257e5474f261bf27d4a3c1dff1e3
> 	"[NETLINK]: Don't prevent creating sockets when no kernel socket is registered"
> 	error should probably be -ENOENT, but I have no idea what this
> 	pam-audit thing is.

Quoting from the thread back then (couldn't find a public reference):

> FC4 includes a pam-0.77-audit.patch which adds a pam module that
> uses libaudit to probe for audit availability. It calls audit_open
> and ignores connection refused but returns an pam error for all
> other errors.

The current version of libaudit properly checks for EPROTONOSUPPORT,
but I don't know when this was fixed and whether we can assume the
broken code is not used anymore.
