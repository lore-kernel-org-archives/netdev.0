From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] iplink: allow to show ip addresses
Date: Mon, 24 Nov 2014 17:42:17 +0100
Message-ID: <1416847337-23661-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:47606 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbaKXQmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 11:42:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new option (-addresses) to the 'ip link' command so that the
user can display link details and IP addresses with the same command.

Example:
$ ip -d -a l ls gre1
9: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/gre 10.16.0.249 peer 10.16.0.121 promiscuity 0
    gre remote 10.16.0.121 local 10.16.0.249 ttl inherit ikey 0.0.0.10 okey 0.0.0.10 icsum ocsum
    inet 192.168.0.249 peer 192.168.0.121/32 scope global gre1
       valid_lft forever preferred_lft forever
    inet6 fe80::5efe:a10:f9/64 scope link
       valid_lft forever preferred_lft forever

Suggested-by: Christophe Gouault <christophe.gouault@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/utils.h | 1 +
 ip/ip.c         | 3 +++
 ip/ipaddress.c  | 5 +++--
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index eef9c42d2fd5..9d0f2ad83e49 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -15,6 +15,7 @@ extern int human_readable;
 extern int use_iec;
 extern int show_stats;
 extern int show_details;
+extern int show_addresses;
 extern int show_raw;
 extern int resolve_hosts;
 extern int oneline;
diff --git a/ip/ip.c b/ip/ip.c
index 5f759d5424aa..ad53d14a1fd9 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -28,6 +28,7 @@ int human_readable = 0;
 int use_iec = 0;
 int show_stats = 0;
 int show_details = 0;
+int show_addresses = 0;
 int resolve_hosts = 0;
 int oneline = 0;
 int timestamp = 0;
@@ -226,6 +227,8 @@ int main(int argc, char **argv)
 			++show_stats;
 		} else if (matches(opt, "-details") == 0) {
 			++show_details;
+		} else if (matches(opt, "-addresses") == 0) {
+			++show_addresses;
 		} else if (matches(opt, "-resolve") == 0) {
 			++resolve_hosts;
 		} else if (matches(opt, "-oneline") == 0) {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index db39437305a9..10cbb4248a67 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1323,7 +1323,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	 * link filters are present, use RTM_GETLINK to get
 	 * the link device
 	 */
-	if (filter_dev && filter.group == -1 && do_link == 1) {
+	if (filter_dev && filter.group == -1 && do_link == 1 && show_addresses == 0) {
 		if (iplink_get(0, filter_dev, RTEXT_FILTER_VF) < 0) {
 			perror("Cannot send link get request");
 			exit(1);
@@ -1437,7 +1437,8 @@ void ipaddr_get_vf_rate(int vfnum, int *min, int *max, int idx)
 
 int ipaddr_list_link(int argc, char **argv)
 {
-	preferred_family = AF_PACKET;
+	if (show_addresses == 0)
+		preferred_family = AF_PACKET;
 	do_link = 1;
 	return ipaddr_list_flush_or_save(argc, argv, IPADD_LIST);
 }
-- 
2.1.0
