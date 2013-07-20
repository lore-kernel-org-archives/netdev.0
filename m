From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [3/4] bonding: the calling of bond->slave_cnt need protection
Date: Sat, 20 Jul 2013 12:47:46 +0200
Message-ID: <20130720104746.GC9149@redhat.com>
References: <51EA3B0D.7020501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab3GTKsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 06:48:31 -0400
Content-Disposition: inline
In-Reply-To: <51EA3B0D.7020501@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 20, 2013 at 03:23:57PM +0800, dingtianhong wrote:
>The bonding_store_mode has rtnl protection, so no need to get read lock
>for bond->slave_cnt, but the bonding_store_fail_over_mac need to protect
>the bond->slave_cnt, so add read_lock().
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>
>---
>drivers/net/bonding/bond_sysfs.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index dc36a3d..d01a189 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -504,11 +504,14 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
> 	int new_value;
> 	struct bonding *bond = to_bond(d);
>
>+	read_lock(&bond->lock);
> 	if (bond->slave_cnt != 0) {
> 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
> 		       bond->dev->name);
>+		read_unlock(&bond->lock);
> 		return -EPERM;
> 	}
>+	read_unlock(&bond->lock);

Maybe it's Saturday, but I really don't see *any* point in this locking.

I think you've meant that we need the rtnl protection while reading
slave_cnt AND updating the .fail_over_mac, so that in between we won't add
new slaves with outdated params.

Something like this (untested):

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dc36a3d..8a5a6a3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -501,20 +501,25 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
  					   struct device_attribute *attr,
  					   const char *buf, size_t count)
  {
-	int new_value;
+	int new_value, ret = count;
  	struct bonding *bond = to_bond(d);
  
+	if (!rtnl_trylock())
+		return restart_syscall();
+
  	if (bond->slave_cnt != 0) {
  		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
  		       bond->dev->name);
-		return -EPERM;
+		ret = -EPERM;
+		goto out;
  	}
  
  	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
  	if (new_value < 0) {
  		pr_err("%s: Ignoring invalid fail_over_mac value %s.\n",
  		       bond->dev->name, buf);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out;
  	}
  
  	bond->params.fail_over_mac = new_value;
@@ -522,7 +527,9 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
  		bond->dev->name, fail_over_mac_tbl[new_value].modename,
  		new_value);
  
-	return count;
+out:
+	rtnl_unlock();
+	return ret;
  }
  
  static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR,
>
> 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
> 	if (new_value < 0) {
