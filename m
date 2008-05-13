From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] DCCP: Fix to reset the connection with Reset Code 5 Option
 Error while receive invalid option
Date: Tue, 13 May 2008 16:17:32 +0800
Message-ID: <48294E9C.4060209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54577 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756693AbYEMIRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 04:17:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If endpoint received invalid option, it must reset the connection with 
Reset Code 5 "Option Error", but current kernel send reset with Reset 
Code 4 "Packet Error".

This patch fixed this problem. dccp_parse_options() has set reset code 
to 5 if option is invalid, so just return 1 to let reset be send with 
this reset code.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/dccp/input.c	2008-05-02 15:37:25.000000000 -0400
+++ b/net/dccp/input.c	2008-05-02 15:50:01.000000000 -0400
@@ -428,7 +428,7 @@ static int dccp_rcv_request_sent_state_p
 		}
 
 		if (dccp_parse_options(sk, NULL, skb))
-			goto out_invalid_packet;
+			goto out_invalid_option;
 
 		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
 		if (likely(dp->dccps_options_received.dccpor_timestamp_echo))
@@ -508,6 +508,7 @@ static int dccp_rcv_request_sent_state_p
 out_invalid_packet:
 	/* dccp_v4_do_rcv will send a reset */
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_PACKET_ERROR;
+out_invalid_option:
 	return 1;
 }
 



