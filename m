From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Avoid infinite loop on recvmsg bug
Date: Wed, 07 Nov 2012 15:42:34 -0800
Message-ID: <1352331754.2748.14.camel@edumazet-glaptop>
References: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
	 <1352316791-16491-1-git-send-email-jwerner@chromium.org>
	 <1352317219.5552.6.camel@edumazet-glaptop>
	 <CAODwPW8mBJspF3k5SCBR-BShNvBLQpD-vyhLRh5Cq-4h=VZDgg@mail.gmail.com>
	 <1352331192.2748.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>
To: Julius Werner <jwerner@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352331192.2748.10.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-11-07 at 15:33 -0800, Eric Dumazet wrote:

> So you probably are fighting a bug we already fixed in upstream kernel.
> 
> (commit c8628155ece363 "tcp: reduce out_of_order memory use" did not
> played well with cloned skbs.)
> 
> This issue was already discussed on netdev in the past.

If you use a 3.4 kernel, you want the following patch.

(I guess you could reproduce the crash easily running a tcpdump in //)


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 257b617..9f8f68c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4496,7 +4496,9 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		 * to avoid future tcp_collapse_ofo_queue(),
 		 * probably the most expensive function in tcp stack.
 		 */
-		if (skb->len <= skb_tailroom(skb1) && !tcp_hdr(skb)->fin) {
+		if (skb->len <= skb_tailroom(skb1) &&
+		    !tcp_hdr(skb)->fin &&
+		    !skb_cloned(skb1)) {
 			NET_INC_STATS_BH(sock_net(sk),
 					 LINUX_MIB_TCPRCVCOALESCE);
 			BUG_ON(skb_copy_bits(skb, 0,
