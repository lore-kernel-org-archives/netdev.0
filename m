From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave
 from a bond, with active usage.
Date: Thu, 8 Sep 2016 17:17:05 +0200
Message-ID: <20160908151705.GD1842@nanopsycho.orion>
References: <1473154470-15087-1-git-send-email-jasminder.kaur@hpe.com>
 <4691.1473174539@famine>
 <AT5PR84MB01151743CF3182FAFC91D7F98AFB0@AT5PR84MB0115.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
        "vfalico@gmail.com" <vfalico@gmail.com>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Gurunath, Vasundhara (STSD)" <vasundhara.gurunath@hpe.com>,
        "Arackal, Paulose Kuriakose (STSD)"
        <paulose.kuriakose.arackal@hpe.com>
To: "Kaur, Jasminder (STSD)" <jasminder.kaur@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AT5PR84MB01151743CF3182FAFC91D7F98AFB0@AT5PR84MB0115.NAMPRD84.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Sep 08, 2016 at 05:05:05PM CEST, jasminder.kaur@hpe.com wrote:
>Hi Jay,  Hi Jiri,
>
>
>
>Thank you for your inputs.
>
>
>
>Some of the requests we got for such preventive checks are from Admins working on large scale up systems with multiple NICs, FlexNICs and IP addresses.
>
>§  One use case for these checks is to give an alert, in case of any accidental removals owing to operator errors on large configurations.
>
>§  Another use case is during online maintenance activities such as dynamic patching or a driver load/unload operation.  Admin's would
>
>shut down applications and delete affected interfaces  before unload of a driver. They would prefer to get an alert during delete operation
>
>in case some usages linger around.
>
>Such alerts are more useful in Cluster configurations, Network Attached Storage( NAS) configurations, VM configurations with Guests, etc.
>
>
>
>So these were mainly the situations that prompted us to add such checks in delete paths.
>
>True these checks are not comprehensive for all use cases, we would like to extend this if it can cover more scenarios.
>
>
>
>sysfs based use cases were the ones we noticed for bond/slave configurations. Do you suggest other CLI's such as  “ip link” is more commonly used ?
>
>Possibly if these checks are rearranged a bit in code, multiple such CLI interfaces can be covered ? Please let us know.


Please avoid top-posting. It is annoying :(



>
>
>
>Thanks & Regards,
>
>Jasminder
>
>
>
>-----Original Message-----
>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>Sent: Tuesday, September 06, 2016 8:39 PM
>To: Kaur, Jasminder (STSD) <jasminder.kaur@hpe.com>
>Cc: vfalico@gmail.com; gospo@cumulusnetworks.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Gurunath, Vasundhara (STSD) <vasundhara.gurunath@hpe.com>; Arackal, Paulose Kuriakose (STSD) <paulose.kuriakose.arackal@hpe.com>
>Subject: Re: [PATCH] bonding: Prevent deletion of a bond, or the last slave from a bond, with active usage.
>
>
>
>Kaur, Jasminder <jasminder.kaur@hpe.com<mailto:jasminder.kaur@hpe.com>> wrote:
>
>
>
>>From: "Kaur, Jasminder" <jasminder.kaur@hpe.com<mailto:jasminder.kaur@hpe.com>>
>
>>
>
>>If a bond is in use such as with IP address configured, removing it can
>
>>result in application disruptions. If bond is used for cluster
>
>>communication or network file system interfaces, removing it can cause
>
>>system down time.
>
>>
>
>>An additional write option “?-” is added to sysfs bond interfaces as
>
>>below, in order to prevent accidental deletions while bond is in use.
>
>>In the absence of any usage, the below option proceeds with bond deletion.
>
>>“ echo "?-bondX" > /sys/class/net/bonding_masters “ .
>
>>If usage is detected such as an IP address configured, deletion is
>
>>prevented with appropriate message logged to syslog.
>
>
>
>                The issue of interfaces being arbitrarily changed or deleted is not specific to bonding, and could affect any networking device (physical or virtual).  Thus, if a facility such as this is to be provided, it should be generic, not specific to bonding.
>
>
>
>                Separately, I'm not sure I see the value of such an option.
>
>Other than administrator error, I'm not sure when bonds (or other
>
>interfaces) would be randomly deleted.  Are you seeing that happening?
>
>
>
>                Also, this patch does not prevent other errors or malicious change, e.g., "ip link set bondX down" or "ip addr del 1.2.3.4/24" would still cause the service disruption you're trying to avoid.
>
>
>
>                And, lastly, what Jiri said: use netlink for new bonding functionality, not sysfs.
>
>
>
>                -J
>
>
>
>>In the absence of any usage, the below option proceeds with deletion of
>
>>slaves from a bond.
>
>>“ echo "?-enoX" > /sys/class/net/bondX/bonding/slaves “ .
>
>>If usage is detected such as an IP address configured on bond, deletion
>
>>is prevented if the last slave is being removed from bond.
>
>>An appropriate message is logged to syslog.
>
>>
>
>>Signed-off-by: Jasminder Kaur <jasminder.kaur@hpe.com<mailto:jasminder.kaur@hpe.com>>
>
>>---
>
>> drivers/net/bonding/bond_options.c | 24 ++++++++++++++++++++++--
>
>> drivers/net/bonding/bond_sysfs.c   | 35 +++++++++++++++++++++++++++++++++--
>
>> 2 files changed, 55 insertions(+), 4 deletions(-)
>
>>
>
>>diff --git a/drivers/net/bonding/bond_options.c
>
>>b/drivers/net/bonding/bond_options.c
>
>>index 577e57c..e7640ea 100644
>
>>--- a/drivers/net/bonding/bond_options.c
>
>>+++ b/drivers/net/bonding/bond_options.c
>
>>@@ -1335,9 +1335,15 @@ static int bond_option_slaves_set(struct bonding *bond,
>
>>             struct net_device *dev;
>
>>             char *ifname;
>
>>             int ret;
>
>>+           struct in_device *in_dev;
>
>>
>
>>             sscanf(newval->string, "%16s", command); /* IFNAMSIZ*/
>
>>-            ifname = command + 1;
>
>>+
>
>>+           if ((command[0] == '?') && (command[1] == '-'))
>
>>+                           ifname = command + 2;
>
>>+           else
>
>>+                           ifname = command + 1;
>
>>+
>
>>             if ((strlen(command) <= 1) ||
>
>>                 !dev_valid_name(ifname))
>
>>                             goto err_no_cmd;
>
>>@@ -1356,6 +1362,20 @@ static int bond_option_slaves_set(struct bonding *bond,
>
>>                             ret = bond_enslave(bond->dev, dev);
>
>>                             break;
>
>>
>
>>+           case '?':
>
>>+                           if (command[1] == '-') {
>
>>+                                           in_dev = __in_dev_get_rtnl(bond->dev);
>
>>+                                           if ((bond->slave_cnt == 1) &&
>
>>+                                               ((in_dev->ifa_list) != NULL)) {
>
>>+                                                           netdev_info(bond->dev, "attempt to remove last slave %s from bond.\n",
>
>>+                                                                               dev->name);
>
>>+                                                           ret = -EBUSY;
>
>>+                                                           break;
>
>>+                                           }
>
>>+                           } else {
>
>>+                                           goto err_no_cmd;
>
>>+                           }
>
>>+
>
>>             case '-':
>
>>                             netdev_info(bond->dev, "Removing slave %s\n", dev->name);
>
>>                             ret = bond_release(bond->dev, dev);
>
>>@@ -1369,7 +1389,7 @@ out:
>
>>             return ret;
>
>>
>
>> err_no_cmd:
>
>>-            netdev_err(bond->dev, "no command found in slaves file - use +ifname or -ifname\n");
>
>>+           netdev_err(bond->dev, "no command found in slaves file - use +ifname
>
>>+or -ifname or ?-ifname\n");
>
>>             ret = -EPERM;
>
>>             goto out;
>
>> }
>
>>diff --git a/drivers/net/bonding/bond_sysfs.c
>
>>b/drivers/net/bonding/bond_sysfs.c
>
>>index e23c3ed..7c2ef64 100644
>
>>--- a/drivers/net/bonding/bond_sysfs.c
>
>>+++ b/drivers/net/bonding/bond_sysfs.c
>
>>@@ -102,7 +102,12 @@ static ssize_t bonding_store_bonds(struct class *cls,
>
>>             int rv, res = count;
>
>>
>
>>             sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
>
>>-            ifname = command + 1;
>
>>+
>
>>+           if ((command[0] == '?') && (command[1] == '-'))
>
>>+                           ifname = command + 2;
>
>>+           else
>
>>+                           ifname = command + 1;
>
>>+
>
>>             if ((strlen(command) <= 1) ||
>
>>                 !dev_valid_name(ifname))
>
>>                             goto err_no_cmd;
>
>>@@ -130,6 +135,32 @@ static ssize_t bonding_store_bonds(struct class *cls,
>
>>                                             res = -ENODEV;
>
>>                             }
>
>>                             rtnl_unlock();
>
>>+           } else if ((command[0] == '?') && (command[1] == '-')) {
>
>>+                           struct net_device *bond_dev;
>
>>+
>
>>+                           rtnl_lock();
>
>>+                           bond_dev = bond_get_by_name(bn, ifname);
>
>>+
>
>>+                           if (bond_dev) {
>
>>+                                           struct in_device *in_dev;
>
>>+                                           struct bonding *bond = netdev_priv(bond_dev);
>
>>+
>
>>+                                           in_dev = __in_dev_get_rtnl(bond_dev);
>
>>+
>
>>+                                           if (((in_dev->ifa_list) != NULL) &&
>
>>+                                               (bond->slave_cnt > 0)) {
>
>>+                                                           pr_err("%s is in use. Unconfigure IP %pI4 before deletion.\n",
>
>>+                                                                  ifname, &in_dev->ifa_list->ifa_local);
>
>>+                                                           rtnl_unlock();
>
>>+                                                           return -EBUSY;
>
>>+                                           }
>
>>+                                           pr_info("%s is being deleted...\n", ifname);
>
>>+                                           unregister_netdevice(bond_dev);
>
>>+                           } else {
>
>>+                                           pr_err("unable to delete non-existent %s\n", ifname);
>
>>+                                           res = -ENODEV;
>
>>+                           }
>
>>+                           rtnl_unlock();
>
>>             } else
>
>>                             goto err_no_cmd;
>
>>
>
>>@@ -139,7 +170,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
>
>>             return res;
>
>>
>
>> err_no_cmd:
>
>>-            pr_err("no command found in bonding_masters - use +ifname or -ifname\n");
>
>>+           pr_err("no command found in bonding_masters - use +ifname or -ifname
>
>>+or ?-ifname\n");
>
>>             return -EPERM;
>
>> }
>
>>
>
>>--
>
>>1.8.3.1
>
>>
>
>
>
>---
>
>                -Jay Vosburgh, jay.vosburgh@canonical.com<mailto:jay.vosburgh@canonical.com>
