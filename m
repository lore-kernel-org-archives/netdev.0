From: "Cloutier, Joseph (Joseph)" <joseph.cloutier@alcatel-lucent.com>
Subject: [PATCH] iputils-s20101006.tar.bz2: "-w deadline" starts after "-c"
 xmitted, and "-c" was exceeded for flood ping
Date: Tue, 10 Jan 2012 12:00:42 -0600
Message-ID: <7D3B6706FA74174B8C1AC24710890745136F454081@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
References: <4F0BB687.6070603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'Linus Torvalds'" <torvalds@linux-foundation.org>
To: "'YOSHIFUJI Hideaki'" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail1.lucent.com ([135.245.0.33]:42166 "EHLO
	ihemail1.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab2AJSBV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 13:01:21 -0500
In-Reply-To: <4F0BB687.6070603@linux-ipv6.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Cloutier <jcloutier@alcatel-lucent.com>

2 changes to ping & ping6.  Only ping_common.c affected.
  1- changed "-w deadline" to start deadline after "-c" pings have been transmitted, instead of from start of run.
  2- fixed bug where > "-c" pings are sent in flood ping mode when "-w deadline" option is also used.
Reason:
  Linux flood ping is an invaluable tool to finding duplex bugs, fiber problems, NE config problems-  especially
  when used to trouble shoot wireless system backhaul problems.  ANY dropped pings are red flag indicators.
  Current ping problem is that it terminates sometimes when outstanding pings are in transit, giving FALSE red
  flags.  Change "-w deadline" to start after last "-c" transmitted ping allows cleanup of stragglers.  Second fix is
  when "-f" option is running, "-c" is not rigorously checked when generating pings  A more rigorous check was
  added.

Signed-off-by: Joseph Cloutier <jcloutier@alcatel-lucent.com>

---
--- iputils-s20101006/ping_common.c.orig        2012-01-10 10:37:40.399719858 -0500
+++ iputils-s20101006/ping_common.c     2012-01-10 11:33:37.084662882 -0500
@@ -523,16 +523,6 @@ void setup(int icmp_sock)

        gettimeofday(&start_time, NULL);

-       if (deadline) {
-               struct itimerval it;
-
-               it.it_interval.tv_sec = 0;
-               it.it_interval.tv_usec = 0;
-               it.it_value.tv_sec = deadline;
-               it.it_value.tv_usec = 0;
-               setitimer(ITIMER_REAL, &it, NULL);
-       }
-
        if (isatty(STDOUT_FILENO)) {
                struct winsize w;

@@ -553,6 +543,7 @@ void main_loop(int icmp_sock, __u8 *pack
        int cc;
        int next;
        int polling;
+       int sig_deadline = 0;

        iov.iov_base = (char *)packet;

@@ -567,9 +558,22 @@ void main_loop(int icmp_sock, __u8 *pack
                /* Check for and do special actions. */
                if (status_snapshot)
                        status();
+               if((npackets == ntransmitted) && deadline &&
+                       (sig_deadline == 0)){
+                       sig_deadline++;
+                       struct itimerval it;
+
+                       it.it_interval.tv_sec = 0;
+                       it.it_interval.tv_usec = 0;
+                       it.it_value.tv_sec = deadline;
+                       it.it_value.tv_usec = 0;
+                       setitimer(ITIMER_REAL, &it, NULL);
+               }

                /* Send probes scheduled to this time. */
                do {
+                       if(npackets == ntransmitted)
+                               break;
                        next = pinger();
                        next = schedule_exit(next);
                } while (next <= 0);
