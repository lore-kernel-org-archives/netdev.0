From: Shmulik Ladkani <shmulik@nsof.io>
Subject: [PATCH iproute2 net-next] ip: link_ip6tnl.c/ip6tunnel.c: Support IP6_TNL_F_ALLOW_LOCAL_REMOTE flag
Date: Sun, 29 Oct 2017 17:50:46 +0200
Message-ID: <20171029155046.16283-1-shmulik@nsof.io>
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:54763 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdJ2Pu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 11:50:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so11802712wmr.3
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 08:50:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

IP6_TNL_F_ALLOW_LOCAL_REMOTE allows tunnel traffic on ip6tnl devices
where the remote endpoint is a local host address.

Specifying "[no]allow-localremote" controls the
IP6_TNL_F_ALLOW_LOCAL_REMOTE flag on ip6tnl interfaces.

This is the user-space counterpart for kernel commit 908d140a87a7 ("ip6_tunnel: Allow rcv/xmit even if remote address is a local address")

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 ip/ip6tunnel.c       |  8 ++++++++
 ip/link_ip6tnl.c     | 11 +++++++++++
 man/man8/ip-tunnel.8 |  7 +++++++
 3 files changed, 26 insertions(+)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index bc44bef7..4563e1e0 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -52,6 +52,7 @@ static void usage(void)
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr, "          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(stderr, "          [ dscp inherit ]\n");
+	fprintf(stderr, "          [ [no]allow-localremote ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME      := STRING\n");
@@ -111,6 +112,9 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
 		printf(" dscp inherit");
 
+	if (p->flags & IP6_TNL_F_ALLOW_LOCAL_REMOTE)
+		printf(" allow-localremote");
+
 	if ((p->i_flags & GRE_KEY) && (p->o_flags & GRE_KEY) &&
 	    p->o_key == p->i_key)
 		printf(" key %u", ntohl(p->i_key));
@@ -239,6 +243,10 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			if (strcmp(*argv, "inherit") != 0)
 				invarg("not inherit", *argv);
 			p->flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "allow-localremote") == 0) {
+			p->flags |= IP6_TNL_F_ALLOW_LOCAL_REMOTE;
+		} else if (strcmp(*argv, "noallow-localremote") == 0) {
+			p->flags &= ~IP6_TNL_F_ALLOW_LOCAL_REMOTE;
 		} else if (strcmp(*argv, "key") == 0) {
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 2f8c3f34..43287ab3 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -42,6 +42,7 @@ static void print_usage(FILE *f)
 		"                  [ flowlabel FLOWLABEL ]\n"
 		"                  [ dscp inherit ]\n"
 		"                  [ fwmark MARK ]\n"
+		"                  [ [no]allow-localremote ]\n"
 		"                  [ noencap ]\n"
 		"                  [ encap { fou | gue | none } ]\n"
 		"                  [ encap-sport PORT ]\n"
@@ -268,6 +269,10 @@ get_failed:
 					invarg("invalid fwmark\n", *argv);
 				flags &= ~IP6_TNL_F_USE_ORIG_FWMARK;
 			}
+		} else if (strcmp(*argv, "allow-localremote") == 0) {
+			flags |= IP6_TNL_F_ALLOW_LOCAL_REMOTE;
+		} else if (strcmp(*argv, "noallow-localremote") == 0) {
+			flags &= ~IP6_TNL_F_ALLOW_LOCAL_REMOTE;
 		} else if (strcmp(*argv, "noencap") == 0) {
 			encaptype = TUNNEL_ENCAP_NONE;
 		} else if (strcmp(*argv, "encap") == 0) {
@@ -472,6 +477,12 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 		}
 	}
 
+	if (flags & IP6_TNL_F_ALLOW_LOCAL_REMOTE)
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_allow_local_remote",
+			   "allow-localremote ",
+			   true);
+
 	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]);
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 7ddbffb2..9040ddda 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -50,6 +50,8 @@ ip-tunnel - tunnel configuration
 .br
 .RB "[ [" no "]" pmtudisc " ]"
 .RB "[ [" no "]" ignore-df " ]"
+.RB "[ [" no "]" allow-localremote " ]"
+.br
 .RB "[ " dev
 .IR PHYS_DEV " ]"
 
@@ -241,6 +243,11 @@ set a fixed encapsulation limit. Default is 4.
 .BI flowlabel " FLOWLABEL"
 .RB ( " only IPv6 tunnels " )
 set a fixed flowlabel.
+
+.TP
+.BI allow-localremote
+.RB ( " only IPv6 tunnels " )
+allow remote endpoint on the local host.
 .RE
 
 .TP
-- 
2.14.2
