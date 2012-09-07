From: Chris Friesen <chris.friesen@genband.com>
Subject: [PATCH] ip autoconfig: allow specifying a list of devices rather
 than one or all
Date: Thu, 06 Sep 2012 18:31:20 -0600
Message-ID: <50494058.10803@genband.com>
References: <50492547.8070307@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:35721 "EHLO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab2IGAbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 20:31:22 -0400
In-Reply-To: <50492547.8070307@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2012 04:35 PM, Chris Friesen wrote:

> We need to be able to boot off of both the gigE ports for redundancy, so 
> it seems like it might be a reasonable idea to extend the "ip=" boot arg 
> to allow specifying a list of devices rather than choosing between a 
> single device or all of them.
> 
> Thoughts? Anyone ever done this?

Just for kicks I tried coding it up.  This seems to work, so I include it
as fuel for discussion.  This applies to linus' current git.

Chris




Allow the user to specify up to four device names as part of IP
autoconfiguration.  This allows a degree of redundancy while also
allowing the user to limit which devices are opened by the kernel
during boot (this may be useful if some devices are very high traffic
or need special configuration).


Signed-off-by: Chris Friesen <chris.friesen@genband.com>


diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67e8a6b..4d24ad4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -157,7 +157,9 @@ static u8 ic_domain[64];		/* DNS (not NIS) domain name */
  */
 
 /* Name of user-selected boot device */
-static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
+#define NUM_NAMED_BOOTDEV 4
+static int user_dev_count __initdata;
+static char user_dev_name[NUM_NAMED_BOOTDEV][IFNAMSIZ] __initdata;
 
 /* Protocols supported by available interfaces */
 static int ic_proto_have_if __initdata = 0;
@@ -189,16 +191,27 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
+static int __init dev_in_userdevlist(struct net_device *dev)
+{
+	int i;
+	for(i=0;i<NUM_NAMED_BOOTDEV;i++) {
+		if (!strcmp(dev->name, user_dev_name[i]))
+			return 1;
+	}
+	return 0;
+}
+
 static bool __init ic_is_init_dev(struct net_device *dev)
 {
 	if (dev->flags & IFF_LOOPBACK)
 		return false;
-	return user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
+	return user_dev_count ? dev_in_userdevlist(dev) :
 	    (!(dev->flags & IFF_LOOPBACK) &&
 	     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&
 	     strncmp(dev->name, "dummy", 5));
 }
 
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
@@ -274,9 +287,8 @@ have_carrier:
 	*last = NULL;
 
 	if (!ic_first_dev) {
-		if (user_dev_name[0])
-			pr_err("IP-Config: Device `%s' not found\n",
-			       user_dev_name);
+		if (user_dev_count)
+			pr_err("IP-Config: Specified boot device(s) not found\n");
 		else
 			pr_err("IP-Config: No network devices available\n");
 		return -ENODEV;
@@ -1605,7 +1617,16 @@ static int __init ip_auto_config_setup(char *addrs)
 				ic_host_name_set = 1;
 				break;
 			case 5:
-				strlcpy(user_dev_name, ip, sizeof(user_dev_name));
+				do {
+					dp = strchr(ip, ',');
+					if (dp)
+						*dp++ = '\0';
+					strlcpy(user_dev_name[user_dev_count], ip,
+						sizeof(user_dev_name[0]));
+					user_dev_count++;
+					if (dp)
+						ip = dp;
+				} while (dp && (user_dev_count < NUM_NAMED_BOOTDEV));
 				break;
 			case 6:
 				if (ic_proto_name(ip) == 0 &&
