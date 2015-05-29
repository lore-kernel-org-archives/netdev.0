From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: do not bindly dump two families
Date: Fri, 29 May 2015 05:37:49 -0700
Message-ID: <1432903069.7456.87.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34676 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbE2Mhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 08:37:51 -0400
Received: by igbhj9 with SMTP id hj9so13431867igb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 05:37:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ss currently dumps IPv4 sockets, then IPv6 sockets from the kernel,
even if -4 or -6 option was given. Filtering in user space then has to
drop all sockets of wrong family. Such a waste of time...

Before :

$ time ss -tn -4 | wc -l
251659

real	0m1.241s
user	0m0.423s
sys	0m0.806s

After:

$ time ss -tn -4 | wc -l
251672

real	0m0.779s
user	0m0.412s
sys	0m0.386s


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 347e3a1..4ef8fea 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2209,6 +2209,8 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 		return -1;
 	rth.dump = MAGIC_SEQ;
 	rth.dump_fp = dump_fp;
+	if (preferred_family == PF_INET6)
+		family = PF_INET6;
 
 again:
 	if ((err = sockdiag_send(family, rth.fd, protocol, f)))
@@ -2221,7 +2223,7 @@ again:
 		}
 		goto Exit;
 	}
-	if (family == PF_INET) {
+	if (family == PF_INET && preferred_family != PF_INET) {
 		family = PF_INET6;
 		goto again;
 	}
