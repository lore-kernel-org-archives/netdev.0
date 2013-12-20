From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Do not listen if rtnl_send() fails in ip link
 iplink_have_newlink() test
Date: Fri, 20 Dec 2013 08:21:07 -0800
Message-ID: <20131220082107.0467d57c@nehalam.linuxnetplumber.net>
References: <20131211105749.1ee87844@nehalam.linuxnetplumber.net>
	<1386832705-3101-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Petr =?UTF-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:45465 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab3LTQVL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 11:21:11 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so2692086pdj.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 08:21:11 -0800 (PST)
In-Reply-To: <1386832705-3101-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I took your idea and enhanced it to all of iproute2 by doing the follow=
ing:

=46rom c4b6330a3a033bd9c9b0664c5f844493137ae599 Mon Sep 17 00:00:00 200=
1
=46rom: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 20 Dec 2013 08:15:02 -0800
Subject: [PATCH] check return value of rtnl_send and related functions
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Use warn_unused_result to enforce checking return value of rtnl_send,
and fix where the errors are.

Suggested by initial patch from Petr P=C3=ADsa=C5=99 <ppisar@redhat.com=
>
---
 include/libnetlink.h |   28 ++++++++++++++++++++--------
 ip/iplink.c          |    5 ++++-
 ip/ipnetconf.c       |    5 ++++-
 misc/arpd.c          |    6 +++++-
 misc/ss.c            |    4 +++-
 5 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index ec3d657..fe7d5d3 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -22,13 +22,22 @@ struct rtnl_handle
=20
 extern int rcvbuf;
=20
-extern int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions);
-extern int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscri=
ptions, int protocol);
+extern int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions)
+	__attribute__((warn_unused_result));
+
+extern int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscri=
ptions,
+			     int protocol)
+	__attribute__((warn_unused_result));
+
 extern void rtnl_close(struct rtnl_handle *rth);
-extern int rtnl_wilddump_request(struct rtnl_handle *rth, int fam, int=
 type);
+extern int rtnl_wilddump_request(struct rtnl_handle *rth, int fam, int=
 type)
+	__attribute__((warn_unused_result));
 extern int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int fam, =
int type,
-				    __u32 filt_mask);
-extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *=
req, int len);
+				    __u32 filt_mask)
+	__attribute__((warn_unused_result));
+extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *=
req,
+			     int len)
+	__attribute__((warn_unused_result));
=20
 typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
 			     struct nlmsghdr *n, void *);
@@ -44,9 +53,12 @@ extern int rtnl_dump_filter_l(struct rtnl_handle *rt=
h,
 extern int rtnl_dump_filter(struct rtnl_handle *rth, rtnl_filter_t fil=
ter,
 			    void *arg);
 extern int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid=
_t peer,
-		     unsigned groups, struct nlmsghdr *answer);
-extern int rtnl_send(struct rtnl_handle *rth, const void *buf, int);
-extern int rtnl_send_check(struct rtnl_handle *rth, const void *buf, i=
nt);
+		     unsigned groups, struct nlmsghdr *answer)
+	__attribute__((warn_unused_result));
+extern int rtnl_send(struct rtnl_handle *rth, const void *buf, int)
+	__attribute__((warn_unused_result));
+extern int rtnl_send_check(struct rtnl_handle *rth, const void *buf, i=
nt)
+	__attribute__((warn_unused_result));
=20
 extern int addattr(struct nlmsghdr *n, int maxlen, int type);
 extern int addattr8(struct nlmsghdr *n, int maxlen, int type, __u8 dat=
a);
diff --git a/ip/iplink.c b/ip/iplink.c
index 58b6c20..e0c14e6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -178,7 +178,10 @@ static int iplink_have_newlink(void)
 		req.n.nlmsg_type =3D RTM_NEWLINK;
 		req.i.ifi_family =3D AF_UNSPEC;
=20
-		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
+		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
+			perror("request send failed");
+			exit(1);
+		}
 		rtnl_listen(&rth, accept_msg, NULL);
 	}
 	return have_rtnl_newlink;
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 9a77ecb..37aaf45 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -161,7 +161,10 @@ static int do_show(int argc, char **argv)
 			addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX,
 				  &filter.ifindex, sizeof(filter.ifindex));
=20
-		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
+		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
+			perror("Can not send request");
+			exit(1);
+		}
 		rtnl_listen(&rth, print_netconf, stdout);
 	} else {
 dump:
diff --git a/misc/arpd.c b/misc/arpd.c
index ec9d570..d293b70 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -428,7 +428,11 @@ static int do_one_request(struct nlmsghdr *n)
=20
 static void load_initial_table(void)
 {
-	rtnl_wilddump_request(&rth, AF_INET, RTM_GETNEIGH);
+	if (rtnl_wilddump_request(&rth, AF_INET, RTM_GETNEIGH) < 0) {
+		perrror("dump request failed");
+		exit(1);
+	}
+	=09
 }
=20
 static void get_kern_msg(void)
diff --git a/misc/ss.c b/misc/ss.c
index 6f38ae7..e59ca5c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -996,7 +996,9 @@ static int xll_initted =3D 0;
 static void xll_init(void)
 {
 	struct rtnl_handle rth;
-	rtnl_open(&rth, 0);
+	if (rtnl_open(&rth, 0) < 0)
+		exit(1);
+
 	ll_init_map(&rth);
 	rtnl_close(&rth);
 	xll_initted =3D 1;
--=20
1.7.10.4
