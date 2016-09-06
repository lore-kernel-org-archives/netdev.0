From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave from a bond, with active usage.
Date: Tue, 06 Sep 2016 08:08:59 -0700
Message-ID: <4691.1473174539@famine>
References: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vasundhara.gurunath@hpe.com, paulose.kuriakose.arackal@hpe.com
To: "Kaur\, Jasminder" <jasminder.kaur@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48405 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933550AbcIFPJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 11:09:05 -0400
In-reply-to: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kaur, Jasminder <jasminder.kaur@hpe.com> wrote:

>From: "Kaur, Jasminder" <jasminder.kaur@hpe.com>
>
>If a bond is in use such as with IP address configured, removing it
>can result in application disruptions. If bond is used for cluster
>communication or network file system interfaces, removing it can cause
>system down time.
>
>An additional write option “?-” is added to sysfs bond interfaces as
>below, in order to prevent accidental deletions while bond is in use.
>In the absence of any usage, the below option proceeds with bond deletion.
>“ echo "?-bondX" > /sys/class/net/bonding_masters “ .
>If usage is detected such as an IP address configured, deletion is
>prevented with appropriate message logged to syslog.

	The issue of interfaces being arbitrarily changed or deleted is
not specific to bonding, and could affect any networking device
(physical or virtual).  Thus, if a facility such as this is to be
provided, it should be generic, not specific to bonding.

	Separately, I'm not sure I see the value of such an option.
Other than administrator error, I'm not sure when bonds (or other
interfaces) would be randomly deleted.  Are you seeing that happening?

	Also, this patch does not prevent other errors or malicious
change, e.g., "ip link set bondX down" or "ip addr del 1.2.3.4/24" would
still cause the service disruption you're trying to avoid.

	And, lastly, what Jiri said: use netlink for new bonding
functionality, not sysfs.

	-J

>In the absence of any usage, the below option proceeds with deletion of
>slaves from a bond.
>“ echo "?-enoX" > /sys/class/net/bondX/bonding/slaves “ .
>If usage is detected such as an IP address configured on bond, deletion
>is prevented if the last slave is being removed from bond.
>An appropriate message is logged to syslog.
>
>Signed-off-by: Jasminder Kaur <jasminder.kaur@hpe.com>
>---
> drivers/net/bonding/bond_options.c | 24 ++++++++++++++++++++++--
> drivers/net/bonding/bond_sysfs.c   | 35 +++++++++++++++++++++++++++++++++--
> 2 files changed, 55 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 577e57c..e7640ea 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -1335,9 +1335,15 @@ static int bond_option_slaves_set(struct bonding *bond,
> 	struct net_device *dev;
> 	char *ifname;
> 	int ret;
>+	struct in_device *in_dev;
> 
> 	sscanf(newval->string, "%16s", command); /* IFNAMSIZ*/
>-	ifname = command + 1;
>+
>+	if ((command[0] == '?') && (command[1] == '-'))
>+		ifname = command + 2;
>+	else
>+		ifname = command + 1;
>+
> 	if ((strlen(command) <= 1) ||
> 	    !dev_valid_name(ifname))
> 		goto err_no_cmd;
>@@ -1356,6 +1362,20 @@ static int bond_option_slaves_set(struct bonding *bond,
> 		ret = bond_enslave(bond->dev, dev);
> 		break;
> 
>+	case '?':
>+		if (command[1] == '-') {
>+			in_dev = __in_dev_get_rtnl(bond->dev);
>+			if ((bond->slave_cnt == 1) &&
>+			    ((in_dev->ifa_list) != NULL)) {
>+				netdev_info(bond->dev, "attempt to remove last slave %s from bond.\n",
>+					    dev->name);
>+				ret = -EBUSY;
>+				break;
>+			}
>+		} else {
>+			goto err_no_cmd;
>+		}
>+
> 	case '-':
> 		netdev_info(bond->dev, "Removing slave %s\n", dev->name);
> 		ret = bond_release(bond->dev, dev);
>@@ -1369,7 +1389,7 @@ out:
> 	return ret;
> 
> err_no_cmd:
>-	netdev_err(bond->dev, "no command found in slaves file - use +ifname or -ifname\n");
>+	netdev_err(bond->dev, "no command found in slaves file - use +ifname or -ifname or ?-ifname\n");
> 	ret = -EPERM;
> 	goto out;
> }
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index e23c3ed..7c2ef64 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -102,7 +102,12 @@ static ssize_t bonding_store_bonds(struct class *cls,
> 	int rv, res = count;
> 
> 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
>-	ifname = command + 1;
>+
>+	if ((command[0] == '?') && (command[1] == '-'))
>+		ifname = command + 2;
>+	else
>+		ifname = command + 1;
>+
> 	if ((strlen(command) <= 1) ||
> 	    !dev_valid_name(ifname))
> 		goto err_no_cmd;
>@@ -130,6 +135,32 @@ static ssize_t bonding_store_bonds(struct class *cls,
> 			res = -ENODEV;
> 		}
> 		rtnl_unlock();
>+	} else if ((command[0] == '?') && (command[1] == '-')) {
>+		struct net_device *bond_dev;
>+
>+		rtnl_lock();
>+		bond_dev = bond_get_by_name(bn, ifname);
>+
>+		if (bond_dev) {
>+			struct in_device *in_dev;
>+			struct bonding *bond = netdev_priv(bond_dev);
>+
>+			in_dev = __in_dev_get_rtnl(bond_dev);
>+
>+			if (((in_dev->ifa_list) != NULL) &&
>+			    (bond->slave_cnt > 0)) {
>+				pr_err("%s is in use. Unconfigure IP %pI4 before deletion.\n",
>+				       ifname, &in_dev->ifa_list->ifa_local);
>+				rtnl_unlock();
>+				return -EBUSY;
>+			}
>+			pr_info("%s is being deleted...\n", ifname);
>+			unregister_netdevice(bond_dev);
>+		} else {
>+			pr_err("unable to delete non-existent %s\n", ifname);
>+			res = -ENODEV;
>+		}
>+		rtnl_unlock();
> 	} else
> 		goto err_no_cmd;
> 
>@@ -139,7 +170,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
> 	return res;
> 
> err_no_cmd:
>-	pr_err("no command found in bonding_masters - use +ifname or -ifname\n");
>+	pr_err("no command found in bonding_masters - use +ifname or -ifname or ?-ifname\n");
> 	return -EPERM;
> }
> 
>-- 
>1.8.3.1
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
