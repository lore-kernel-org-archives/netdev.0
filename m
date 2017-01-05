From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Thu, 05 Jan 2017 10:27:52 -0800
Message-ID: <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        willemb@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34946 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdAEShk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 13:37:40 -0500
Received: by mail-pg0-f67.google.com with SMTP id i5so41460948pgh.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 10:36:58 -0800 (PST)
In-Reply-To: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-05 at 02:34 +0100, Daniel Borkmann wrote:
> When TX timestamping is in use with TPACKET_V3's TX ring, then we'll
> hit the BUG() in __packet_set_timestamp() when ring buffer slot is
> returned to user space via tpacket_destruct_skb(). This is due to v3
> being assumed as unreachable here, but since 7f953ab2ba46 ("af_packet:
> TX_RING support for TPACKET_V3") it's not anymore. Fix it by filling
> the timestamp back into the ring slot.
> 
> Fixes: 7f953ab2ba46 ("af_packet: TX_RING support for TPACKET_V3")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  net/packet/af_packet.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 7e39087..ddbda25 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -481,6 +481,9 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
>  		h.h2->tp_nsec = ts.tv_nsec;
>  		break;
>  	case TPACKET_V3:
> +		h.h3->tp_sec = ts.tv_sec;
> +		h.h3->tp_nsec = ts.tv_nsec;
> +		break;
>  	default:
>  		WARN(1, "TPACKET version not supported.\n");
>  		BUG();

Gosh. Can we also replace this BUG() into something less aggressive ?

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b9e1a13b4ba36a0bc7edf6a8c2c116c7d48c970c..0c0d268544787dcbef6601c5014e7d3836d16f96 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -476,9 +476,11 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
 		h.h2->tp_nsec = ts.tv_nsec;
 		break;
 	case TPACKET_V3:
+		h.h3->tp_sec = ts.tv_sec;
+		h.h3->tp_nsec = ts.tv_nsec;
+		break;
 	default:
-		WARN(1, "TPACKET version not supported.\n");
-		BUG();
+		pr_err_once("TPACKET version %u not supported.\n", po->tp_version);
 	}
 
 	/* one flush is safe, as both fields always lie on the same cacheline */
