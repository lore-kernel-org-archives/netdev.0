From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding questions: carrier based link monitoring / slave device state flags
Date: Thu, 03 Aug 2006 17:19:29 -0700
Message-ID: <200608040019.k740JTZt018654@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0608030815270.32510@zuben>
Cc: netdev@vger.kernel.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39102 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S932565AbWHDAmo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:42:44 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k740gdnQ006229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 20:42:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k740XkRk311712
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 18:42:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k740JVg9007094
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 18:19:32 -0600
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <Pine.LNX.4.64.0608030815270.32510@zuben> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>First, i'd like to verify what is the parameter setting to have the
>bonding driver use netif_carrier_ok(slave_device) as the means for
>link detection. Is setting use_carrier = 1 enough or one needs to set
>miimon to non-zero as well??? (where the value of miimon translates
>to the link monitoring frequency).

	I'll just note that all of the bonding parameters and such are
documented in the Documentation/networking/bonding.txt file that comes
with the kernel source code.  You can also download the documentation
from sourceforge.net/projects/bonding.

	To answer your question, you'd have to specify an miimon=X
interval (where X is some nonzero value, e.g., 100).  The default for
the use_carrier parameter is 1, which is what you want, so there is no
need to specify it.  The purpose of the use_carrier parameter is to
permit the old method to be used for network drivers that don't support
netif_carrier (which are pretty rare these days).

>Second, I understand that an enslaved device must **not** be UP, so
>when enslaving a device the bonding driver calls dev_open(slave_device),
>and make sure the device is UP, correct?

	Yes, the bonding driver does need to have the slave down during
part of the enslavement (to set the MAC address), but if the slave isn't
up, it will be set down.  Don't worry about it.

>What i want to better understand here, is whether for the bonding driver
>to declare a slave as "being able to carry traffic" it assumes the slave
>will move from UP to RUNNING state (and later netif_carrier_ok would
>return TRUE) without an IP address being set for the slave device ???

	The RUNNING state is set (indirectly) by the device driver when
it calls netif_carrier_on(); this is totally unrelated to the IP address
information attached to an interface.  Whatever IP address is set for a
slave is not used during operation.

>Is (per the bonding driver) the **time** it should take the slave to get
>from UP to (RUNNING && carrier_ok) state limited and/or controlled?

	I'm not exactly sure what you're asking here, but when miimon is
enabled, if the slave is not netif_carrier_ok() during any of the
periodic checks, it will be disabled by the bonding driver.

	There are also updelay and downdelay parameters to handle cases
where it takes some amount of real time for a carrier state transition
to occur (and, thus, state changes should be ignored for a period of
time).  E.g., some switches will assert link up on a port before they
are actually able to send and receive traffic; in that case, bonding
could use the updelay parameter to ignore link up changes for a period
of time.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
