From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 07:44:50 +0100
Message-ID: <87li0kkhzx.fsf@natisbad.org>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
 netdev@vger.kernel.org, edumazet@google.com,
 Cong Wang <xiyou.wangcong@gmail.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 (Eric Dumazet's message of "Sun, 17 Nov 2013 09:41:38 -0800")
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Sun, 2013-11-17 at 15:19 +0100, Willy Tarreau wrote:
>
>> 
>> So it is fairly possible that in your case you can't fill the link if you
>> consume too many descriptors. For example, if your server uses TCP_NODELAY
>> and sends incomplete segments (which is quite common), it's very easy to
>> run out of descriptors before the link is full.
>
> BTW I have a very simple patch for TCP stack that could help this exact
> situation...
>
> Idea is to use TCP Small Queue so that we dont fill qdisc/TX ring with
> very small frames, and let tcp_sendmsg() have more chance to fill
> complete packets.
>
> Again, for this to work very well, you need that NIC performs TX
> completion in reasonable amount of time...
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3dc0c6c..10456cf 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -624,13 +624,19 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
>  {
>  	if (tcp_send_head(sk)) {
>  		struct tcp_sock *tp = tcp_sk(sk);
> +		struct sk_buff *skb = tcp_write_queue_tail(sk);
>  
>  		if (!(flags & MSG_MORE) || forced_push(tp))
> -			tcp_mark_push(tp, tcp_write_queue_tail(sk));
> +			tcp_mark_push(tp, skb);
>  
>  		tcp_mark_urg(tp, flags);
> -		__tcp_push_pending_frames(sk, mss_now,
> -					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
> +		if (flags & MSG_MORE)
> +			nonagle = TCP_NAGLE_CORK;
> +		if (atomic_read(&sk->sk_wmem_alloc) > 2048) {
> +			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
> +			nonagle = TCP_NAGLE_CORK;
> +		}
> +		__tcp_push_pending_frames(sk, mss_now, nonagle);
>  	}
>  }

I did some test regarding mvneta perf on current linus tree (commit
2d3c627502f2a9b0, w/ c9eeec26e32e "tcp: TSQ can use a dynamic limit"
reverted). It has Simon's tclk patch for mvebu (1022c75f5abd, "clk:
armada-370: fix tclk frequencies"). Kernel has some debug options
enabled and the patch above is not applied. I will spend some time on
this two directions this evening. The idea was to get some numbers on
the impact of TCP send window size and tcp_limit_output_bytes for
mvneta. 

The test is done with a laptop (Debian, 3.11.0, e1000e) directly
connected to a RN102 (Marvell Armada 370 @1.2GHz, mvneta). The RN102
is running Debian armhf with an Apache2 serving a 1GB file from ext4
over lvm over RAID1 from 2 WD30EFRX. The client is nothing fancy, i.e.
a simple wget w/ -O /dev/null option.

With the exact same setup on a ReadyNAS Duo v2 (Kirkwood 88f6282
@1.6GHz, mv643xx_eth), I managed to get a throughput of 108MB/s
(cannot remember the kernel version but sth between 3.8 and 3.10.

So with that setup:

w/ TCP send window set to   4MB: 17.4 MB/s
w/ TCP send window set to   2MB: 16.2 MB/s
w/ TCP send window set to   1MB: 15.6 MB/s
w/ TCP send window set to 512KB: 25.6 MB/s
w/ TCP send window set to 256KB: 57.7 MB/s
w/ TCP send window set to 128KB: 54.0 MB/s
w/ TCP send window set to  64KB: 46.2 MB/s
w/ TCP send window set to  32KB: 42.8 MB/s

Then, I started playing w/ tcp_limit_output_bytes (default is 131072),
w/ TCP send window set to 256KB:

tcp_limit_output_bytes set to 512KB: 59.3 MB/s
tcp_limit_output_bytes set to 256KB: 58.5 MB/s
tcp_limit_output_bytes set to 128KB: 56.2 MB/s
tcp_limit_output_bytes set to  64KB: 32.1 MB/s
tcp_limit_output_bytes set to  32KB: 4.76 MB/s

As a side note, during the test, I sometimes gets peak for some seconds
at the beginning at 90MB/s which tend to confirm what WIlly wrote,
i.e. that the hardware can do more.

Cheers,

a+
