From: Isaac Boukris <iboukris@gmail.com>
Subject: [PATCH] unix: escape all null bytes in abstract unix domain socket
Date: Sat, 29 Oct 2016 22:20:20 +0300
Message-ID: <1477768820-1295-2-git-send-email-iboukris@gmail.com>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
Cc: Isaac Boukris <iboukris@gmail.com>
To: stephen@networkplumber.org, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract unix domain socket may embed null characters,
these should be translated to '@' when printed out to
proc the same way the null prefix is currently being
translated.

This helps for tools such as netstat, lsof and the proc
based implementation in ss to show all the significant
bytes of the name (instead of getting cut at the first
null occurrence).

Signed-off-by: Isaac Boukris <iboukris@gmail.com>
---
 net/unix/af_unix.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 145082e..9250b03 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2805,14 +2805,19 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 
 			i = 0;
 			len = u->addr->len - sizeof(short);
-			if (!UNIX_ABSTRACT(s))
+			if (!UNIX_ABSTRACT(s)) {
 				len--;
-			else {
+				for ( ; i < len; i++)
+					seq_putc(seq,
+						 u->addr->name->sun_path[i]);
+			} else {
 				seq_putc(seq, '@');
 				i++;
+				for ( ; i < len; i++)
+					seq_putc(seq,
+						 u->addr->name->sun_path[i] ?:
+						 '@');
 			}
-			for ( ; i < len; i++)
-				seq_putc(seq, u->addr->name->sun_path[i]);
 		}
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
-- 
2.7.4
