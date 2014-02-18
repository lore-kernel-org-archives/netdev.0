From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 1/3] bonding: add bond_set_slave_state/flags()
Date: Mon, 17 Feb 2014 18:08:22 -0800
Message-ID: <5329.1392689302@death.nxdomain>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-2-git-send-email-dingtianhong@huawei.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, cwang@twopensource.com,
	jiri@resnulli.us, thomas@glanzmann.de, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44721 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaBRCIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 21:08:30 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 17 Feb 2014 19:08:29 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1C34919D8036
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:08:25 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I28QWB8716772
	for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 03:08:26 +0100
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I28OQK016547
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:08:25 -0700
In-reply-to: <1392626151-23916-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The new function could change the slave state and flags, then call
>rtmsg_ifinfo() according to the input parameters notify.
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bonding.h | 26 ++++++++++++++++++++++++++
> 1 file changed, 26 insertions(+)
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 86ccfb9..d210124 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -303,6 +303,18 @@ static inline void bond_set_backup_slave(struct slave *slave)
> 	}
> }
>
>+static inline void bond_set_slave_state(struct slave *slave,
>+					int slave_state, bool notify)
>+{
>+	if (slave->backup != slave_state)
>+		slave->backup = slave_state;
>+	else
>+		return;
>+
>+	if (notify)
>+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);

	I think this would be clearer if coded as:

	if (slave->backup == slave_slave)
		return;

	slave->backup = slave_state;
	if (notify)
		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);

>+}
>+
> static inline void bond_slave_state_change(struct bonding *bond)
> {
> 	struct list_head *iter;
>@@ -408,6 +420,20 @@ static inline void bond_set_slave_active_flags(struct slave *slave)
> 	slave->inactive = 0;
> }
>
>+static inline void bond_set_slave_flags(struct slave *slave,
>+					int state, bool notify)
>+
>+{
>+	if (state == BOND_STATE_ACTIVE) {
>+		bond_set_slave_state(slave, state, notify);
>+		slave->inactive = 0;
>+	} else if (state == BOND_STATE_BACKUP && !bond_is_lb(slave->bond)) {
>+		bond_set_slave_state(slave, state, notify);
>+		if (!slave->bond->params.all_slaves_active)
>+			slave->inactive = 1;
>+	}
>+}

	As I said in my other reply, I don't see why this shouldn't be
integrated into the existing state change functions instead of creating
a new function.

	-J

> static inline bool bond_is_slave_inactive(struct slave *slave)
> {
> 	return slave->inactive;
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
