From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2] ipaddress: enable -details option
Date: Thu,  4 Dec 2014 17:41:07 +0100
Message-ID: <1417711267-13334-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20141125061023.GA8819@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, mkubecek@suse.cz, jbenc@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:50228 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbaLDQlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 11:41:13 -0500
In-Reply-To: <20141125061023.GA8819@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option was used only for 'ip link', but it can be useful to have it for
'ip address'. Thus it is possible to display link details and addresses with one
command.

Example:
$ ip -d a ls dev gre1
9: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN group default
    link/gre 10.16.0.249 peer 10.16.0.121 promiscuity 0
    gre remote 10.16.0.121 local 10.16.0.249 ttl inherit ikey 0.0.0.10 okey 0.0.0.10 icsum ocsum
    inet 192.168.0.249 peer 192.168.0.121/32 scope global gre1
       valid_lft forever preferred_lft forever
    inet6 fe80::5efe:a10:f9/64 scope link
       valid_lft forever preferred_lft forever

Suggested-by: Christophe Gouault <christophe.gouault@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: patch 'ip address' to display link details instead
    of patching 'ip link' to display addresses

 ip/ipaddress.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d993243d5f8..221ae1fc054a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -604,7 +604,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
-	if (!filter.family || filter.family == AF_PACKET) {
+	if (!filter.family || filter.family == AF_PACKET || show_details) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    link/%s ", ll_type_n2a(ifi->ifi_type, b1, sizeof(b1)));
@@ -627,14 +627,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		}
 	}
 
-	if (do_link && tb[IFLA_PROMISCUITY] && show_details)
+	if (tb[IFLA_PROMISCUITY] && show_details)
 		fprintf(fp, " promiscuity %u ",
 			*(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
 
-	if (do_link && tb[IFLA_LINKINFO] && show_details)
+	if (tb[IFLA_LINKINFO] && show_details)
 		print_linktype(fp, tb[IFLA_LINKINFO]);
 
-	if (do_link && tb[IFLA_IFALIAS]) {
+	if ((do_link || show_details) && tb[IFLA_IFALIAS]) {
 		fprintf(fp, "%s    alias %s", _SL_,
 			rta_getattr_str(tb[IFLA_IFALIAS]));
 	}
@@ -644,7 +644,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		__print_link_stats(fp, tb);
 	}
 
-	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
+	if ((do_link || show_details) && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
 		struct rtattr *i, *vflist = tb[IFLA_VFINFO_LIST];
 		int rem = RTA_PAYLOAD(vflist);
 		for (i = RTA_DATA(vflist); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
-- 
2.1.0
