From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH v2] netlink: don't compare the nul-termination in nla_strcmp
Date: Tue,  1 Apr 2014 19:38:44 +0200
Message-ID: <1396373924-9538-1-git-send-email-pablo@netfilter.org>
Cc: fw@strlen.de, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44094 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbaDARjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 13:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira <pablo@netfilter.org>

nla_strcmp compares the string length plus one, so it's implicitly
including the nul-termination in the comparison.

 int nla_strcmp(const struct nlattr *nla, const char *str)
 {
        int len = strlen(str) + 1;
        ...
                d = memcmp(nla_data(nla), str, len);

However, if NLA_STRING is used, userspace can send us a string without
the nul-termination. This is a problem since the string
comparison will not match as the last byte may be not the
nul-termination.

Fix this by skipping the comparison of the nul-termination if the
attribute data is nul-terminated. Suggested by Thomas Graf.

Cc: Florian Westphal <fw@strlen.de>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 lib/nlattr.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index 18eca78..fc67547 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -303,9 +303,15 @@ int nla_memcmp(const struct nlattr *nla, const void *data,
  */
 int nla_strcmp(const struct nlattr *nla, const char *str)
 {
-	int len = strlen(str) + 1;
-	int d = nla_len(nla) - len;
+	int len = strlen(str);
+	char *buf = nla_data(nla);
+	int attrlen = nla_len(nla);
+	int d;
 
+	if (attrlen > 0 && buf[attrlen - 1] == '\0')
+		attrlen--;
+
+	d = attrlen - len;
 	if (d == 0)
 		d = memcmp(nla_data(nla), str, len);
 
-- 
1.7.10.4
