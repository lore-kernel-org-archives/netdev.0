From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding directly changes underlying device address
Date: Tue, 13 May 2014 09:30:41 -0700
Message-ID: <20030.1399998641@localhost.localdomain>
References: <5371FCD0.7050502@mellanox.com> <20140513115527.GC2910@minipsycho.orion>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55640 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaEMQaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:30:46 -0400
In-reply-to: <20140513115527.GC2910@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Tue, May 13, 2014 at 01:06:56PM CEST, ogerlitz@mellanox.com wrote:
>>Hi Jay, Veaceslav
>>
>>I see  now that alb_set_slave_mac_addr directly changes the
>>underlying device mac address without calling dev_set_mac_address
>>when running in TLB mode. Is that on purpose? if yes, can you explain
>>why?
>
>I believe that is a bug. dev_addr change should be always done using
>dev_set_mac_address.

	It may or may not be a bug today, but it's done this way on
purpose to work around the limitations of the system when the tlb mode
was implemented.

	The tlb mode wants to have each slave send with source MAC set
to a particular MAC assigned to the slave (which may or may not be the
slave's actual MAC address).  It does not need for slaves other than the
active slave to actually receive any packets (tlb only has load
balancing for TX, RX all goes to one slave), so programming the MAC into
the device was left out on purpose.

	The MAC change was done this way because, when the code was
originally written, many (perhaps most) devices / drivers could not
change their MAC address while open; it was common practice to program
the MAC in the device open function, and nowhere else.  This method
permits the tlb mode to do the MAC juggling on the TX side without
requiring the slave device be able to change its MAC while open (as the
alb mode requires).

>>I suspect this can lead to funny (or actually sad) bugs in networking
>>drivers, can we avoid that?

	Changing this would also remove support for the tlb mode from
any device that cannot change their MAC while open.  I don't know how
many devices that is (it's probably a small number nowadays), but if
it's not zero then an assessment on losing that support has to be made.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
