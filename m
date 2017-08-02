From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] bpf: Make bytecode-file reading a little more robust
Date: Wed,  2 Aug 2017 14:57:56 +0200
Message-ID: <20170802125756.26210-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42079 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdHBM6J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 08:58:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_parse_string() will now correctly handle:

- Extraneous whitespace,
- OPs on multiple lines and
- overlong file names.

The added feature of allowing to have OPs on multiple lines (like e.g.
tcpdump prints them) is rather a side effect of fixing detection of
malformed bytecode files having random content on a second line, like
e.g.:

| 4,40 0 0 12,21 0 1 2048,6 0 0 262144,6 0 0 0
| foobar

Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/bpf.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index e7a4d12fdf2f9..4f52ad4a8f023 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -208,11 +208,11 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 
 	if (from_file) {
 		size_t tmp_len, op_len = sizeof("65535 255 255 4294967295,");
-		char *tmp_string, *last;
+		char *tmp_string, *pos, c, c_prev = ' ';
 		FILE *fp;
 
 		tmp_len = sizeof("4096,") + BPF_MAXINSNS * op_len;
-		tmp_string = calloc(1, tmp_len);
+		tmp_string = pos = calloc(1, tmp_len);
 		if (tmp_string == NULL)
 			return -ENOMEM;
 
@@ -223,17 +223,33 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 			return -ENOENT;
 		}
 
-		if (!fgets(tmp_string, tmp_len, fp)) {
+		while ((c = fgetc(fp)) != EOF) {
+			switch (c) {
+			case '\n':
+				if (c_prev != ',')
+					*(pos++) = ',';
+				break;
+			case ' ':
+			case '\t':
+				if (c_prev != ' ')
+					*(pos++) = c;
+				break;
+			default:
+				*(pos++) = c;
+			}
+			if (pos - tmp_string == tmp_len)
+				break;
+			c_prev = c;
+		}
+
+		if (!feof(fp)) {
 			free(tmp_string);
 			fclose(fp);
-			return -EIO;
+			return -E2BIG;
 		}
 
 		fclose(fp);
-
-		last = &tmp_string[strlen(tmp_string) - 1];
-		if (*last == '\n')
-			*last = 0;
+		*pos = 0;
 
 		*need_release = true;
 		*bpf_string = tmp_string;
-- 
2.13.1
