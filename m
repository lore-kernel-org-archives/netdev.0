From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 6/9] s390: qeth driver fixes [3/6]
Date: Fri, 15 Sep 2006 08:51:25 -0700
Message-ID: <200609151551.k8FFpPZt001753@death.nxdomain.ibm.com>
References: <20060915142619.GF10043@de.ibm.com>
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:14548 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932095AbWIOPv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 11:51:28 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8FFpRvR017317
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 11:51:27 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FFpR0B257352
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 11:51:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FFpRQg024891
	for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 11:51:27 -0400
To: Frank Pavlic <fpavlic@de.ibm.com>
In-reply-to: <20060915142619.GF10043@de.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic <fpavlic@de.ibm.com> wrote:

>[PATCH 6/9] s390: qeth driver fixes [3/6]
>
>From: Frank Pavlic <fpavlic@de.ibm.com>
>       	fixed kernel panic caused by qeth driver:
>        Using a bonding device qeth driver will realloc
>        headroom for every skb coming from the bond device.
>        Once this happens qeth frees the original skb and
>        set the skb pointer to the new realloced skb.

	Frank, does the following patch to bonding (to track larger than
usual hard_header_len) resolve this problem without changing qeth?  I
believe this patch is queued for 2.6.19.

To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Cc: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH 5/7] bonding: Handle large hard_header_len
X-Mailer: MH-E 7.83; nmh 1.1-RC4; GNU Emacs 21.4.1
Date: Fri, 01 Sep 2006 15:12:44 -0700
From: Jay Vosburgh <fubar@death>


The bonding driver fails to adjust its hard_header_len when enslaving
interfaces.  Whenever an interface with a hard_header_len greater than the
ETH_HLEN default is enslaved, the potential for an oops exists, and if the
oops happens while responding to an arp request, for example, the system
panics.  GIANFAR devices may use an extended hard_header for VLAN or
hardware checksumming.  Enslaving such a device and then transmitting over
it causes a kernel panic.

Patch modified from submitter's original, but submitter agreed with this
patch in private email.

Signed-off-by: Mark Huth <mhuth@mvista.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


--- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 14:46:07	1.3
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/19 15:47:27	1.4
@@ -1211,10 +1211,14 @@ static int bond_compute_features(struct 
 	unsigned long features = BOND_INTERSECT_FEATURES;
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
+	unsigned short max_hard_header_len = ETH_HLEN;
 	int i;
 
-	bond_for_each_slave(bond, slave, i)
+	bond_for_each_slave(bond, slave, i) {
 		features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
+		if (slave->dev->hard_header_len > max_hard_header_len)
+			max_hard_header_len = slave->dev->hard_header_len;
+	}
 
 	if ((features & NETIF_F_SG) && 
 	    !(features & NETIF_F_ALL_CSUM))
@@ -1232,6 +1236,7 @@ static int bond_compute_features(struct 
 
 	features |= (bond_dev->features & ~BOND_INTERSECT_FEATURES);
 	bond_dev->features = features;
+	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;
 }



	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
