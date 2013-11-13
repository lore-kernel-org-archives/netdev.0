From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net RESEND] bonding: add ip checks when store ip target
Date: Wed, 13 Nov 2013 11:00:00 +0100
Message-ID: <20131113100000.GH19702@redhat.com>
References: <5282E196.8030401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759054Ab3KMKCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 05:02:23 -0500
Content-Disposition: inline
In-Reply-To: <5282E196.8030401@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 10:19:02AM +0800, Ding Tianhong wrote:
>I met a Bug when I add ip target with the wrong ip address:
>
>echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target
>
>the wrong ip address will transfor to 245.245.245.244 and add
>to the ip target success, it is uncorrect, so I add checks to avoid
>adding wrong address.
>
>The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
>the next check and will not add to ip target.
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_sysfs.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ec9b646..e0c97fb 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -653,7 +653,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
> 	int ind, i, j, ret = -EINVAL;
>
> 	targets = bond->params.arp_targets;
>-	newtarget = in_aton(buf + 1);
>+	in4_pton(buf + 1, strlen(buf) - 1, (u8 *)&newtarget, -1, NULL);

No need for strlen(buf)-1, if you specify -1 it will compute it by itself.

Also, you might simplify the code a bit in the function. Otherwise - looks
good, thank you.

Untested patch:

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c29b836..e3fff6e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -661,16 +661,16 @@ static ssize_t bonding_store_arp_targets(struct device *d,
  	unsigned long *targets_rx;
  	int ind, i, j, ret = -EINVAL;
  
+	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL)) {
+		pr_err("%s: invalid ARP target specified, use +<addr> or -<addr>\n",
+		       bond->dev->name);
+		goto out;
+	}
+
  	targets = bond->params.arp_targets;
-	newtarget = in_aton(buf + 1);
+
  	/* look for adds */
  	if (buf[0] == '+') {
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
  		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
  			pr_err("%s: ARP target %pI4 is already present\n",
  			       bond->dev->name, &newtarget);
@@ -693,12 +693,6 @@ static ssize_t bonding_store_arp_targets(struct device *d,
  		targets[ind] = newtarget;
  		write_unlock_bh(&bond->lock);
  	} else if (buf[0] == '-')	{
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
  		ind = bond_get_targets_ip(targets, newtarget);
  		if (ind == -1) {
  			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
