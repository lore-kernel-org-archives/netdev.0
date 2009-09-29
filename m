From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH] [RFC] IPv4 TCP fails to send window scale option when window
 scale is zero
Date: Tue, 29 Sep 2009 17:05:52 +0200
Message-ID: <4AC22250.7060301@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ori Finkalman <ori@comsleep.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:46420 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbZI2Pbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 11:31:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ori Finkalman <ori@comsleep.com>


Acknowledge TCP window scale support by inserting the proper option in 
SYN/ACK header
even if our window scale is zero.


This fixes the following observed behavior:


1. Client sends a SYN with TCP window scaling option and non zero window 
scale value to a Linux box.

2. Linux box notes large receive window from client.

3. Linux decides on a zero value of window scale for its part.

4. Due to compare against requested window scale size option, Linux does 
not to send windows scale

TCP option header on SYN/ACK at all.


Result:


Client box thinks TCP window scaling is not supported, since SYN/ACK had 
no TCP window scale option,
while Linux thinks that TCP window scaling is supported (and scale might 
be non zero), since SYN had

TCP window scale option and we have a mismatched idea between the client 
and server regarding window sizes.


Please comment and/or apply.


---


Bug reported and patch written by Ori Finkalman from Comsleep Ltd. I'm 
just helping mainline it.


The behavior was observed with a Windows box as the client and latest 
Debian kernel but for the best
of my understanding this can happen with latest kernel versions and 
other client OS (probably also Linux)

as well.



Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
Signed-off-by: Ori Finkelman <ori@comsleep.com>


Index: net/ipv4/tcp_output.c
===================================================================
--- net/ipv4/tcp_output.c    (revision 46)
+++ net/ipv4/tcp_output.c    (revision 210)
@@ -353,6 +353,7 @@ static void tcp_init_nondata_skb(struct
 #define OPTION_SACK_ADVERTISE    (1 << 0)
 #define OPTION_TS        (1 << 1)
 #define OPTION_MD5        (1 << 2)
+#define OPTION_WSCALE        (1 << 3)
 
 struct tcp_out_options {
     u8 options;        /* bit field of OPTION_* */
@@ -417,7 +418,7 @@ static void tcp_options_write(__be32 *pt
                    TCPOLEN_SACK_PERM);
     }
 
-    if (unlikely(opts->ws)) {
+    if (unlikely(OPTION_WSCALE & opts->options)) {
         *ptr++ = htonl((TCPOPT_NOP << 24) |
                    (TCPOPT_WINDOW << 16) |
                    (TCPOLEN_WINDOW << 8) |
@@ -530,8 +531,8 @@ static unsigned tcp_synack_options(struc
 
     if (likely(ireq->wscale_ok)) {
         opts->ws = ireq->rcv_wscale;
-        if(likely(opts->ws))
-            size += TCPOLEN_WSCALE_ALIGNED;
+        opts->options |= OPTION_WSCALE;
+        size += TCPOLEN_WSCALE_ALIGNED;
     }
     if (likely(doing_ts)) {
         opts->options |= OPTION_TS;



-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."

