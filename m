From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Add support for multipath route realms
Date: Tue, 25 Jul 2006 05:58:36 +0200
Message-ID: <44C596EC.905@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000908020309040808070809"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20645 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932291AbWGYEAM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 00:00:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000908020309040808070809
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------000908020309040808070809
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Add support for multipath route realms

Routing realms exist per nexthop, but iproute currently only allows to send
a single route realm, which is refused by the kernel for multipath routes.
Add support for specifying per nexthop realms. Old kernels only return the
first realm back to userspace when dumping, so the others can't be displayed,
besides that it will also behave correctly on old kernels.

old kernel:

1.2.3.4 realm 1
        nexthop dev dummy0 weight 1
        nexthop dev dummy1 weight 1
        nexthop dev dummy2 weight 1
        nexthop dev dummy3 weight 1

new kernel:

1.2.3.4
        nexthop realm 1 dev dummy0 weight 1
        nexthop realm 2 dev dummy1 weight 1
        nexthop realm 3 dev dummy2 weight 1
        nexthop realm 4 dev dummy3 weight 1

route queries on both old and new kernel:

1.2.3.4 dev dummy0  src 10.0.0.1 realm 1
    cache  mtu 1500 advmss 1460 metric 10 64
1.2.3.4 dev dummy1  src 10.0.0.1 realm 2
    cache  mtu 1500 advmss 1460 metric 10 64
1.2.3.4 dev dummy2  src 10.0.0.1 realm 3
    cache  mtu 1500 advmss 1460 metric 10 64
1.2.3.4 dev dummy3  src 10.0.0.1 realm 4
    cache  mtu 1500 advmss 1460 metric 10 64

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit dbc39a8d37d658776a8959d2393b1047ea124436
tree be59669a06709aaa3b194f050529fe3986928dc8
parent 8f8a36487119a3cd1afe86a9649704aca088567b
author Patrick McHardy <kaber@trash.net> Tue, 25 Jul 2006 05:55:36 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 25 Jul 2006 05:55:36 +0200

 ip/iproute.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index a43c09e..3544f02 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -557,6 +557,18 @@ #endif
 							    RTA_DATA(tb[RTA_GATEWAY]),
 							    abuf, sizeof(abuf)));
 				}
+				if (tb[RTA_FLOW]) {
+					__u32 to = *(__u32*)RTA_DATA(tb[RTA_FLOW]);
+					__u32 from = to>>16;
+					to &= 0xFFFF;
+					fprintf(fp, " realm%s ", from ? "s" : "");
+					if (from) {
+						fprintf(fp, "%s/",
+							rtnl_rtrealm_n2a(from, b1, sizeof(b1)));
+					}
+					fprintf(fp, "%s",
+						rtnl_rtrealm_n2a(to, b1, sizeof(b1)));
+				}
 			}
 			if (r->rtm_flags&RTM_F_CLONED && r->rtm_type == RTN_MULTICAST) {
 				fprintf(fp, " %s", ll_index_to_name(nh->rtnh_ifindex));
@@ -606,6 +618,13 @@ int parse_one_nh(struct rtattr *rta, str
 			rtnh->rtnh_hops = w - 1;
 		} else if (strcmp(*argv, "onlink") == 0) {
 			rtnh->rtnh_flags |= RTNH_F_ONLINK;
+		} else if (matches(*argv, "realms") == 0) {
+			__u32 realm;
+			NEXT_ARG();
+			if (get_rt_realms(&realm, *argv))
+				invarg("\"realm\" value is invalid\n", *argv);
+			rta_addattr32(rta, 4096, RTA_FLOW, realm);
+			rtnh->rtnh_len += sizeof(struct rtattr) + 4;
 		} else
 			break;
 	}

--------------000908020309040808070809--
