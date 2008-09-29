From: Ali Saidi <saidi@engin.umich.edu>
Subject: [PATCH] Fix possible double-ack w/ user dma
Date: Sun, 28 Sep 2008 21:13:37 -0500
Message-ID: <0298B280-C0E8-4A30-90B6-DD25A4054CF0@engin.umich.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-51--465918210
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.93.161]:39568 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbYI2CV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 22:21:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-51--465918210
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

When TCP receive copy offload is enabled it's possible that   
tcp_rcv_established() will cause two acks to be sent for a single  
packet. In the case that a tcp_dma_early_copy() is successful,  
copied_early is set to true which causes tcp_cleanup_rbuf() to be  
called early which can send an ack. Further along in  
tcp_rcv_established(),  __tcp_ack_snd_check() is called and will  
schedule a delayed ACK. If no packets are processed before the delayed  
ack timer expires the packet will be acked twice.

Attached is a patch that addresses the problem.

Ali




--Apple-Mail-51--465918210
Content-Disposition: attachment;
	filename=fix_double_ack.diff
Content-Type: application/octet-stream;
	x-unix-mode=0660;
	name="fix_double_ack.diff"
Content-Transfer-Encoding: 7bit

diff net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Thu Sep 25 16:37:03 2008 -0700
+++ b/net/ipv4/tcp_input.c	Sun Sep 28 20:56:50 2008 -0500
@@ -4879,7 +4879,8 @@ int tcp_rcv_established(struct sock *sk,
 					goto no_ack;
 			}
 
-			__tcp_ack_snd_check(sk, 0);
+			if (!copied_early && || tp->rcv_nxt != tp->rcv_wup)
+				__tcp_ack_snd_check(sk, 0);
 no_ack:
 #ifdef CONFIG_NET_DMA
 			if (copied_early)

--Apple-Mail-51--465918210
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7bit



--Apple-Mail-51--465918210--
