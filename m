From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip route: error out on multiple via without nexthop keyword
Date: Thu, 19 Jan 2017 09:08:21 -0800
Message-ID: <1484845701-19354-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34239 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdASRIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:08:36 -0500
Received: by mail-pf0-f171.google.com with SMTP id e4so14874776pfg.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:08:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To specify multiple nexthops in a route the user is expected to use the
"nexthop" keyword which ip route uses to create the RTA_MULTIPATH.
However, ip route always accepts multiple 'via' keywords where only the
last one is used in the route leading to confusion. For example, ip
accepts this syntax:
    $ ip ro add vrf red  1.1.1.0/24 via 10.100.1.18 via 10.100.2.18

but the route entered inserted by the kernel is just the last gateway:
    1.1.1.0/24 via 10.100.2.18 dev eth2

which is not the full request from the user. Detect the presense of
multiple 'via' and give the user a hint to add nexthop:

    $ ip ro add vrf red  1.1.1.0/24 via 10.100.1.18 via 10.100.2.18
    Error: argument "via" is wrong: use nexthop syntax to specify multiple via

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index e433de8be189..52dbdc7dea36 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -881,6 +881,10 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 			inet_prefix addr;
 			int family;
 
+			if (gw_ok) {
+				invarg("use nexthop syntax to specify multiple via\n",
+				       *argv);
+			}
 			gw_ok = 1;
 			NEXT_ARG();
 			family = read_family(*argv);
-- 
2.1.4
