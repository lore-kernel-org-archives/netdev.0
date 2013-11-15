From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] bonding: set primary_reselect in LB and AB mode
Date: Fri, 15 Nov 2013 10:02:45 -0800
Message-ID: <4031.1384538565@death.nxdomain>
References: <5285F130.5060705@huawei.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:46701 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046Ab3KOSCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 13:02:50 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 15 Nov 2013 13:02:49 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1AE2938C8045
	for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 13:02:46 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAFI2lGG50725044
	for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 18:02:47 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAFI2k5q011497
	for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 13:02:47 -0500
In-reply-to: <5285F130.5060705@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The primary_reselect only reselection for the primary slave,
>but the primary slave only support for ALB, TLB and AB mode,
>so we sould set the primary_reselect for these mode.
>
>to fix this: Add a check for ALB, TLB and AB mode in
>bonding_store_primary_reselect, avoid to select active slave
>again in other modes.

	I don't believe that setting primary_reselect in a
!USES_PRIMARY() mode has any negative effects.  It doesn't do anything,
but also doesn't break anything.  Is there a case that setting
primary_reselect causes misbehavior in a !USES_PRIMARY() mode?

	Presuming that primary_reselect doesn't break things, this just
adds an ordering limitation when configuring bonding (mode must be set
prior to primary_reselect).  I don't believe this change adds any value,
and may break existing configuration scripts.

	-J

>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_sysfs.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 47749c9..cac2291 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1141,6 +1141,13 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
> 	if (!rtnl_trylock())
> 		return restart_syscall();
>
>+	if (!USES_PRIMARY(bond->params.mode)) {
>+		pr_info("%s: Unable to set primary reselect; %s is in mode %d\n",
>+			bond->dev->name, bond->dev->name, bond->params.mode);
>+		ret = -EINVAL;
>+		goto out;
>+	}
>+
> 	new_value = bond_parse_parm(buf, pri_reselect_tbl);
> 	if (new_value < 0)  {
> 		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
>-- 
>1.7.12

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
