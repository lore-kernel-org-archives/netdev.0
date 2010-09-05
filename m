From: Thomas Habets <thomas@habets.pp.se>
Subject: [PATCH] iputils ping,ping6: use monotonic clock to schedule pings
Date: Sun, 5 Sep 2010 14:58:24 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1009051453090.13886@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:1348 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab0IEM60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 08:58:26 -0400
Received: from red.crap.retrofitta.se (10.200.216.81.static.apv.siw.siwnet.net [81.216.200.10])
	by reptilian.habets.pp.se (Postfix) with ESMTP id 2B01A3C898
	for <netdev@vger.kernel.org>; Sun,  5 Sep 2010 14:58:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes the problem where when time is set backwards 'ping' appears
to freeze until the walltime catches up with the previously set time.

Adds dependency on librt.

diff --git a/Makefile b/Makefile
index 42f8475..a6812a3 100644
--- a/Makefile
+++ b/Makefile
@@ -28,8 +28,8 @@ all: $(TARGETS)

  tftpd: tftpd.o tftpsubs.o
  arping: arping.o -lsysfs
-ping: ping.o ping_common.o
-ping6: ping6.o ping_common.o -lresolv -lcrypto
+ping: ping.o ping_common.o -lrt
+ping6: ping6.o ping_common.o -lresolv -lcrypto -lrt
  ping.o ping6.o ping_common.o: ping_common.h
  tftpd.o tftpsubs.o: tftp.h

diff --git a/ping_common.c b/ping_common.c
index e0edf39..5883e63 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -304,6 +304,20 @@ void print_timestamp(void)
         }
  }

+int
+getclock(struct timeval *tv)
+{
+#ifdef CLOCK_MONOTONIC
+       struct timespec ts;
+       if (!clock_gettime(CLOCK_MONOTONIC, &ts)) {
+               tv->tv_sec = ts.tv_sec;
+               tv->tv_usec = ts.tv_nsec / 1000;
+               return;
+       }
+#endif
+       return gettimeofday(tv, NULL);
+}
+
  /*
   * pinger --
   *     Compose and transmit an ICMP ECHO REQUEST packet.  The IP packet
@@ -324,13 +338,13 @@ int pinger(void)

         /* Check that packets < rate*time + preload */
         if (cur_time.tv_sec == 0) {
-               gettimeofday(&cur_time, NULL);
+               getclock(&cur_time);
                 tokens = interval*(preload-1);
         } else {
                 long ntokens;
                 struct timeval tv;

-               gettimeofday(&tv, NULL);
+               getclock(&tv);
                 ntokens = (tv.tv_sec - cur_time.tv_sec)*1000 +
                         (tv.tv_usec-cur_time.tv_usec)/1000;
                 if (!interval) {
