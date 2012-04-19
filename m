From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 01/19] net: Implement register_net_sysctl.
Date: Thu, 19 Apr 2012 16:18:47 -0700
Message-ID: <m162cvia3s.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44445 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929Ab2DSXOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:14:47 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now all of the networking sysctl registrations are running in a
compatibiity mode.  The natvie sysctl registration api takes a cstring
for a path and a simple ctl_table.  Implement register_net_sysctl so
that we can register network sysctls without needing to use
compatiblity code in the sysctl core.

Switching from a ctl_path to a cstring results in less boiler plate
and denser code that is a little easier to read.

I would simply have changed the arguments to register_net_sysctl_table
instead of keeping two functions in parallel but gcc will allow a
ctl_path pointer to be passed to a char * pointer with only issuing a
warning resulting in completely incorrect code can be built.  Since I
have to change the function name I am taking advantage of the situation
to let both register_net_sysctl and register_net_sysctl_table live for a
short time in parallel which makes clean conversion patches a bit easier
to read and write.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    2 ++
 net/sysctl_net.c            |    7 +++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ee547c1..446245e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -287,6 +287,8 @@ extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
 extern struct ctl_table_header *register_net_sysctl_rotable(
 	const struct ctl_path *path, struct ctl_table *table);
+extern struct ctl_table_header *register_net_sysctl(struct net *net,
+	const char *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
 
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index c3e65ae..3865c4f 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -117,6 +117,13 @@ struct ctl_table_header *register_net_sysctl_rotable(const
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
 
+struct ctl_table_header *register_net_sysctl(struct net *net,
+	const char *path, struct ctl_table *table)
+{
+	return __register_sysctl_table(&net->sysctls, path, table);
+}
+EXPORT_SYMBOL_GPL(register_net_sysctl);
+
 void unregister_net_sysctl_table(struct ctl_table_header *header)
 {
 	unregister_sysctl_table(header);
-- 
1.7.2.5
