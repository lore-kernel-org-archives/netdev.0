From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed correctly
Date: Thu, 20 Dec 2007 12:31:27 +0900
Message-ID: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:58187 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767AbXLTDb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 22:31:29 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1726903nze.1
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 19:31:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"ip route show" does not print correct value when larger rto_min is
set (e.g. 3sec).

This problem is because of overflow in print_route() and
the patch below is a workaround fix for that.

[root test]# ./iproute2.git.org/ip/ip route show dev eth1
192.168.140.0/24  proto kernel  scope link  src 192.168.140.130
169.254.0.0/16  scope link
[root test]# ./iproute2.git.org/ip/ip route change 192.168.140.0/24
dev eth1 rto_min 3s
[root test]# ./iproute2.git.org/ip/ip route show dev eth1
192.168.140.0/24  scope link  rto_min lock 2ms     <-- wrong
169.254.0.0/16  scope link
[root test]# ./iproute2.git/ip/ip route show dev eth1  # patched version
192.168.140.0/24  scope link  rto_min lock 3000ms  <-- correct
169.254.0.0/16  scope link
[root test]#


Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 ip/iproute.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index f4200ae..fa722c6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -510,16 +510,16 @@ int print_route(const struct sockaddr_nl *who,
struct nlmsghdr *n, void *arg)
                                fprintf(fp, " %u",
*(unsigned*)RTA_DATA(mxrta[i]));
                        else {
                                unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
+                               unsigned hz1 = hz / 1000;

-                               val *= 1000;
                                if (i == RTAX_RTT)
                                        val /= 8;
                                else if (i == RTAX_RTTVAR)
                                        val /= 4;
-                               if (val >= hz)
-                                       fprintf(fp, " %ums", val/hz);
+                               if (val >= hz1)
+                                       fprintf(fp, " %ums", val/hz1);
                                else
-                                       fprintf(fp, " %.2fms", (float)val/hz);
+                                       fprintf(fp, " %.2fms", (float)val/hz1);
                        }
                }
        }
