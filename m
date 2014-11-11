From: David Buckley <isreal-netdev-at-vger.kernel.org@bucko.me.uk>
Subject: [PATCH] ping mdev rounding issue
Date: Tue, 11 Nov 2014 09:16:05 +0000
Message-ID: <20141111091605.GA20540@cirno.bucko.me.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiraboshi.bucko.me.uk ([192.95.26.74]:54381 "EHLO kiraboshi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752059AbaKKJvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 04:51:17 -0500
Received: from host81-129-56-167.range81-129.btcentralplus.com ([81.129.56.167] helo=cirno.fluorescence.co.uk)
	by kiraboshi with esmtpsa (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <isreal-localmail-from-bucko-at-cirno@bucko.me.uk>)
	id 1Xo7Wc-0005E7-Iz
	for netdev@vger.kernel.org; Tue, 11 Nov 2014 09:14:10 +0000
Received: from bucko by cirno.fluorescence.co.uk with local (Exim 4.84)
	(envelope-from <isreal-localmail-from-bucko-at-cirno@bucko.me.uk>)
	id 1Xo7YT-0000eu-UT
	for netdev@vger.kernel.org; Tue, 11 Nov 2014 09:16:05 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

ping has a rounding issue in standard deviation computation.

It stores all values as integer micros, and computes standard deviation
as:

sqrt(SUM(time*time)/count - (SUM(time)/count)*(SUM(time)/count))

Because the second 'count' divide is performed before the multiply, a
rounding error results of the order O(sqrt(SUM(time)/count)).

Example: I ping my server twice. One takes 1000us, the second takes
1001us.

Standard deviation computed by ping is:

  sqrt((1000000+1002001)/2 - ((1000+1001)/2)*((1000+1001)/2))
= sqrt(1001000 - 1000*1000) = sqrt(1000) = 31

So we got a 1us difference and report a 31 us standard deviation.

If the samples are 999 and 1001
  sqrt((998001+1002001)/2 - ((999+1001)/2)*((999+1001)/2))
= sqrt(1000001 - 1000*1000) = sqrt(1) = 0

So more deviation makes for less /reported/ deviation.

This is reduced slightly in this case by more samples (100*1000+1001
reports deviation of 4us, for instance), but really it's caused by the
rounding error ((float)SUM(time)/count) - (SUM(time)/count) being
/multiplied/ by the average time. The expected error is of the order
sqrt(mean).

Example real-world bad computation:

PING 74.125.230.238 (74.125.230.238) 56(84) bytes of data.
64 bytes from 74.125.230.238: icmp_seq=1 ttl=51 time=16.1 ms
64 bytes from 74.125.230.238: icmp_seq=2 ttl=51 time=16.1 ms
64 bytes from 74.125.230.238: icmp_seq=3 ttl=51 time=16.2 ms
64 bytes from 74.125.230.238: icmp_seq=4 ttl=51 time=16.1 ms
^C
--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 16.132/16.170/16.246/0.161 ms


With patch (attached):

PING 74.125.230.238 (74.125.230.238) 56(84) bytes of data.
64 bytes from 74.125.230.238: icmp_seq=1 ttl=51 time=16.0 ms
64 bytes from 74.125.230.238: icmp_seq=2 ttl=51 time=16.1 ms
64 bytes from 74.125.230.238: icmp_seq=3 ttl=51 time=16.1 ms
64 bytes from 74.125.230.238: icmp_seq=4 ttl=51 time=16.1 ms
^C
--- 74.125.230.238 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 16.045/16.128/16.197/0.054 ms

-- 
David Buckley

--fUYQa+Pmc3FrFX/N
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="fix_rounding.patch"

--- a/ping_common.c	2014-11-11 00:02:07.000000000 +0000
+++ b/ping_common.c	2014-11-11 09:04:06.699021939 +0000
@@ -1016,14 +1016,17 @@
 	}
 	putchar('\n');
 
 	if (nreceived && timing) {
 		long tmdev;
+		long count = nreceived + nrepeats;
 
-		tsum /= nreceived + nrepeats;
-		tsum2 /= nreceived + nrepeats;
-		tmdev = llsqrt(tsum2 - tsum * tsum);
+		// mdev = sqrt((tsum2/count) - (tsum/count)*(tsum2/count))
+		// However, we must be careful about rounding!
+		tmdev = llsqrt((tsum2 * count - tsum * tsum) / (count * count));
+		tsum2 /= count;
+		tsum /= count;
 
 		printf("rtt min/avg/max/mdev = %ld.%03ld/%lu.%03ld/%ld.%03ld/%ld.%03ld ms",
 		       (long)tmin/1000, (long)tmin%1000,
 		       (unsigned long)(tsum/1000), (long)(tsum%1000),
 		       (long)tmax/1000, (long)tmax%1000,

--fUYQa+Pmc3FrFX/N--
