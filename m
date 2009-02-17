From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 14:24:14 -0800
Message-ID: <21405.1234909454@death.nxdomain.ibm.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <200902172117.22671.arvidjaar@mail.ru> <499B19AF.1000003@hp.com> <16929.1234904788@death.nxdomain.ibm.com> <499B30DC.5040303@hp.com>
Cc: Andrey Borzenkov <arvidjaar@mail.ru>, "J.A. Magall"@us.ibm.com,
	=?ISO-8859-1?Q?=F3n?= <jamagallon@ono.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	bonding-devel@lists.sourceforge.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43956 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbZBQWYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:24:20 -0500
In-reply-to: <499B30DC.5040303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>Jay Vosburgh wrote:
[...]
>> 	Putting the ipv6 bits into a different module might not help,
>> either, because the "core" bonding code would still have the call to the
>> ipv6 functions.  Unless there's some magic way to somehow know at
>> runtime whether or not the ipv6 module is loaded, and only try to
>> resolve those symbols if ipv6 is loaded.  That seems complicated.
>
>This separate bonding_ipv6 module would have to register itself with the
>"core" one with a new proto_ops of some sort.  Calls are made for the
>appropriate method, for example bond_ops->send_gratuitous(bond).  We'd
>change the IPv4 code too.  It's just a theory, does make things more
>complicated.

	I don't see any reason to change the IPv4 bits; there won't ever
be a case of ipv4 not being loaded, and this would just add the
complexity of a registration gizmo with no real benefit.  A "bonding
ipv6 ops" would be strictly a hack to deal with ipv6 module dependencies
for cases when the kernel is built with CONFIG_IPV6 but the ipv6 module
itself is prevented from loading.

	A registration gizmo doesn't need to be especially complicated;
there's only three functions in bond_ipv6.c that are called from the
bonding core: bond_send_unsolicited_na, and the ipv6 notifier register /
unregister.  The bonding_ipv6 module can simply be bond_ipv6.c, which
calls some exported "hey, bond_send_unsol_na is here" thing in the
bonding core during init and another "hey, send_unsol_na is gone" during
unload.  The bonding_ipv6 module can do its own notifier registration
handing.

>> 	To answer your question, I have come across this (aliasing ipv6
>> to nothing in modprobe.conf to disable IPv6) from time to time, but
>> didn't think of it when the NA code was added to bonding.
>
>So I guess I'll start hacking the above, unless someone has a better
>suggestion.

	Well, I think this is pretty heinous, but I don't have a better
idea at the moment.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
