From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] ipv6: track device renames in snmp6
Date: Thu, 26 Apr 2007 16:42:47 -0700
Message-ID: <20070426164247.3b3b2c7a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:48050 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755248AbXDZXtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 19:49:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When network device's are renamed, the IPV6 snmp6 code
gets confused. It doesn't track name changes so it will OOPS
when network device's are removed.

The fix is trivial, just unregister/re-register in notify handler.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/ipv6/addrconf.c |    6 ++++--
 net/ipv6/proc.c     |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

--- linux-2.6.orig/net/ipv6/addrconf.c	2007-04-25 10:19:07.000000000 -0700
+++ linux-2.6/net/ipv6/addrconf.c	2007-04-26 16:37:36.000000000 -0700
@@ -2281,8 +2281,9 @@ static int addrconf_notify(struct notifi
 		break;
 
 	case NETDEV_CHANGENAME:
-#ifdef CONFIG_SYSCTL
 		if (idev) {
+			snmp6_unregister_dev(idev);
+#ifdef CONFIG_SYSCTL
 			addrconf_sysctl_unregister(&idev->cnf);
 			neigh_sysctl_unregister(idev->nd_parms);
 			neigh_sysctl_register(dev, idev->nd_parms,
@@ -2290,8 +2291,9 @@ static int addrconf_notify(struct notifi
 					      &ndisc_ifinfo_sysctl_change,
 					      NULL);
 			addrconf_sysctl_register(idev, &idev->cnf);
-		}
 #endif
+			snmp6_register_dev(idev);
+		}
 		break;
 	};
 
--- linux-2.6.orig/net/ipv6/proc.c	2007-04-10 10:11:19.000000000 -0700
+++ linux-2.6/net/ipv6/proc.c	2007-04-26 16:37:36.000000000 -0700
@@ -236,6 +236,7 @@ int snmp6_unregister_dev(struct inet6_de
 		return -EINVAL;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
+	idev->stats.proc_dir_entry = NULL;
 	return 0;
 }
 
