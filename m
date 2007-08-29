From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [ofa-general] Re: [PATCH V4 10/10] net/bonding: Destroy bonding master when last slave is gone
Date: Wed, 29 Aug 2007 12:50:14 -0700
Message-ID: <16908.1188417014@death>
References: <46C9B474.5020202@voltaire.com> <46C9BA2D.7060204@voltaire.com> <3403.1188343986@death> <46D57D5D.3060706@gmail.com>
Cc: Moni Shoua <monis@voltaire.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:56127 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbXH2TuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 15:50:18 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TJoHGo032590
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 15:50:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TJoHd4652470
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 15:50:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TJoGFm011621
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 15:50:17 -0400
In-reply-to: <46D57D5D.3060706@gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moni Shoua <monisonlists@gmail.com> wrote:

>Jay Vosburgh wrote:
>> Moni Shoua <monis@voltaire.com> wrote:
>> 
>>> When bonding enslaves non Ethernet devices it takes pointers to functions 
>>> in the module that owns the slaves. In this case it becomes unsafe
>>> to keep the bonding master registered after last slave was unenslaved 
>>> because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
>>> ensures that these functions be used anymore.
>> 
>> 	Would it not be simpler to run the bonding master through
>> ether_setup() again when the final slave is released (to reset all of
>> the pointers to their "ethernet" values)?  I'm presuming here the
>> pointers of questionable validity are the ones set in the
>> bond_setup_by_slave() copied from the slave_dev->hard_header, et al.
>> 
>> 	Having the bonding master disappear (but only sometimes) after
>> the last slave is removed is a semantic change I'd rather not introduce
>> if it's not necessary.
>
>Thanks for the comments.
>
>Having the master disappear is one way I could think of to solve the problem of leaving
>the bonding module with pointers to illegal addresses.
>The other way is to increase the usage count, with try_module_get(), of the module which owns of the slave.
>To do that I  have to restore the field  owner in structure net_device (it was removed in 2.6).

	What I was asking above is really whether or not it's feasible
to simply reset the affected pointers back to the "ethernet" values from
ether_setup().  I would think this should return the bonding master back
to the original state it started in before any slaves were added.
Unless I'm missing something; I'm willing to believe there's some
IB-specific tidbit I'm unaware of that makes this more complicated than
it seems.

	This presumes that I'm correct in thinking that the pointers
you're talking about (as being unsafe after removal of last slave) are
the ones copied in your new function bond_setup_by_slave().

	I don't think it's desirable to acquire a reference to the slave
driver module.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
