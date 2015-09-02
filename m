From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] ip route: Print table id for 'ip route get'
Date: Wed,  2 Sep 2015 10:30:31 -0700
Message-ID: <1441215031-22667-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33031 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141AbbIBRah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 13:30:37 -0400
Received: by pacex6 with SMTP id ex6so12938337pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 10:30:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Table id is not dumped for 'ip route get' requests because the RTM_F_CLONED
flag is set in rt_fill_info. Move it out from the check and show user the
table id any time it is not MAIN.

Example:
    $ ip ru ls
    0:		from all lookup local
    32765:	from all to 10.2.1.0/24 lookup 10
    32766:	from all lookup main
    32767:	from all lookup default

    $ ip route ls
    default via 10.0.0.254 dev eth0
    10.0.0.0/24 dev eth0  proto kernel  scope link  src 10.0.0.2
    10.2.2.0/24 dev eth2  proto kernel  scope link  src 10.2.2.2
    10.2.3.0/24 dev eth3  proto kernel  scope link  src 10.2.3.2
    10.2.4.0/24 dev eth4  proto kernel  scope link  src 10.2.4.2

    $ ip route ls table 10
    10.2.1.0/24 dev eth1  scope link

    Currently:
    $ ip route get 10.2.1.240
    10.2.1.240 dev eth1  src 10.2.1.2
        cache

    With this patch:
    $ ip route get 10.2.1.240
    10.2.1.240 dev eth1  table 10  src 10.2.1.2
        cache

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8f49e6289003..9e6148d68e6c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -421,9 +421,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_OIF] && filter.oifmask != -1)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
+	if ((table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
+		fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
+
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
-		if ((table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
-			fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 		if ((r->rtm_protocol != RTPROT_BOOT || show_details > 0) && filter.protocolmask != -1)
 			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
 		if ((r->rtm_scope != RT_SCOPE_UNIVERSE || show_details > 0) && filter.scopemask != -1)
-- 
1.9.1
