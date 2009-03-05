From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected - twice
Date: Thu, 05 Mar 2009 10:51:12 -0800
Message-ID: <9712.1236279072@death.nxdomain.ibm.com>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc> <16084.1235752119@death.nxdomain.ibm.com> <49A84802.7030502@krogh.cc> <30478.1235766943@death.nxdomain.ibm.com> <49AA2973.7040209@krogh.cc> <49AA8B4F.8090405@krogh.cc>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53243 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620AbZCESvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 13:51:07 -0500
In-reply-to: <49AA8B4F.8090405@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh <jesper@krogh.cc> wrote:

>Jesper Krogh wrote:
>> I appreciate that you spend time on it, but my feeling is that it
>> definately isn't reproducible in all environments (otherwise we would
>> probably have seen a large cry by now).
>>
>> I'm trying to bisect the "fix" down and hope that'll tell us something
>> more.
>
>Ok, The fixing commit seems to be: cb52deba12f27af90a46d2f8667a64888118a888
>
>Applying it to 2.6.28.7 and 2.6.27.19 makes them both work.
>
>It also explains why my e1000 based bonds didnt break, allthough the
>commitmessage doesnt mention anything about how it should effect
>bonding. Wouldn't it make sense to propose this patch for 2.6.27 and
>2.6.28 stable kernels?

	Perhaps.

	I don't have a forcedeth to test with, and as you surmised, I
was unable to reproduce the problem with other chipsets (tg3 or e1000).

	However, I did find another bug I introduced during the "mii
refactor" patch that you mentioned as being the original source of the
problem.  That bug will cause 802.3ad to not notice speed changes.

	Could you test the patch below on your 2.6.68.7 and/or 2.6.27.19
and see if it resolves your problem (without the forcedeth patch)?

	-J

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2c96b93..ad81474 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3545,11 +3545,27 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		}
 		break;
 	case NETDEV_CHANGE:
-		/*
-		 * TODO: is this what we get if somebody
-		 * sets up a hierarchical bond, then rmmod's
-		 * one of the slave bonding devices?
-		 */
+		if (bond->params.mode == BOND_MODE_8023AD ||
+		    bond_is_lb(bond)) {
+			struct slave *slave;
+
+			slave = bond_get_slave_by_dev(bond, slave_dev);
+			if (slave) {
+				u16 old_speed = slave->speed;
+				u16 old_duplex = slave->duplex;
+
+				bond_update_speed_duplex(slave);
+
+				if (bond_is_lb(bond))
+					break;
+
+				if (old_speed != slave->speed)
+					bond_3ad_adapter_speed_changed(slave);
+				if (old_duplex != slave->duplex)
+					bond_3ad_adapter_duplex_changed(slave);
+			}
+		}
+
 		break;
 	case NETDEV_DOWN:
 		/*


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
