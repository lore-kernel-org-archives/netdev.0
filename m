From: Thomas Haller <thaller@redhat.com>
Subject: [patch iproute2 v3 3/3] add support for IFA_F_NOPREFIXROUTE
Date: Tue,  7 Jan 2014 21:46:28 +0100
Message-ID: <1389127588-20236-1-git-send-email-thaller@redhat.com>
References: <1388999830-1753-1-git-send-email-jiri@resnulli.us>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	dcbw@redhat.com, Thomas Haller <thaller@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbaAGUqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 15:46:49 -0500
In-Reply-To: <1388999830-1753-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 Hi,

 this additional patch is based on the previous two patches v2,
 so I reply to this email.

 It's related to the discussion about adding a flag IFA_F_NOPREFIXROUTE
 to suppress creation of prefix routes
 (see thread "[patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR",
 from Thu,  2 Jan 2014 16:34:37 +0100).

 include/linux/if_addr.h |  6 +++++-
 ip/ipaddress.c          | 11 ++++++++++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index e1e95ce..cc375e4 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -18,6 +18,9 @@ struct ifaddrmsg {
  * It makes no difference for normally configured broadcast interfaces,
  * but for point-to-point IFA_ADDRESS is DESTINATION address,
  * local address is supplied in IFA_LOCAL attribute.
+ *
+ * IFA_FLAGS is a u32 attribute that extends the u8 field ifa_flags.
+ * If present, the value from struct ifaddrmsg will be ignored.
  */
 enum {
 	IFA_UNSPEC,
@@ -45,7 +48,8 @@ enum {
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
-#define IFA_F_MANAGETEMPADDR	0x0100
+#define IFA_F_MANAGETEMPADDR	0x100
+#define IFA_F_NOPREFIXROUTE	0x200
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b0d54fe..f794fa1 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -82,7 +82,7 @@ static void usage(void)
 	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
-	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr ]\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -707,6 +707,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		ifa_flags &= ~IFA_F_MANAGETEMPADDR;
 		fprintf(fp, "mngtmpaddr ");
 	}
+	if (ifa_flags & IFA_F_NOPREFIXROUTE) {
+		ifa_flags &= ~IFA_F_NOPREFIXROUTE;
+		fprintf(fp, "noprefixroute ");
+	}
 	if (!(ifa_flags & IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
@@ -1133,6 +1137,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
 			filter.flags |= IFA_F_MANAGETEMPADDR;
 			filter.flagmask |= IFA_F_MANAGETEMPADDR;
+		} else if (strcmp(*argv, "noprefixroute") == 0) {
+			filter.flags |= IFA_F_NOPREFIXROUTE;
+			filter.flagmask |= IFA_F_NOPREFIXROUTE;
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
@@ -1354,6 +1361,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			ifa_flags |= IFA_F_NODAD;
 		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
 			ifa_flags |= IFA_F_MANAGETEMPADDR;
+		} else if (strcmp(*argv, "noprefixroute") == 0) {
+			ifa_flags |= IFA_F_NOPREFIXROUTE;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
-- 
1.8.4.2
