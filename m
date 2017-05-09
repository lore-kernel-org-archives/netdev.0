From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] ip: mpls: fix printing of mpls labels
Date: Mon,  8 May 2017 23:04:13 -0700
Message-ID: <20170509060413.11596-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36200 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdEIGEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 02:04:39 -0400
Received: by mail-pg0-f65.google.com with SMTP id 64so6117617pgb.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 23:04:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the kernel returns more labels than iproute2 expects, none of
the labels are printed and (null) is shown instead:
    $ ip -f mpls ro ls
    101 as to (null) via inet 172.16.2.2 dev virt12
    201 as to 202/203 via inet6 2001:db8:2::2 dev virt12

Remove the use of MPLS_MAX_LABELS and rely on buffer length that is
passed to mpls_ntop. With this change ip can print the label stack
returned by the kernel up to 255 characters (limit is due to size of
buf passed in) which amounts to 31 labels with a separator.

With this change the above is:
    $ ip/ip -f mpls ro ls
    101 as to 102/103/104/105/106/107/108/109/110 via inet 172.16.2.2 dev virt12

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 lib/mpls_ntop.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/mpls_ntop.c b/lib/mpls_ntop.c
index 945d6d5e..5902f503 100644
--- a/lib/mpls_ntop.c
+++ b/lib/mpls_ntop.c
@@ -10,18 +10,20 @@ static const char *mpls_ntop1(const struct mpls_label *addr, char *buf, size_t b
 {
 	size_t destlen = buflen;
 	char *dest = buf;
-	int count;
+	int count = 0;
 
-	for (count = 0; count < MPLS_MAX_LABELS; count++) {
-		uint32_t entry = ntohl(addr[count].entry);
+	while (1) {
+		uint32_t entry = ntohl(addr[count++].entry);
 		uint32_t label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
 		int len = snprintf(dest, destlen, "%u", label);
 
+		if (len >= destlen)
+			break;
+
 		/* Is this the end? */
 		if (entry & MPLS_LS_S_MASK)
 			return buf;
 
-
 		dest += len;
 		destlen -= len;
 		if (destlen) {
-- 
2.11.0 (Apple Git-81)
