From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [-net,v2,1/2] bonding: fix store_arp_validate race with mode
 change
Date: Tue, 10 Sep 2013 20:15:29 +0200
Message-ID: <20130910181529.GF8474@redhat.com>
References: <1378504826-18855-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab3IJSRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 14:17:35 -0400
Content-Disposition: inline
In-Reply-To: <1378504826-18855-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 12:00:25AM +0200, nikolay@redhat.com wrote:
>We need to protect store_arp_validate via rtnl because it can race with
>mode changing and we can end up having arp_validate set in a mode
>different from active-backup.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>---
>v2: no change
>
> drivers/net/bonding/bond_sysfs.c | 14 ++++++++++----
> 1 file changed, 10 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ce46776..4e38683 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -419,27 +419,33 @@ static ssize_t bonding_store_arp_validate(struct device *d,
> 					  struct device_attribute *attr,
> 					  const char *buf, size_t count)
> {
>-	int new_value;
>+	int new_value, ret = count;
> 	struct bonding *bond = to_bond(d);

p.s. If, by any chance, there'll be another v3 - move that struct before
ints :). But it's ok as is, anyway.

>
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 	new_value = bond_parse_parm(buf, arp_validate_tbl);
> 	if (new_value < 0) {
> 		pr_err("%s: Ignoring invalid arp_validate value %s\n",
> 		       bond->dev->name, buf);
>-		return -EINVAL;
>+		ret = -EINVAL;
>+		goto out;
> 	}
> 	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
> 		pr_err("%s: arp_validate only supported in active-backup mode.\n",
> 		       bond->dev->name);
>-		return -EINVAL;
>+		ret = -EINVAL;
>+		goto out;
> 	}
> 	pr_info("%s: setting arp_validate to %s (%d).\n",
> 		bond->dev->name, arp_validate_tbl[new_value].modename,
> 		new_value);
>
> 	bond->params.arp_validate = new_value;
>+out:
>+	rtnl_unlock();
>
>-	return count;
>+	return ret;
> }
>
> static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
