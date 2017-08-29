From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] lib/bpf: Fix bytecode-file parsing
Date: Tue, 29 Aug 2017 17:09:45 +0200
Message-ID: <20170829150945.7077-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55699 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752435AbdH2PJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 11:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The signedness of char type is implementation dependent, and there are
architectures on which it is unsigned by default. In that case, the
check whether fgetc() returned EOF failed because the return value was
assigned an (unsigned) char variable prior to comparison with EOF (which
is defined to -1). Fix this by using int as type for 'c' variable, which
also matches the declaration of fgetc().

While being at it, fix the parser logic to correctly handle multiple
empty lines and consecutive whitespace and tab characters to further
improve the parser's robustness. Note that this will still detect double
separator characters, so doesn't soften up the parser too much.

Fixes: 3da3ebfca85b8 ("bpf: Make bytecode-file reading a little more robust")
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/bpf.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 0bd0a95eafe6c..77eb8ee27114f 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -208,8 +208,9 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 
 	if (from_file) {
 		size_t tmp_len, op_len = sizeof("65535 255 255 4294967295,");
-		char *tmp_string, *pos, c, c_prev = ' ';
+		char *tmp_string, *pos, c_prev = ' ';
 		FILE *fp;
+		int c;
 
 		tmp_len = sizeof("4096,") + BPF_MAXINSNS * op_len;
 		tmp_string = pos = calloc(1, tmp_len);
@@ -228,18 +229,20 @@ static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 			case '\n':
 				if (c_prev != ',')
 					*(pos++) = ',';
+				c_prev = ',';
 				break;
 			case ' ':
 			case '\t':
 				if (c_prev != ' ')
 					*(pos++) = c;
+				c_prev = ' ';
 				break;
 			default:
 				*(pos++) = c;
+				c_prev = c;
 			}
 			if (pos - tmp_string == tmp_len)
 				break;
-			c_prev = c;
 		}
 
 		if (!feof(fp)) {
-- 
2.13.1
