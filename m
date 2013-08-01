From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Question regarding failure utilizing bonding mode 5
 (balance-tlb)
Date: Thu, 1 Aug 2013 08:12:48 +0300
Message-ID: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2274 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab3HAFNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 01:13:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've had reports that load/unload tests using bonding driver in
balance-tlb mode over bnx2x interfaces results in loss of traffic.

When investigating, we've found out that the bonding driver uses the ndo
(ndo_change_mac_addr()) during ifenslave to override the slaves' HW MAC
address. It then directly goes and changes the slaves netdevices'
dev_addr so that each network interface would posses a distinguish MAC
address (as seen in ifconfig), while the FW/HW of both interfaces is
still configured by the MAC passed by the ndo.

When the active slave is unloaded, the ifconfig MAC (dev_addr) is
swapped between the slaves directly, i.e., without calling the ndo. Once
the interface of the previously active slave will be reloaded, it will
configure it's HW MAC according to that dev_addr value  (i.e., the
bonding driver takes no additional measures to force it's own MAC on the
interface when re-loading), causing it to have a configured MAC which
differs from the one that is held by the bonding driver.

If this is done an additional time (on the newly active slave), both
slave devices will be configured to a MAC which differs from the one
held by the bond interface (i.e., the bond interface holds the MAC of
the original active slave, while both interfaces configured the MAC of
the original inactive slave). This obviously prevents any traffic from
being successfully sent/received.

bnx2x uses dev_addr directly for MAC configuration, which I think is the
default behaviour for most network drivers - ixgbe has a shadow value
which it uses instead, but I think that's the exception and not the
rule.

As I see it, either:

   1. The bonding driver is flawed in balance-tlb mode and should be
fixed.

   2. bnx2x's behaviour is flawed - it should have some persistent
shadow MAC which should contain the last MAC set - either factory value
or what was configured by the ndo, and use it instead of dev_addr when
configuring the HW MAC.
This would probably indicate that other drivers are flawed as well.

   3. The test itself is flawed, since user should not unload slave
interfaces.

What's the correct approach for fixing the issue?
Idea's will be welcomed.

Thanks,
Yuval
