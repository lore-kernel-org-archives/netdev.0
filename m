From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] bonding: permit enslaving interfaces without
 set_mac support
Date: Thu, 17 Jul 2014 21:31:30 +0200
Message-ID: <20140717193130.GA23793@mikrodark.usersys.redhat.com>
References: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
 <12382.1405624891@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:59988 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbaGQTe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 15:34:29 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so2529559wgh.8
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 12:34:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <12382.1405624891@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 12:21:31PM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@gmail.com> wrote:
>
>>Currently we exit if the slave isn't the first slave, doesn't support mac
>>address setting and fail_over_mac isn't FOM_ACTIVE. It's wrong because we
>>only require ndo_set_mac_address in case bonding is in active-backup mode
>>and FOM isn't FOM_ACTIVE.
>>
>>To fix this - only exit with an error if we're in a/b mode and have
>>fail_over_mac != FOM_ACTIVE.
>>
>>Also, maintain current behaviour on the first slave (forcibly change fom to
>>FOM_ACTIVE) to not break anyone's configuration.
>
>	I'm just catching up on this, so I apologize for being late to
>the party here, but the main point of that test was to prohibit slaves
>that cannot change their MAC from joining a bond whose mode requires
>changing the MAC (which is all of them except for active-backup).
>
>	It looks like the new code path will still fail when
>bond_enslave() later on attempts to change the MAC, as long as
>fail_over_mac is not set.  If f_o_m is set, the enslave will succeed,
>after bypassing the dev_set_mac_address call.  That in turn would seem
>to allow creating a bond of any mode, setting fail_over_mac, then
>filling it with, e.g., ipoib devices.  That bond won't function
>correctly in the modes other than active-backup.

Hm, good catch, it wasn't covered in my testing I guess. I don't have the
time/code at hand right now, so can't re-test it.

I'll verify it tomorrow and, if it's true (most probably), will send a
follow-up.

Thank you!

>
>	Am I missing something here?
>
>	-J
>
>>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>>---
>> drivers/net/bonding/bond_main.c | 19 ++++++++++---------
>> 1 file changed, 10 insertions(+), 9 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index 09dc3ef..e0a33b5 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1298,19 +1298,20 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 	}
>>
>> 	if (slave_ops->ndo_set_mac_address == NULL) {
>>-		if (!bond_has_slaves(bond)) {
>>-			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address\n",
>>-				bond_dev->name);
>>-			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) {
>>+		pr_warn("%s: Warning: The slave device specified does not support setting the MAC address\n",
>>+			bond_dev->name);
>>+		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
>>+		    bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
>>+			if (!bond_has_slaves(bond)) {
>> 				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
>> 				pr_warn("%s: Setting fail_over_mac to active for active-backup mode\n",
>> 					bond_dev->name);
>>+			} else {
>>+				pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
>>+				       bond_dev->name);
>>+				res = -EOPNOTSUPP;
>>+				goto err_undo_flags;
>> 			}
>>-		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
>>-			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
>>-			       bond_dev->name);
>>-			res = -EOPNOTSUPP;
>>-			goto err_undo_flags;
>> 		}
>> 	}
>>
>>--
>>1.8.4
>>
>
>---
>	-Jay Vosburgh, jay.vosburgh@canonical.com
