From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 02/12] ip/tunnel: introduce tnl_parse_key()
Date: Fri, 13 Nov 2015 18:08:55 +0100
Message-ID: <1447434545-32182-3-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57823 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933395AbbKMRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:08 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of duplicating the same code six times (key, ikey and okey in
iptunnel and ip6tunnel), have a common parsing routine. This has the
added benefit of having the same verbose error message in ip6tunnel as
well as iptunnel.

I'm not sure if parsing an IPv4 address as key makes sense for
ip6tunnel, but the code was there before so this patch at least doesn't
make it worse.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c | 33 +++------------------------------
 ip/iptunnel.c  | 33 +++------------------------------
 ip/tunnel.c    | 15 +++++++++++++++
 ip/tunnel.h    |  1 +
 4 files changed, 22 insertions(+), 60 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 07010d3..8b842b6 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -230,45 +230,18 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 				invarg("not inherit", *argv);
 			p->flags |= IP6_TNL_F_RCV_DSCP_COPY;
 		} else if (strcmp(*argv, "key") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
 			p->o_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->i_key = p->o_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0) < 0) {
-					fprintf(stderr, "invalid value of \"key\"\n");
-					exit(-1);
-				}
-				p->i_key = p->o_key = htonl(uval);
-			}
+			p->i_key = p->o_key = tnl_parse_key("key", *argv);
 		} else if (strcmp(*argv, "ikey") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->i_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"ikey\"\n");
-					exit(-1);
-				}
-				p->i_key = htonl(uval);
-			}
+			p->i_key = tnl_parse_key("ikey", *argv);
 		} else if (strcmp(*argv, "okey") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->o_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->o_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"okey\"\n");
-					exit(-1);
-				}
-				p->o_key = htonl(uval);
-			}
+			p->o_key = tnl_parse_key("okey", *argv);
 		} else if (strcmp(*argv, "seq") == 0) {
 			p->i_flags |= GRE_SEQ;
 			p->o_flags |= GRE_SEQ;
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 36534f2..9c9dc54 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -106,45 +106,18 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				exit(-1);
 			}
 		} else if (strcmp(*argv, "key") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
 			p->o_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->i_key = p->o_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
-					exit(-1);
-				}
-				p->i_key = p->o_key = htonl(uval);
-			}
+			p->i_key = p->o_key = tnl_parse_key("key", *argv);
 		} else if (strcmp(*argv, "ikey") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->i_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value for \"ikey\": \"%s\"; it should be an unsigned integer\n", *argv);
-					exit(-1);
-				}
-				p->i_key = htonl(uval);
-			}
+			p->i_key = tnl_parse_key("ikey", *argv);
 		} else if (strcmp(*argv, "okey") == 0) {
-			unsigned uval;
 			NEXT_ARG();
 			p->o_flags |= GRE_KEY;
-			if (strchr(*argv, '.'))
-				p->o_key = get_addr32(*argv);
-			else {
-				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value for \"okey\": \"%s\"; it should be an unsigned integer\n", *argv);
-					exit(-1);
-				}
-				p->o_key = htonl(uval);
-			}
+			p->o_key = tnl_parse_key("okey", *argv);
 		} else if (strcmp(*argv, "seq") == 0) {
 			p->i_flags |= GRE_SEQ;
 			p->o_flags |= GRE_SEQ;
diff --git a/ip/tunnel.c b/ip/tunnel.c
index d69fe84..79f2201 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -180,3 +180,18 @@ int tnl_ioctl_get_6rd(const char *name, void *p)
 {
 	return tnl_gen_ioctl(SIOCGET6RD, name, p, EINVAL);
 }
+
+__be32 tnl_parse_key(const char *name, const char *key)
+{
+	unsigned uval;
+
+	if (strchr(key, '.'))
+		return get_addr32(key);
+
+	if (get_unsigned(&uval, key, 0) < 0) {
+		fprintf(stderr, "invalid value for \"%s\": \"%s\";", name, key);
+		fprintf(stderr, " it should be an unsigned integer\n");
+		exit(-1);
+	}
+	return htonl(uval);
+}
diff --git a/ip/tunnel.h b/ip/tunnel.h
index 9c2f5d2..9fb4a18 100644
--- a/ip/tunnel.h
+++ b/ip/tunnel.h
@@ -31,5 +31,6 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p);
 int tnl_prl_ioctl(int cmd, const char *name, void *p);
 int tnl_6rd_ioctl(int cmd, const char *name, void *p);
 int tnl_ioctl_get_6rd(const char *name, void *p);
+__be32 tnl_parse_key(const char *name, const char *key);
 
 #endif
-- 
2.1.2
