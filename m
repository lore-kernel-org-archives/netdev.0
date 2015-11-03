From: Florian Weimer <fweimer@redhat.com>
Subject: [PATCH v2] glibc: Terminate process on invalid netlink response from
 kernel [BZ #12926]
Date: Tue, 3 Nov 2015 14:40:15 +0100
Message-ID: <5638B93F.3090202@redhat.com>
References: <562A9391.1040806@redhat.com> <20151024042203.GQ26317@vapier.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020908060904020603060902"
Cc: Hannes Sowa <hannes@redhat.com>, netdev@vger.kernel.org
To: GNU C Library <libc-alpha@sourceware.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289AbbKCNkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 08:40:18 -0500
In-Reply-To: <20151024042203.GQ26317@vapier.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020908060904020603060902
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

On 10/24/2015 06:22 AM, Mike Frysinger wrote:
> On 23 Oct 2015 22:07, Florian Weimer wrote:
>> --- /dev/null
>> +++ b/sysdeps/unix/sysv/linux/netlink_assert_response.c
>> @@ -0,0 +1,100 @@
>> +/* Copyright (C) 2015 Free Software Foundation, Inc.
>> +   This file is part of the GNU C Library.
> 
> guess we like to have the first line be a short desc of the file

Added.

>> +static int
>> +get_address_family (int fd)
>> +{
>> ...
>> +  return sa.ss_family;

> ss_family is of type sa_family_t, not int ... not a big deal, but the
> two do differ in sign ...

Thanks.  I added static asserts to make sure that the actual type does
not cause problems with the use of -1 and an int return value.

I do not want to use SO_DOMAIN here because I expect this to eventually
move into generic code because we probably should do similar checking on
other internally-used sockets (where reporting impossible errors to the
caller would be grossly misleading).

I'm still waiting for comments from the kernel people. :)

Florian

--------------020908060904020603060902
Content-Type: text/x-patch;
 name="0001-Terminate-process-on-invalid-netlink-response-from-k.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-Terminate-process-on-invalid-netlink-response-from-k.pa";
 filename*1="tch"

Terminate process on invalid netlink response from kernel [BZ

The recvmsg system calls for netlink sockets have been particularly
prone to picking up unrelated data after a file descriptor race
(where the descriptor is closed and reopened concurrently in a
multi-threaded process, as the result of a file descriptor
management issue elsewhere).  This commit adds additional error
checking and aborts the process if a datagram of unexpected length
(without the netlink header) is received, or an error code which
cannot happen due to the way the netlink socket is used.

2015-11-03  Florian Weimer  <fweimer@redhat.com>

	[BZ #12926]
	Terminate process on invalid netlink response.
	* sysdeps/unix/sysv/linux/netlinkaccess.h
	(__netlink_assert_response): Declare.
	* sysdeps/unix/sysv/linux/netlink_assert_response.c: New file.
	* sysdeps/unix/sysv/linux/Makefile [$(subdir) =3D=3D inet]
	(sysdep_routines): Add netlink_assert_response.
	* sysdeps/unix/sysv/linux/check_native.c (__check_native): Call
	__netlink_assert_response.
	* sysdeps/unix/sysv/linux/check_pf.c (make_request): Likewise.
	* sysdeps/unix/sysv/linux/ifaddrs.c (__netlink_request): Likewise.
	* sysdeps/unix/sysv/linux/Versions (GLIBC_PRIVATE): Add
	__netlink_assert_response.

diff --git a/ChangeLog b/ChangeLog
index ab7aa69..0b8ed92 100644
--- a/ChangeLog
+++ b/ChangeLog
@@ -1,3 +1,19 @@
+2015-11-03  Florian Weimer  <fweimer@redhat.com>
+
+	[BZ #12926]
+	Terminate process on invalid netlink response.
+	* sysdeps/unix/sysv/linux/netlinkaccess.h
+	(__netlink_assert_response): Declare.
+	* sysdeps/unix/sysv/linux/netlink_assert_response.c: New file.
+	* sysdeps/unix/sysv/linux/Makefile [$(subdir) =3D=3D inet]
+	(sysdep_routines): Add netlink_assert_response.
+	* sysdeps/unix/sysv/linux/check_native.c (__check_native): Call
+	__netlink_assert_response.
+	* sysdeps/unix/sysv/linux/check_pf.c (make_request): Likewise.
+	* sysdeps/unix/sysv/linux/ifaddrs.c (__netlink_request): Likewise.
+	* sysdeps/unix/sysv/linux/Versions (GLIBC_PRIVATE): Add
+	__netlink_assert_response.
+
 2015-11-02  Joseph Myers  <joseph@codesourcery.com>
=20
 	* math/libm-test.inc (modf_test_data): Add more tests.
diff --git a/NEWS b/NEWS
index 896eb02..d3738df 100644
--- a/NEWS
+++ b/NEWS
@@ -24,6 +24,14 @@ Version 2.23
   19095, 19124, 19125, 19129, 19134, 19137, 19156, 19174, 19181, 19189,
   19201.
=20
+* getaddrinfo now detects certain invalid responses on an internal netli=
nk
+  socket.  If such responses are received, an affected process will
+  terminate with an error message of "Unexpected error <number> on netli=
nk
+  descriptor <number>" or "Unexpected netlink response of size <number> =
on
+  descriptor <number>".  The most likely cause for these errors is a
+  multi-threaded application which erroneously closes and reuses the net=
link
+  file descriptor while it is used by getaddrinfo.
+
 * A defect in the malloc implementation, present since glibc 2.15 (2012)=
 or
   glibc 2.10 via --enable-experimental-malloc (2009), could result in th=
e
   unnecessary serialization of memory allocation requests across threads=
=2E
diff --git a/sysdeps/unix/sysv/linux/Makefile b/sysdeps/unix/sysv/linux/M=
akefile
index 2c67a66..d6cc529 100644
--- a/sysdeps/unix/sysv/linux/Makefile
+++ b/sysdeps/unix/sysv/linux/Makefile
@@ -151,6 +151,7 @@ sysdep_headers +=3D netinet/if_fddi.h netinet/if_tr.h=
 \
 		  netipx/ipx.h netash/ash.h netax25/ax25.h netatalk/at.h \
 		  netrom/netrom.h netpacket/packet.h netrose/rose.h \
 		  neteconet/ec.h netiucv/iucv.h
+sysdep_routines +=3D netlink_assert_response
 endif
=20
 # Don't compile the ctype glue code, since there is no old non-GNU C lib=
rary.
diff --git a/sysdeps/unix/sysv/linux/Versions b/sysdeps/unix/sysv/linux/V=
ersions
index 16bb281..202ffcc 100644
--- a/sysdeps/unix/sysv/linux/Versions
+++ b/sysdeps/unix/sysv/linux/Versions
@@ -169,5 +169,7 @@ libc {
   GLIBC_PRIVATE {
     # functions used in other libraries
     __syscall_rt_sigqueueinfo;
+    # functions used by nscd
+    __netlink_assert_response;
   }
 }
diff --git a/sysdeps/unix/sysv/linux/check_native.c b/sysdeps/unix/sysv/l=
inux/check_native.c
index eaefca1..d04c8f2 100644
--- a/sysdeps/unix/sysv/linux/check_native.c
+++ b/sysdeps/unix/sysv/linux/check_native.c
@@ -35,6 +35,7 @@
=20
 #include <not-cancel.h>
=20
+#include "netlinkaccess.h"
=20
 void
 __check_native (uint32_t a1_index, int *a1_native,
@@ -117,6 +118,7 @@ __check_native (uint32_t a1_index, int *a1_native,
 	};
=20
       ssize_t read_len =3D TEMP_FAILURE_RETRY (__recvmsg (fd, &msg, 0));=

+      __netlink_assert_response (fd, read_len);
       if (read_len < 0)
 	goto out_fail;
=20
diff --git a/sysdeps/unix/sysv/linux/check_pf.c b/sysdeps/unix/sysv/linux=
/check_pf.c
index f072fb3..af4fdf8 100644
--- a/sysdeps/unix/sysv/linux/check_pf.c
+++ b/sysdeps/unix/sysv/linux/check_pf.c
@@ -36,6 +36,7 @@
 #include <atomic.h>
 #include <nscd/nscd-client.h>
=20
+#include "netlinkaccess.h"
=20
 #ifndef IFA_F_HOMEADDRESS
 # define IFA_F_HOMEADDRESS 0
@@ -164,7 +165,8 @@ make_request (int fd, pid_t pid)
 	};
=20
       ssize_t read_len =3D TEMP_FAILURE_RETRY (__recvmsg (fd, &msg, 0));=

-      if (read_len <=3D 0)
+      __netlink_assert_response (fd, read_len);
+      if (read_len < 0)
 	goto out_fail;
=20
       if (msg.msg_flags & MSG_TRUNC)
diff --git a/sysdeps/unix/sysv/linux/ifaddrs.c b/sysdeps/unix/sysv/linux/=
ifaddrs.c
index 64b4a1c..768a7ed 100644
--- a/sysdeps/unix/sysv/linux/ifaddrs.c
+++ b/sysdeps/unix/sysv/linux/ifaddrs.c
@@ -168,6 +168,7 @@ __netlink_request (struct netlink_handle *h, int type=
)
 	};
=20
       read_len =3D TEMP_FAILURE_RETRY (__recvmsg (h->fd, &msg, 0));
+      __netlink_assert_response (h->fd, read_len);
       if (read_len < 0)
 	goto out_fail;
=20
diff --git a/sysdeps/unix/sysv/linux/netlink_assert_response.c b/sysdeps/=
unix/sysv/linux/netlink_assert_response.c
new file mode 100644
index 0000000..b570e93
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/netlink_assert_response.c
@@ -0,0 +1,106 @@
+/* Check recvmsg results for netlink sockets.
+   Copyright (C) 2015 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <sys/socket.h>
+
+#include "netlinkaccess.h"
+
+static int
+get_address_family (int fd)
+{
+  struct sockaddr_storage sa;
+  socklen_t sa_len =3D sizeof (sa);
+  if (__getsockname (fd, (struct sockaddr *) &sa, &sa_len) < 0)
+    return -1;
+  /* Check that the socket family number is preserved despite in-band
+     signaling.  */
+  _Static_assert (sizeof (sa.ss_family) < sizeof (int), "address family =
size");
+  _Static_assert (0 < (__typeof__ (sa.ss_family)) -1,
+                  "address family unsigned");
+  return sa.ss_family;
+}
+
+void
+internal_function
+__netlink_assert_response (int fd, ssize_t result)
+{
+  if (result < 0)
+    {
+      /* Check if the error is unexpected.  */
+      bool terminate =3D false;
+      int error_code =3D errno;
+      int family =3D get_address_family (fd);
+      if (family !=3D AF_NETLINK)
+        /* If the address family does not match (or getsockname
+           failed), report the original error.  */
+        terminate =3D true;
+      else if (error_code =3D=3D EBADF
+          || error_code =3D=3D ENOTCONN
+          || error_code =3D=3D ENOTSOCK
+          || error_code =3D=3D ECONNREFUSED)
+        /* These errors indicate that the descriptor is not a
+           connected socket.  */
+        terminate =3D true;
+      else if (error_code =3D=3D EAGAIN || error_code =3D=3D EWOULDBLOCK=
)
+        {
+          /* The kernel might return EAGAIN for other reasons than a
+             non-blocking socket.  But if the socket is not blocking,
+             it is not ours, so report the error.  */
+          int mode =3D __fcntl (fd, F_GETFL, 0);
+          if (mode < 0 || (mode & O_NONBLOCK) !=3D 0)
+            terminate =3D true;
+        }
+      if (terminate)
+        {
+          char message[200];
+          if (family < 0)
+            __snprintf (message, sizeof (message),
+                        "Unexpected error %d on netlink descriptor %d",
+                        error_code, fd);
+          else
+            __snprintf (message, sizeof (message),
+                        "Unexpected error %d on netlink descriptor %d"
+                        " (address family %d)",
+                        error_code, fd, family);
+          __libc_fatal (message);
+        }
+      else
+        /* Restore orignal errno value.  */
+        __set_errno (error_code);
+    }
+  else if (result < sizeof (struct nlmsghdr))
+    {
+      char message[200];
+      int family =3D get_address_family (fd);
+      if (family < 0)
+          __snprintf (message, sizeof (message),
+                      "Unexpected netlink response of size %zd"
+                      " on descriptor %d",
+                      result, fd);
+      else
+          __snprintf (message, sizeof (message),
+                      "Unexpected netlink response of size %zd"
+                      " on descriptor %d (address family %d)",
+                      result, fd, family);
+      __libc_fatal (message);
+    }
+}
+libc_hidden_def (__netlink_assert_response)
diff --git a/sysdeps/unix/sysv/linux/netlinkaccess.h b/sysdeps/unix/sysv/=
linux/netlinkaccess.h
index c204b67..01ac35c 100644
--- a/sysdeps/unix/sysv/linux/netlinkaccess.h
+++ b/sysdeps/unix/sysv/linux/netlinkaccess.h
@@ -19,6 +19,7 @@
 #define _NETLINKACCESS_H 1
=20
 #include <stdint.h>
+#include <sys/types.h>
 #include <asm/types.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
@@ -48,5 +49,10 @@ extern void __netlink_close (struct netlink_handle *h)=
;
 extern void __netlink_free_handle (struct netlink_handle *h);
 extern int __netlink_request (struct netlink_handle *h, int type);
=20
+/* Terminate the process if RESULT is an invalid recvmsg result for
+   the netlink socket FD.  */
+void __netlink_assert_response (int fd, ssize_t result)
+  internal_function;
+libc_hidden_proto (__netlink_assert_response)
=20
 #endif /* netlinkaccess.h */
--=20
2.4.3


--------------020908060904020603060902--
