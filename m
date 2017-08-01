From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] Really fix get_addr() and get_prefix() error messages
Date: Tue,  1 Aug 2017 18:36:11 +0200
Message-ID: <20170801163611.10094-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33187 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751769AbdHAQgY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:36:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both functions take the desired address family as a parameter. So using
that to notify the user what address family was expected is correct,
unlike using dst->family which will tell the user only what address
family was specified.

The situation which commit 334af76143368 tried to fix was when 'ip'
would accept addresses from multiple families. In that case, the family
parameter is set to AF_UNSPEC so that get_addr_1() may accept any valid
address.

This patch introduces a wrapper around family_name() which returns the
string "any valid" for AF_UNSPEC instead of the three question marks
unsuitable for use in error messages.

Tests for AF_UNSPEC:

| # ip a a 256.10.166.1/24 dev d0
| Error: any valid prefix is expected rather than "256.10.166.1/24".

| # ip neighbor add proxy 2001:db8::g dev d0
| Error: any valid address is expected rather than "2001:db8::g".

Tests for explicit address family:

| # ip -6 addrlabel add prefix 1.1.1.1/24 label 123
| Error: inet6 prefix is expected rather than "1.1.1.1/24".

| # ip -4 addrlabel add prefix dead:beef::1/24 label 123
| Error: inet prefix is expected rather than "dead:beef::1/24".

Reported-by: Jaroslav Aster <jaster@redhat.com>
Fixes: 334af76143368 ("fix get_addr() and get_prefix() error messages")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/utils.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 9aa3219c5547d..9143ed2284870 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -616,12 +616,19 @@ done:
 	return err;
 }
 
+static const char *family_name_verbose(int family)
+{
+	if (family == AF_UNSPEC)
+		return "any valid";
+	return family_name(family);
+}
+
 int get_addr(inet_prefix *dst, const char *arg, int family)
 {
 	if (get_addr_1(dst, arg, family)) {
 		fprintf(stderr,
 			"Error: %s address is expected rather than \"%s\".\n",
-			family_name(dst->family), arg);
+			family_name_verbose(family), arg);
 		exit(1);
 	}
 	return 0;
@@ -639,7 +646,7 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
 	if (get_prefix_1(dst, arg, family)) {
 		fprintf(stderr,
 			"Error: %s prefix is expected rather than \"%s\".\n",
-			family_name(dst->family), arg);
+			family_name_verbose(family), arg);
 		exit(1);
 	}
 	return 0;
-- 
2.13.1
