From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: [PATCH] af_unix: Fix path of /proc/net/unix
Date: Sat, 07 Feb 2004 16:03:48 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <878yjf2wx7.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

/proc/net/unix on 2.4,
  c14e0580: 0000000C 00000000 00000000 0002 01   742 /dev/log
  c06bfa80: 00000002 00000000 00000000 0002 01 1019617 @0123 ...

/proc/net/unix on 2.6,
  c7c85d1c: 0000000C 00000000 00000000 0002 01  1021 /dev/log^@
  c551bd5c: 00000002 00000000 00000000 0002 01  5692 ^@0123 ... @

We should overwrite the first "nul" by "@" in the case of abstract
path, otherwise currently "netstat -x" can't print, at least.  And
normal one, odd "nul" was added.

This patch does behavior of 2.4. Please apply.


---

 net/unix/af_unix.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff -puN net/unix/af_unix.c~af_unix-abstruct-fix net/unix/af_unix.c
--- linux-2.6.2/net/unix/af_unix.c~af_unix-abstruct-fix	2004-02-07 01:47:05.000000000 +0900
+++ linux-2.6.2-hirofumi/net/unix/af_unix.c	2004-02-07 03:39:06.000000000 +0900
@@ -1863,14 +1863,19 @@ static int unix_seq_show(struct seq_file
 			sock_i_ino(s));
 
 		if (u->addr) {
-			int i;
+			int i, len;
 			seq_putc(seq, ' ');
-			
-			for (i = 0; i < u->addr->len-sizeof(short); i++)
-				seq_putc(seq, u->addr->name->sun_path[i]);
 
-			if (UNIX_ABSTRACT(s))
+			i = 0;
+			len = u->addr->len - sizeof(short);
+			if (!UNIX_ABSTRACT(s))
+				len--;
+			else {
 				seq_putc(seq, '@');
+				i++;
+			}
+			for ( ; i < len; i++)
+				seq_putc(seq, u->addr->name->sun_path[i]);
 		}
 		unix_state_runlock(s);
 		seq_putc(seq, '\n');

_
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
