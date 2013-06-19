From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 1/6] bonding: verify if bond has ip only once on
 arp validate
Date: Wed, 19 Jun 2013 20:48:38 +0200
Message-ID: <20130619184838.GA22345@redhat.com>
References: <1371663286-12518-2-git-send-email-vfalico@redhat.com>
 <27844.1371664224@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964953Ab3FSStT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:49:19 -0400
Content-Disposition: inline
In-Reply-To: <27844.1371664224@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 10:50:24AM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
>
>>It's extra work to verify bond's ip presence for every slave, so take it
>>out of the loop.
>
>	The current code doesn't verify for every slave (target address,
>actually).  The call to bond_has_this_ip() happens at most once, if the
>sip (source IP) matches the arp_ip_target being inspected, after which
>the function returns.
>
>	I can see that the patch will bypass the loop entirely if the
>bond lacks the IP, but I'm not sure that's a meaningful improvement,
>since it changes from calling bond_has_this_ip 0 or 1 times to always 1
>time.

Yep, you're right, I've misread the code.

It's just not worth it, will drop this patch in v2.

>
>	-J
>
>
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>---
>> drivers/net/bonding/bond_main.c |   13 ++++++++-----
>> 1 files changed, 8 insertions(+), 5 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index bc1246f..3d8b5ba 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -2602,13 +2602,16 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
>> 	int i;
>> 	__be32 *targets = bond->params.arp_targets;
>>
>>+	if (!bond_has_this_ip(bond, tip)) {
>>+		pr_debug("bva: tip %pI4 not found\n", &tip);
>>+		return;
>>+	}
>>+
>> 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
>>-		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
>>-			 &sip, &tip, i, &targets[i],
>>-			 bond_has_this_ip(bond, tip));
>>+		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip)\n",
>>+			 &sip, &tip, i, &targets[i]);
>> 		if (sip == targets[i]) {
>>-			if (bond_has_this_ip(bond, tip))
>>-				slave->last_arp_rx = jiffies;
>>+			slave->last_arp_rx = jiffies;
>> 			return;
>> 		}
>> 	}
>>--
>>1.7.1
>>
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
