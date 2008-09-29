From: Ali Saidi <saidi@engin.umich.edu>
Subject: Re: [PATCH] Fix possible double-ack w/ user dma
Date: Sun, 28 Sep 2008 22:45:51 -0500
Message-ID: <DCA6A06C-CE49-453F-91D8-23A6C4187FD6@engin.umich.edu>
References: <0298B280-C0E8-4A30-90B6-DD25A4054CF0@engin.umich.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-54--460384669
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:56514 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753996AbYI2Dx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 23:53:28 -0400
In-Reply-To: <0298B280-C0E8-4A30-90B6-DD25A4054CF0@engin.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-54--460384669
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

I attached a broken patch. This one is correct, although there are  
probably other ways to fix the issue.

Ali



--Apple-Mail-54--460384669
Content-Disposition: attachment;
	filename=fix_double_ack.diff
Content-Type: application/octet-stream;
	x-unix-mode=0660;
	name="fix_double_ack.diff"
Content-Transfer-Encoding: 7bit

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4879,7 +4879,8 @@ int tcp_rcv_established(struct sock *sk,
 					goto no_ack;
 			}
 
-			__tcp_ack_snd_check(sk, 0);
+			if (!copied_early || tp->rcv_nxt != tp->rcv_wup)
+				__tcp_ack_snd_check(sk, 0);
 no_ack:
 #ifdef CONFIG_NET_DMA
 			if (copied_early)

--Apple-Mail-54--460384669
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit


On Sep 28, 2008, at 9:13 PM, Ali Saidi wrote:

> When TCP receive copy offload is enabled it's possible that   
> tcp_rcv_established() will cause two acks to be sent for a single  
> packet. In the case that a tcp_dma_early_copy() is successful,  
> copied_early is set to true which causes tcp_cleanup_rbuf() to be  
> called early which can send an ack. Further along in  
> tcp_rcv_established(),  __tcp_ack_snd_check() is called and will  
> schedule a delayed ACK. If no packets are processed before the  
> delayed ack timer expires the packet will be acked twice.
>
> Attached is a patch that addresses the problem.
>
> Ali
>
>
>
> <fix_double_ack.diff>


--Apple-Mail-54--460384669--
