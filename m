From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: drop SACK if ctsn is not less than the next tsn of
 assoc
Date: Tue, 31 Jul 2007 12:44:27 +0800
Message-ID: <46AEBE2B.1060702@cn.fujitsu.com>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:51366 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbXGaEpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 00:45:47 -0400
In-Reply-To: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If SCTP data sender received a SACK which contains Cumulative TSN Ack is 
not less than the Cumulative TSN Ack Point, and if this Cumulative TSN 
Ack is not used by the data sender, SCTP data sender still accept this 
SACK , and next SACK which send correctly to DATA sender be dropped, 
because it is less than the new Cumulative TSN Ack Point.
After received this SACK, data will be retrans again and again even if 
correct SACK is received.
So I think this SACK must be dropped to let data transmit  correctly.

Following is the tcpdump of my test. And patch in this mail can avoid 
this problem.

02:19:38.233278 sctp (1) [INIT] [init tag: 1250461886] [rwnd: 54784] [OS: 10] [MIS: 65535] [init TSN: 217114040] 
02:19:39.782160 sctp (1) [INIT ACK] [init tag: 1] [rwnd: 54784] [OS: 100] [MIS: 65535] [init TSN: 100] 
02:19:39.798583 sctp (1) [COOKIE ECHO] 
02:19:40.082125 sctp (1) [COOKIE ACK] 
02:19:40.097859 sctp (1) [DATA] (B)(E) [TSN: 217114040] [SID: 0] [SSEQ 0] [PPID 0xf192090b] 
02:19:40.100162 sctp (1) [DATA] (B)(E) [TSN: 217114041] [SID: 0] [SSEQ 1] [PPID 0x3e467007] 
02:19:40.100779 sctp (1) [DATA] (B)(E) [TSN: 217114042] [SID: 0] [SSEQ 2] [PPID 0x11b12a0a] 
02:19:40.101200 sctp (1) [DATA] (B)(E) [TSN: 217114043] [SID: 0] [SSEQ 3] [PPID 0x30e7d979] 
02:19:40.561147 sctp (1) [SACK] [cum ack 217114040] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:40.568498 sctp (1) [DATA] (B)(E) [TSN: 217114044] [SID: 0] [SSEQ 4] [PPID 0x251ff86f] 
02:19:40.569308 sctp (1) [DATA] (B)(E) [TSN: 217114045] [SID: 0] [SSEQ 5] [PPID 0xe5d5da5d] 
02:19:40.700584 sctp (1) [SACK] [cum ack 290855864] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:40.701562 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:40.701567 sctp (1) [DATA] (B)(E) [TSN: 217114047] [SID: 0] [SSEQ 7] [PPID 0xca47e645] 
02:19:40.701569 sctp (1) [DATA] (B)(E) [TSN: 217114048] [SID: 0] [SSEQ 8] [PPID 0x6c0ea150] 
02:19:40.701576 sctp (1) [DATA] (B)(E) [TSN: 217114049] [SID: 0] [SSEQ 9] [PPID 0x9cc1994f] 
02:19:40.701585 sctp (1) [DATA] (B)(E) [TSN: 217114050] [SID: 0] [SSEQ 10] [PPID 0xb1df4129] 
02:19:41.098201 sctp (1) [SACK] [cum ack 217114041] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:41.283257 sctp (1) [SACK] [cum ack 217114042] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:41.457217 sctp (1) [SACK] [cum ack 217114043] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:41.691528 sctp (1) [SACK] [cum ack 217114044] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:41.849636 sctp (1) [SACK] [cum ack 217114045] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:41.975473 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:42.021229 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:42.196495 sctp (1) [SACK] [cum ack 217114047] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:42.424319 sctp (1) [SACK] [cum ack 217114048] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:42.586924 sctp (1) [SACK] [cum ack 217114049] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:42.744810 sctp (1) [SACK] [cum ack 217114050] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:42.965536 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:43.106385 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:43.218969 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:45.374101 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:45.489258 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:49.830116 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:49.984577 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
02:19:58.760300 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
02:19:58.931690 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 


Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- net/sctp/sm_statefuns.c.orig	2007-07-29 18:11:01.000000000 -0400
+++ net/sctp/sm_statefuns.c	2007-07-29 18:14:49.000000000 -0400
@@ -2880,6 +2880,15 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
+	/* If Cumulative TSN Ack is not less than the Cumulative TSN
+	 * Ack which will be send in the next data, drop the SACK.
+	 */
+	if (!TSN_lt(ctsn, asoc->next_tsn)) {
+		SCTP_DEBUG_PRINTK("ctsn %x\n", ctsn);
+		SCTP_DEBUG_PRINTK("next_tsn %x\n", asoc->next_tsn);
+		return SCTP_DISPOSITION_DISCARD;
+	}
+
 	/* Return this SACK for further processing.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_SACKH(sackh));
 



