From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [stable] [PATCH] ipv6: track device renames in snmp6
Date: Fri, 27 Apr 2007 11:17:57 -0700
Message-ID: <20070427111757.35ac3a52@freekitty>
References: <20070426164247.3b3b2c7a@freekitty>
	<20070427041659.GB4841@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ???????????? <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34690 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754309AbXD0STh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 14:19:37 -0400
In-Reply-To: <20070427041659.GB4841@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That patch I sent was against 2.6.21, but both 2.6.20 and 2.6.21 have
the problem.  Here is a version for 2.6.20.
=============================================

When network device's are renamed, the IPV6 snmp6 code
gets confused. It doesn't track name changes so it will OOPS
when network device's are removed.

The fix is trivial, just unregister/re-register in notify handler.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/ipv6/addrconf.c |    6 ++++--
 net/ipv6/proc.c     |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

--- linux-2.6.20.y.orig/net/ipv6/addrconf.c	2007-04-27 11:14:51.000000000 -0700
+++ linux-2.6.20.y/net/ipv6/addrconf.c	2007-04-27 11:16:26.000000000 -0700
@@ -2338,8 +2338,9 @@ static int addrconf_notify(struct notifi
 		break;
 
 	case NETDEV_CHANGENAME:
-#ifdef CONFIG_SYSCTL
 		if (idev) {
+			snmp6_unregister_dev(idev);
+#ifdef CONFIG_SYSCTL
 			addrconf_sysctl_unregister(&idev->cnf);
 			neigh_sysctl_unregister(idev->nd_parms);
 			neigh_sysctl_register(dev, idev->nd_parms,
@@ -2347,8 +2348,9 @@ static int addrconf_notify(struct notifi
 					      &ndisc_ifinfo_sysctl_change,
 					      NULL);
 			addrconf_sysctl_register(idev, &idev->cnf);
-		}
 #endif
+			snmp6_register_dev(idev);
+		}
 		break;
 	};
 
--- linux-2.6.20.y.orig/net/ipv6/proc.c	2007-02-23 15:34:07.000000000 -0800
+++ linux-2.6.20.y/net/ipv6/proc.c	2007-04-27 11:16:26.000000000 -0700
@@ -237,6 +237,7 @@ int snmp6_unregister_dev(struct inet6_de
 		return -EINVAL;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
+	idev->stats.proc_dir_entry = NULL;
 	return 0;
 }
 
