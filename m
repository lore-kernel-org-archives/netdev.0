From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: active-backup/bonding with drivers not supporting set_mac_address()
Date: Mon, 10 Jul 2006 11:29:14 -0700
Message-ID: <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0607101618390.26558@zuben>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:21912 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964972AbWGJS3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 14:29:32 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6AITG7m023845
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:29:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6AITGaG292064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:29:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6AITG4s032015
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:29:16 -0400
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <Pine.LNX.4.64.0607101618390.26558@zuben> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Looking on the linux bonding driver, it seems to unconditionally (*)
>assume that the enslaved device supports the set_mac_address call.
>
>From reading the doc (Documentation/networking/bonding.txt) i understand that
>it is **not** a must prerequisite for the active-backup mode, this is since
>there is at most one active slave at each point of time and as the doc states:
>
>	when a failover occurs in active-backup mode, bonding will issue
>	one or more gratuitous ARPs on the newly active slave.

	I think you're misreading the documentation a bit.  Some
specific modes (balance-alb, for example) require that the slave device
driver support set_mac_address while the device is up.  Many device
drivers will only allow MAC changes while the device is down; those
drivers won't work with the alb mode.

	The active-backup and other modes have always needed a set_mac
functionality, but they don't require that the device be up when
changing the MAC (those modes set the mac for a slave one time, during
the enslavement process, and the device is down when this is done).

	The purpose of the gratuitous ARP is to update switch forwarding
tables (i.e., announce that the device has moved from one port to
another), not to announce a change of MAC address.

>I'd like to get feedback from people here if you think it makes sense
>to change the bonding driver to actually allow for active-backup/bonding
>with network device drivers which does not support set_mac_address.

	What network device drivers are there that don't permit ever
changing the device MAC address?

	I think changing active-backup (as an example here) to cause a
MAC change during failover will have some side effects and secondary
requirements that aren't necessarily obvious.  For example, the MAC of
the bond itself will change during failover; I'm not sure right offhand
what effect if any this might have on third parties.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
