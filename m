From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: don't update snd_nxt, when a socket is switched
 from repair mode
Date: Tue, 19 Nov 2013 10:29:40 -0800
Message-ID: <1384885780.8604.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384884606-9978-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	criu@openvz.org, Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384884606-9978-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-19 at 22:10 +0400, Andrey Vagin wrote:
> snd_nxt must be updated synchronously with sk_send_head.  Otherwise
> tp->packets_out may be updated incorrectly, what may bring a kernel panic.
> 
> Here is a kernel panic from my host.
> [  103.043194] BUG: unable to handle kernel NULL pointer dereference at 0000000000000048
> [  103.044025] IP: [<ffffffff815aaaaf>] tcp_rearm_rto+0xcf/0x150
> ...
> [  146.301158] Call Trace:
> [  146.301158]  [<ffffffff815ab7f0>] tcp_ack+0xcc0/0x12c0
> 
> Before this panic a tcp socket was restored. This socket had sent and
> unsent data in the write queue. Sent data was restored in repair mode,
> then the socket was switched from reapair mode and unsent data was
> restored. After that the socket was switched back into repair mode.
> 
> In that moment we had a socket where write queue looks like this:
> snd_una    snd_nxt   write_seq
>    |_________|________|
>              |
> 	  sk_send_head
> 
> After a second switching from repair mode the state of socket was
> changed:
> 
> snd_una          snd_nxt, write_seq
>    |_________ ________|
>              |
> 	  sk_send_head
> 
> This state is inconsistent, because snd_nxt and sk_send_head are not
> synchronized.
> 
> Bellow you can find a call trace, how packets_out can be incremented
> twice for one skb, if snd_nxt and sk_send_head are not synchronized.
> In this case packets_out will be always positive, even when
> sk_write_queue is empty.
> 
> tcp_write_wakeup
> 	skb = tcp_send_head(sk);
> 	tcp_fragment
> 		if (!before(tp->snd_nxt, TCP_SKB_CB(buff)->end_seq))
> 			tcp_adjust_pcount(sk, skb, diff);
> 	tcp_event_new_data_sent
> 		tp->packets_out += tcp_skb_pcount(skb);
> 
> I think update of snd_nxt isn't required, when a socket is switched from
> repair mode.  Because it's initialized in tcp_connect_init. Then when a
> write queue is restored, snd_nxt is incremented in tcp_event_new_data_sent,
> so it's always is in consistent state.
> 
> I have checked, that the bug is not reproduced with this patch and
> all tests about restoring tcp connections work fine.
> 
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  net/ipv4/tcp_output.c | 1 -
>  1 file changed, 1 deletion(-)

Fixes: c0e88ff0f256 ("tcp: Repair socket queues")
Acked-by: Eric Dumazet <edumazet@google.com>
