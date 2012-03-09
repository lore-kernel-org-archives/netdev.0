From: Christophe Alladoum <Christophe.Alladoum@hsc.fr>
Subject: Possible integer overflow in ping_common.c
Date: Fri, 9 Mar 2012 17:33:00 +0100
Message-ID: <20120309163300.GC1925@taz.hsc.fr>
Reply-To: Christophe.Alladoum@hsc.fr
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Transfer-Encoding: 8bit
Cc: Romain Coltel <Romain.Coltel@hsc.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from itesec.hsc.fr ([192.70.106.33]:33459 "EHLO itesec.hsc.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756764Ab2CIQmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2012 11:42:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi list,

A collegue and I found a possible integer overflow in ping_common.c that could
lead to excessive CPU usage when triggered.

PoC :
{{{
$ ping -i 3600 google.com
PING google.com (173.194.66.102) 56(84) bytes of data.
64 bytes from we-in-f102.1e100.net (173.194.66.102): icmp_req=1 ttl=50 time=11.4 ms
[...]
(check your CPU usage)
}}}

Here, ping will loop in main_loop() loop in this section of code :
{{{
/* from iputils-s20101006 source */
/* ping_common.c */

    546 void main_loop(int icmp_sock, __u8 *packet, int packlen)
    547 {
[...]
    559         for (;;) {
[...]
    572                 do {
    573                         next = pinger();
    574                         next = schedule_exit(next);
    575                 } while (next <= 0);
[...]
    588                 if ((options & (F_ADAPTIVE|F_FLOOD_POLL)) || next<SCHINT(interval)) {
[...]
    593                         if (1000*next <= 1000000/(int)HZ) {
}}}

If interval parameter (-i) is set, then condition L593 will overflow, making
this statement "always true" for big values (e.g. -i 3600). As a consequence, 
ping process will start looping actively as long as condition is true (could be
pretty long).

Tested on Fedora/Debian/Gentoo Linux system (2.6.x x86_32 and x86_64) on iputils
version 20101006. ping6 seems also to be affected since it's relying on
ping_common.c functions.

Quick'n dirty patch (full patch in appendix) is to cast test result as long long:
{{{
    593                         if (((long long)1000*next) <= (long long)1000000/(int)HZ) {
}}}

Can you confirm this bug?

Thanks
-- 
Christophe Alladoum - <christophe.alladoum@hsc.fr>
Hervé Schauer Consultants - <http://www.hsc.fr>

--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ping_interger_overflow.patch"

--- /home/chris/downloads/iputils-s20101006/ping_common.c	2010-10-06 13:59:20.000000000 +0200
+++ /home/chris/downloads/iputils-s20101006-patched/ping_common.c	2012-03-09 16:42:46.878151032 +0100
@@ -590,7 +590,7 @@
 
 			/* If we are here, recvmsg() is unable to wait for
 			 * required timeout. */
-			if (1000*next <= 1000000/(int)HZ) {
+		if (((long long)1000*next) <= (long long)1000000/(int)HZ) {
 				/* Very short timeout... So, if we wait for
 				 * something, we sleep for MININTERVAL.
 				 * Otherwise, spin! */

--/04w6evG8XlLl3ft--
