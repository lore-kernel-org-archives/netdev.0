From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Tue, 09 Dec 2014 13:40:19 -0800
Message-ID: <1418161219.27198.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <3594382.qsqLZcX7yO@storm>
	 <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2625472.GutY3xCvKT@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36730 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaLIVkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:40:21 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so5335575igb.11
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 13:40:21 -0800 (PST)
In-Reply-To: <2625472.GutY3xCvKT@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 21:36 +0100, Wolfgang Walter wrote:

> How would that be done? I found no way to disable it especially for xfrm. I 
> disabled gso for the interface which serves the ipsec traffic but this does 
> not help. tcp still uses gso for the esp tunnel.
> 
> I put a view printk's in net/xfrm/xfrm_output.c and net/ipv4/tcp_output.c. (I 
> try to understand where in the xfrm transformation gso is handeled).
> 
> What I can say yet is:
> 
> xfrm_output() is used with ipsec (esp) tunnel mode but at I never see gso 
> packets here. xfrm_output_gso() is never called.
> 
> Everytime tcp_set_skb_tso_segs() is called for a tcp connection over the esp-
> tunnel and it is a gso case then the tcp connection hangs. Those packets 
> always have skb->len 1398 and mss_now is 1374. I see a call of xfrm_output() 
> afterwards but for a packet of skb->len 52 (maybe ACK from other direction?).
> 
> As long as the tcp-connection over the ipsec-tunnel works and if I send bulk 
> traffic xfrm_output() is called 3 times with packet skb->len 1426 and then one 
> time with 78 (maybe other direction?), don't know if that is of any interest.
> 
> 
> With non-ipsec-traffic gso works fine: in this case the skb->len() varies a 
> lot and mss_now is always 1288.
> 

Presumably something happens so that sk_can_gso() returns false.

But apparently, this happens _after_ tcp_sendmsg(), ie a bit too late.

Note that after https://patchwork.ozlabs.org/patch/418506/ is applied,
fix would simply be :

diff --git a/net/core/sock.c b/net/core/sock.c
index 9a56b2000c3f374fb95aedada3327447816a9512..678ef8393680dc781445c5f121719ea8ea7bb7c1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 			sk->sk_gso_max_size = dst->dev->gso_max_size;
 			sk->sk_gso_max_segs = dst->dev->gso_max_segs;
 		}
+	} else {
+		sk->sk_gso_max_segs = 1;
 	}
 }
 EXPORT_SYMBOL_GPL(sk_setup_caps);
