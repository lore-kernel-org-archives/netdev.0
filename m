From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 1/6] ipntable: Avoid memory allocation for filter.name
Date: Thu, 24 Aug 2017 11:51:45 +0200
Message-ID: <20170824095150.5469-2-phil@nwl.cc>
References: <20170824095150.5469-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56427 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752555AbdHXJwD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:52:03 -0400
In-Reply-To: <20170824095150.5469-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original issue was that filter.name might end up unterminated if
user provided string was too long. But in fact it is not necessary to
copy the commandline parameter at all: just make filter.name point to it
instead.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 1837909fa42e7..88236ce0ec1e1 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -37,7 +37,7 @@ static struct
 	int family;
 	int index;
 #define NONE_DEV	(-1)
-	char name[1024];
+	const char *name;
 } filter;
 
 static void usage(void) __attribute__((noreturn));
@@ -367,7 +367,7 @@ static int print_ntable(const struct sockaddr_nl *who, struct nlmsghdr *n, void
 	if (tb[NDTA_NAME]) {
 		const char *name = rta_getattr_str(tb[NDTA_NAME]);
 
-		if (strlen(filter.name) > 0 && strcmp(filter.name, name))
+		if (filter.name && strcmp(filter.name, name))
 			return 0;
 	}
 	if (tb[NDTA_PARMS]) {
@@ -631,7 +631,7 @@ static int ipntable_show(int argc, char **argv)
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
 
-			strncpy(filter.name, *argv, sizeof(filter.name));
+			filter.name = *argv;
 		} else
 			invarg("unknown", *argv);
 
-- 
2.13.1
