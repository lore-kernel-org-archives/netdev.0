From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] dev: add support of flag IFF_NOPROC
Date: Thu,  3 Oct 2013 15:28:25 +0200
Message-ID: <1380806905-4461-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49924 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab3JCN3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 09:29:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag allows to create netdevices without creating directories in
/proc, ie no /proc/sys/net/ipv[4|6]/[conf|neigh]/<dev> and no
/proc/net/dev_snmp6/<dev>.

When a system creates a lot of virtual netdevices, this allows to speed up the
creation time. For systems which continuously create and destroy virtual
netdevices, proc entries for these netdevices may not be used, hence adding this
flag is interesting.

Note that the flag should be specified at the creation time (before calling
register_netdevice()) and cannot be removed during the life of the netdevice.

Here are some numbers:

dummy20000.batch contains 20 000 times 'link add type dummy' and
dummy20000-noproc.batch 20 000 times 'link add noproc type dummy'.

time ip -b dummy20000.batch
real    0m56.367s
user    0m0.200s
sys     0m53.070s

time ip -b dummy20000-noproc.batch
real    0m42.417s
user    0m0.310s
sys     0m38.470s

Suggested-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if.h | 2 ++
 net/core/dev.c          | 2 +-
 net/core/rtnetlink.c    | 1 +
 net/ipv4/devinet.c      | 3 +++
 net/ipv6/addrconf.c     | 3 +++
 net/ipv6/proc.c         | 5 +++++
 6 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b01e46..bb9fe5eb38bf 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -53,6 +53,8 @@
 
 #define IFF_ECHO	0x40000		/* echo sent packets		*/
 
+#define IFF_NOPROC	0x80000		/* no proc/sysctl directories	*/
+
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index c25db20a4246..13f6dd360c74 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5199,7 +5199,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
 			       IFF_AUTOMEDIA)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
-				    IFF_ALLMULTI));
+				    IFF_ALLMULTI | IFF_NOPROC));
 
 	/*
 	 *	Load in the correct multicast list now the flags have changed.
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4aedf03da052..5bad28e66fa2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1860,6 +1860,7 @@ replay:
 		}
 
 		dev->ifindex = ifm->ifi_index;
+		dev->flags |= ifm->ifi_flags & IFF_NOPROC;
 
 		if (ops->newlink)
 			err = ops->newlink(net, dev, tb, data);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcbd04ae..13b4089d8996 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2160,6 +2160,9 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 
 static void devinet_sysctl_register(struct in_device *idev)
 {
+	if (idev->dev->flags & IFF_NOPROC)
+		return;
+
 	neigh_sysctl_register(idev->dev, idev->arp_parms, "ipv4", NULL);
 	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					&idev->cnf);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd3fb301da38..e06d15ea2dba 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5032,6 +5032,9 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
+	if (idev->dev->flags & IFF_NOPROC)
+		return;
+
 	neigh_sysctl_register(idev->dev, idev->nd_parms, "ipv6",
 			      &ndisc_ifinfo_sysctl_change);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 091d066a57b3..f89911116aa7 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -274,6 +274,9 @@ int snmp6_register_dev(struct inet6_dev *idev)
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
+	if (idev->dev->flags & IFF_NOPROC)
+		return 0;
+
 	net = dev_net(idev->dev);
 	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
@@ -291,6 +294,8 @@ int snmp6_register_dev(struct inet6_dev *idev)
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
 	struct net *net = dev_net(idev->dev);
+	if (idev->dev->flags & IFF_NOPROC)
+		return 0;
 	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
 	if (!idev->stats.proc_dir_entry)
-- 
1.8.2.1
