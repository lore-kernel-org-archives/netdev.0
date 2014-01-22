From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 1/5] bonding: The fail_over_mac should be set only in ACTIVE_BACKUP mode
Date: Tue, 21 Jan 2014 16:25:26 -0800
Message-ID: <20332.1390350326@death.nxdomain>
References: <52DE4161.3050801@huawei.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:33368 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbaAVAZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:25:32 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 21 Jan 2014 17:25:32 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D4E9C1FF001A
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 17:24:57 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0M0PTe28519986
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 01:25:29 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0M0PTBJ025191
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 17:25:29 -0700
In-reply-to: <52DE4161.3050801@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>According the bonding.txt, the option fail_over_mac only affect for
>AB mode, but in currect code, the parameter could be set to active
>or follow in every mode, this will cause bonding could not set all
>slaves of an RR or XOR mode to the same MAC address at enslavement
>time, so reset fail_over_mac to 0 if the mode is not ACTIVE_BACKUP.

	The correct way to fix this in general is to permit setting an
option at any time, but only have it take effect in active-backup mode.
This minimizes ordering requirements when setting options.

	I would instead modify the bond enslave and removal processing
to check the mode in addition to fail_over_mac when setting a slave's
MAC during enslavement.  The change active slave processing already only
calls the fail_over_mac function when in active-backup mode.  This
should also be a simpler change set.

>Fix the wrong variables for pr_err().
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 3220b48..ecff04e 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4307,12 +4307,14 @@ static int bond_check_params(struct bond_params *params)
> 						      fail_over_mac_tbl);
> 		if (fail_over_mac_value == -1) {
> 			pr_err("Error: invalid fail_over_mac \"%s\"\n",
>-			       arp_validate == NULL ? "NULL" : arp_validate);
>+			       fail_over_mac == NULL ? "NULL" : fail_over_mac);

	This part is ok.

> 			return -EINVAL;
> 		}
>
>-		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
>-			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
>+		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
>+			pr_warning("Warning: fail_over_mac only affects active-backup mode, set it to 0.\n");
>+			fail_over_mac_value = BOND_FOM_NONE;
>+		}

	This part is not.

	I would additionally NAK patches 2, 3, and 4 (noting that 4
inhibits the change to fail_over_mac, but not the warning message that
we're changing it).

	Patch 5 is ok, although it really has nothing to do with
fail_over_mac.

	-J

> 	} else {
> 		fail_over_mac_value = BOND_FOM_NONE;
> 	}
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
