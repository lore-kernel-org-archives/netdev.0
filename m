From: Bin Li <libin.charles@gmail.com>
Subject: [PATCH] correct_error_code.patch
Date: Fri, 22 Jul 2011 12:03:47 +0800
Message-ID: <CAGBH1r5dpEX0gbh3KDKQ15Opc6sba=MDM+5gRy8Ry7eKLcT72w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51113 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1GVEDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:03:49 -0400
Received: by iyb12 with SMTP id 12so1517008iyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 21:03:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The issue is came from https://bugzilla.novell.com/show_bug.cgi?id=681952.

In any previous version (since suse ... 10.0?), ip addr add always returned
the error code 2 in case the ip address is already set on the interface:

# ip a s dev bond0 | grep 172
    inet 172.16.2.3/24 brd 172.16.2.255 scope global bond0
# ip a a 172.16.2.3/24 dev bond0 ; echo $?
RTNETLINK answers: File exists
2

On 11.4, it returns the exit code 254:

# ip a s dev eth0 | grep 172
    inet 172.16.1.1/24 brd 172.16.1.255 scope global eth0
# ip addr add 172.16.1.1/24 dev eth0 ; echo $?
RTNETLINK answers: File exists
254

This of course causes ifup to return an error in this quite common case...

And I found it caused by commit 1db61e022d5f4318b9b236fef48be48a65e00878
-----------------------------------------------------------------------------------------------------
commit 1db61e022d5f4318b9b236fef48be48a65e00878
Author: Michele Petrazzo - Unipex <michele.petrazzo@unipex.it>
Date:   Sat Mar 6 08:56:53 2010 +0000

    Continue after errors in -batch

    Allow ip to process all the file passed with the -batch argument when
    is passed also the -force switch

    Signed-off-by: Michele Petrazzo <michele.petrazzo@unipex.it>

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3186f9c..48f7b1e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1039,7 +1039,7 @@ static int ipaddr_modify(int cmd, int flags, int argc,
char **argv)
        }
        if (l && matches(d, l) != 0) {
                fprintf(stderr, "\"dev\" (%s) must match \"label\" (%s).\n", d,
l);
-               exit(1);
+               return -1;
        }

        if (peer_len == 0 && local_len) {
@@ -1104,7 +1104,7 @@ static int ipaddr_modify(int cmd, int flags, int argc,
char **argv)
        }

        if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
-               exit(2);
+               return -2;

        return 0;
 }
-----------------------------------------------------------------------------------------------------

The fix to not exit seems to be correct to continue in batch mode, but
it (is incomplete and) breaks the normal operations because main does
not catch this change.

And we made patch for it.

-----------------------------------------------------------------------------------------------------
diff --git a/ip/ip.c b/ip/ip.c
index 7f0c468..75bc830 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -145,6 +145,7 @@ static int batch(const char *name)
 int main(int argc, char **argv)
 {
        char *basename;
+       int ret = 0;

        basename = strrchr(argv[0], '/');
        if (basename == NULL)
@@ -247,17 +248,29 @@ int main(int argc, char **argv)

        _SL_ = oneline ? "\\" : "\n" ;

-       if (batch_file)
-               return batch(batch_file);
+       if (batch_file) {
+               ret = batch(batch_file);
+               if (ret < 0)
+                       ret = -ret;
+               exit(ret);
+       }

        if (rtnl_open(&rth, 0) < 0)
                exit(1);

-       if (strlen(basename) > 2)
-               return do_cmd(basename+2, argc, argv);
+       if (strlen(basename) > 2) {
+               ret = do_cmd(basename+2, argc, argv);
+               if (ret < 0)
+                       ret = -ret;
+               exit(ret);
+       }

-       if (argc > 1)
-               return do_cmd(argv[1], argc-1, argv+1);
+       if (argc > 1) {
+               ret = do_cmd(argv[1], argc-1, argv+1);
+               if (ret < 0)
+                       ret = -ret;
+               exit(ret);
+       }

        rtnl_close(&rth);
        usage();

-----------------------------------------------------------------------------------------------------

What to do with this problem as it would make sense to make the error
codes "stable" (again)?

BTW, how to join this mailinglist?

Sincerely Yours,

Bin Li

http://zh.opensuse.org
