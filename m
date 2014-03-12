From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] iproute: Show default type, table, proto and scope of route
Date: Wed, 12 Mar 2014 12:46:53 +0900
Message-ID: <1394596013-25090-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145AbaCLDrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 23:47:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In "ip route show" output unicast type, main table, boot protocol and
universe scope are hidden as default labels.

Sometimes it is helpful to show the hidden label for people not enough
familiar with routing subsystem to map the output of "ip route show" and
kernel source code.

With this patch "ip route show" with -d option shows the default labels.

Example of difference of output with -d option:

    $ ./ip/ip -4   route show table all dev virbr1
    ...
    192.168.121.0/28  proto kernel  scope link  src 192.168.121.1
    ...
    $ ./ip/ip -4 -d  route show table all dev virbr1
    ...
    unicast 192.168.121.0/28  table main  proto kernel  scope link  src 192.168.121.1
    ...

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 ip/iproute.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index bc3c3e1..daff9ce 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -332,7 +332,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (n->nlmsg_type == RTM_DELROUTE)
 		fprintf(fp, "Deleted ");
-	if (r->rtm_type != RTN_UNICAST && !filter.type)
+	if ((r->rtm_type != RTN_UNICAST || show_details > 0) && !filter.type)
 		fprintf(fp, "%s ", rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
 
 	if (tb[RTA_DST]) {
@@ -389,11 +389,11 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
-		if (table != RT_TABLE_MAIN && !filter.tb)
+		if ((table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
 			fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
-		if (r->rtm_protocol != RTPROT_BOOT && filter.protocolmask != -1)
+		if ((r->rtm_protocol != RTPROT_BOOT || show_details > 0) && filter.protocolmask != -1)
 			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
-		if (r->rtm_scope != RT_SCOPE_UNIVERSE && filter.scopemask != -1)
+		if ((r->rtm_scope != RT_SCOPE_UNIVERSE || show_details > 0) && filter.scopemask != -1)
 			fprintf(fp, " scope %s ", rtnl_rtscope_n2a(r->rtm_scope, b1, sizeof(b1)));
 	}
 	if (tb[RTA_PREFSRC] && filter.rprefsrc.bitlen != host_len) {
-- 
1.8.5.3
