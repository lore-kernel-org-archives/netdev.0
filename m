From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 1/6] bonding: verify if bond has ip only once on arp validate
Date: Wed, 19 Jun 2013 10:50:24 -0700
Message-ID: <27844.1371664224@death.nxdomain>
References: <1371663286-12518-2-git-send-email-vfalico@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51684 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757212Ab3FSRuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 13:50:40 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 19 Jun 2013 11:50:40 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8E86F3E40044
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:50:18 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5JHoVsF072296
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:50:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5JHoRAH022186
	for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:50:29 -0600
In-reply-to: <1371663286-12518-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>It's extra work to verify bond's ip presence for every slave, so take it
>out of the loop.

	The current code doesn't verify for every slave (target address,
actually).  The call to bond_has_this_ip() happens at most once, if the
sip (source IP) matches the arp_ip_target being inspected, after which
the function returns.

	I can see that the patch will bypass the loop entirely if the
bond lacks the IP, but I'm not sure that's a meaningful improvement,
since it changes from calling bond_has_this_ip 0 or 1 times to always 1
time.

	-J


>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_main.c |   13 ++++++++-----
> 1 files changed, 8 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index bc1246f..3d8b5ba 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2602,13 +2602,16 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
> 	int i;
> 	__be32 *targets = bond->params.arp_targets;
>
>+	if (!bond_has_this_ip(bond, tip)) {
>+		pr_debug("bva: tip %pI4 not found\n", &tip);
>+		return;
>+	}
>+
> 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
>-		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
>-			 &sip, &tip, i, &targets[i],
>-			 bond_has_this_ip(bond, tip));
>+		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip)\n",
>+			 &sip, &tip, i, &targets[i]);
> 		if (sip == targets[i]) {
>-			if (bond_has_this_ip(bond, tip))
>-				slave->last_arp_rx = jiffies;
>+			slave->last_arp_rx = jiffies;
> 			return;
> 		}
> 	}
>-- 
>1.7.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
