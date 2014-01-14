From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2 net-next] bonding: handle slave's name change with primary_slave logic
Date: Tue, 14 Jan 2014 09:32:59 -0800
Message-ID: <4299.1389720779@death.nxdomain>
References: <1389700179-12723-1-git-send-email-vfalico@redhat.com>
Cc: netdev@vger.kernel.org, Ding Tianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:33508 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbaANRdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 12:33:09 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 14 Jan 2014 12:33:08 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 774ACC90067
	for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 12:33:01 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0EHX3l45439958
	for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 17:33:03 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0EHX24a032031
	for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 12:33:03 -0500
In-reply-to: <1389700179-12723-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@redhat.com> wrote:

>Currently, if a slave's name change, we just pass it by. However, if the
>slave is a current primary_slave, then we end up with using a slave, whose
>name != params.primary, for primary_slave. And vice-versa, if we don't have
>a primary_slave but have params.primary set - we will not detected a new
>primary_slave.
>
>Fix this by catching the NETDEV_CHANGENAME event and setting primary_slave
>accordingly. Also, if the primary_slave was changed, issue a reselection of
>the active slave, cause the priorities have changed.
>
>Reported-by: Ding Tianhong <dingtianhong@huawei.com>
>CC: Ding Tianhong <dingtianhong@huawei.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_main.c | 23 ++++++++++++++++++++---
> 1 file changed, 20 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e06c445..8077199 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2860,9 +2860,26 @@ static int bond_slave_netdev_event(unsigned long event,
> 		 */
> 		break;
> 	case NETDEV_CHANGENAME:
>-		/*
>-		 * TODO: handle changing the primary's name
>-		 */
>+		/* we don't care if we don't have primary set */
>+		if (!USES_PRIMARY(bond->params.mode) ||
>+		    !bond->params.primary[0])
>+			break;
>+
>+		if (slave == bond->primary_slave) {
>+			/* slave's name changed - he's no longer primary */
>+			bond->primary_slave = NULL;
>+		} else if (!strcmp(slave_dev->name, bond->params.primary)) {
>+			/* we have a new primary slave */
>+			bond->primary_slave = slave;
>+		} else  /* we didn't change primary - exit */
>+			break;
>+
>+		pr_info("%s: Primary slave changed to %s, re-electing.\n",

	I suspect you mean "reselecting" here, not "re-electing."  I'd
add a couple more words, e.g., "reselecting active slave" to make it
clearer.

	-J

>+			bond->dev->name, bond->primary_slave ? slave_dev->name :
>+							       "none");
>+		write_lock_bh(&bond->curr_slave_lock);
>+		bond_select_active_slave(bond);
>+		write_unlock_bh(&bond->curr_slave_lock);
> 		break;
> 	case NETDEV_FEAT_CHANGE:
> 		bond_compute_features(bond);
>-- 
>1.8.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
