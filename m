From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] sunrpc: handle copy*user and put_user errors
Date: Sun, 18 Jan 2004 21:13:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118211300.3f90c945.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.


From: Eugene TEO <eugeneteo@eugeneteo.net>


Patch compiles, and tested. Please apply.

http://www.anomalistic.org/patches/sunrpc-check-ret-fixes-2.6.1-rc1-mm1.patch

diff -Naur -X /home/amnesia/w/dontdiff 2.6.1-rc1-mm1/net/sunrpc/sysctl.c 2.6.1-rc1-mm1-fix/net/sunrpc/sysctl.c

diff -puN net/sunrpc/sysctl.c~sunrpc_retval net/sunrpc/sysctl.c


 linux-261-bk4-kj1-rddunlap/net/sunrpc/sysctl.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff -puN net/sunrpc/sysctl.c~sunrpc_retval net/sunrpc/sysctl.c
--- linux-261-bk4-kj1/net/sunrpc/sysctl.c~sunrpc_retval	2004-01-16 16:03:22.000000000 -0800
+++ linux-261-bk4-kj1-rddunlap/net/sunrpc/sysctl.c	2004-01-16 16:03:22.000000000 -0800
@@ -81,7 +81,8 @@ proc_dodebug(ctl_table *table, int write
 
 		if (left > sizeof(tmpbuf) - 1)
 			return -EINVAL;
-		copy_from_user(tmpbuf, p, left);
+		if (copy_from_user(tmpbuf, p, left))
+			return -EFAULT;
 		tmpbuf[left] = '\0';
 
 		for (p = tmpbuf, value = 0; '0' <= *p && *p <= '9'; p++, left--)
@@ -101,9 +102,11 @@ proc_dodebug(ctl_table *table, int write
 		len = sprintf(tmpbuf, "%d", *(unsigned int *) table->data);
 		if (len > left)
 			len = left;
-		__copy_to_user(buffer, tmpbuf, len);
+		if (__copy_to_user(buffer, tmpbuf, len))
+			return -EFAULT;
 		if ((left -= len) > 0) {
-			put_user('\n', (char *)buffer + len);
+			if (put_user('\n', (char *)buffer + len))
+				return -EFAULT;
 			left--;
 		}
 	}

_


--
~Randy
