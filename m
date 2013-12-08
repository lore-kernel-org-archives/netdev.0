From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 08 Dec 2013 12:50:24 -0800
Message-ID: <1386535824.30495.301.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LFD.2.03.1312031500020.570@intel.com>
	 <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
	 <alpine.LFD.2.03.1312031626400.7539@intel.com>
	 <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
	 <alpine.LFD.2.03.1312040113290.14367@intel.com>
	 <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
	 <52A197DF.5010806@mellanox.com>
	 <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
	 <20131208124352.GA7935@zed.ravello.local> <52A46F2A.40101@mellanox.com>
	 <20131208143054.GA6984@zed.ravello.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45545 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759914Ab3LHUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 15:50:29 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so4118853pbc.20
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 12:50:28 -0800 (PST)
In-Reply-To: <20131208143054.GA6984@zed.ravello.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-08 at 16:30 +0200, Mike Rapoport wrote:
>  
> It was something *very* hacky:

> 		if (skb->len < 64000)
> 			skb_shinfo(skb)->gso_size = skb->len;
> 		else
> 			skb_shinfo(skb)->gso_size = 64000;

This sounds like an 16bit overflow somewhere.

This reminds the issue we fix in commit 50bceae9bd356
("tcp: Reallocate headroom if it would overflow csum_start")

You might try to reduce the 0xFFFF to something smaller.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 993da005e087..8364bcfe1e08 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2373,7 +2373,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * beyond what csum_start can cover.
 	 */
 	if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
-		     skb_headroom(skb) >= 0xFFFF)) {
+		     skb_headroom(skb) >= 0xFF00)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
 						   GFP_ATOMIC);
 		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
