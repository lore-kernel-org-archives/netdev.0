From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V5 2/2] bonding: Prevent duplicate userspace notification
Date: Thu, 25 May 2017 11:31:55 -0400
Message-ID: <1495726316-27626-3-git-send-email-vyasevic@redhat.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
Cc: dsahern@gmail.com, roopa@cumulusnetworks.com, jiri@resnulli.us,
        vfalico@gmail.com, andy@greyhouse.net,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34285 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965246AbdEYPcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 11:32:20 -0400
Received: by mail-qk0-f196.google.com with SMTP id u75so30503316qka.1
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 08:32:20 -0700 (PDT)
In-Reply-To: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever a user changes bonding options, a NETDEV_CHANGEINFODATA
notificatin is generated which results in a rtnelink message to
be sent.  While runnig 'ip monitor', we can actually see 2 messages,
one a result of the event, and the other a result of state change
that is generated bo netdev_state_change().  However, this is not
always the case. If bonding changes were done via sysfs or ifenslave
(old ioctl interface), then only 1 message is seen.

This patch removes duplicate messages in the case of using netlink
to configure bonding.  It introduceds a separte function that
triggers a netdev event and uses that function in the syfs and ioctl
cases.

This was discovered while auditing all the different envents and
continues the effort of cleaning up duplicated netlink messages.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/bonding/bond_main.c    |  3 ++-
 drivers/net/bonding/bond_options.c | 27 +++++++++++++++++++++++++--
 include/net/bond_options.h         |  2 ++
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7331331..d7aa137 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3481,7 +3481,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	case BOND_CHANGE_ACTIVE_OLD:
 	case SIOCBONDCHANGEACTIVE:
 		bond_opt_initstr(&newval, slave_dev->name);
-		res = __bond_opt_set(bond, BOND_OPT_ACTIVE_SLAVE, &newval);
+		res = __bond_opt_set_notify(bond, BOND_OPT_ACTIVE_SLAVE,
+					    &newval);
 		break;
 	default:
 		res = -EOPNOTSUPP;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1bcbb89..8ca6833 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -673,7 +673,30 @@ int __bond_opt_set(struct bonding *bond,
 out:
 	if (ret)
 		bond_opt_error_interpret(bond, opt, ret, val);
-	else if (bond->dev->reg_state == NETREG_REGISTERED)
+
+	return ret;
+}
+/**
+ * __bond_opt_set_notify - set a bonding option
+ * @bond: target bond device
+ * @option: option to set
+ * @val: value to set it to
+ *
+ * This function is used to change the bond's option value and trigger
+ * a notification to user sapce. It can be used for both enabling/changing
+ * an option and for disabling it. RTNL lock must be obtained before calling
+ * this function.
+ */
+int __bond_opt_set_notify(struct bonding *bond,
+			  unsigned int option, struct bond_opt_value *val)
+{
+	int ret = -ENOENT;
+
+	ASSERT_RTNL();
+
+	ret = __bond_opt_set(bond, option, val);
+
+	if (!ret && (bond->dev->reg_state == NETREG_REGISTERED))
 		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
 
 	return ret;
@@ -696,7 +719,7 @@ int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf)
 	if (!rtnl_trylock())
 		return restart_syscall();
 	bond_opt_initstr(&optval, buf);
-	ret = __bond_opt_set(bond, option, &optval);
+	ret = __bond_opt_set_notify(bond, option, &optval);
 	rtnl_unlock();
 
 	return ret;
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
index 1797235..d79d28f 100644
--- a/include/net/bond_options.h
+++ b/include/net/bond_options.h
@@ -104,6 +104,8 @@ struct bond_option {
 
 int __bond_opt_set(struct bonding *bond, unsigned int option,
 		   struct bond_opt_value *val);
+int __bond_opt_set_notify(struct bonding *bond, unsigned int option,
+			  struct bond_opt_value *val);
 int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
 
 const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
-- 
2.7.4
