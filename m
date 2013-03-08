From: Jason Wang <jasowang@redhat.com>
Subject: TCP small packets throughput and multiqueue virtio-net
Date: Fri, 08 Mar 2013 14:24:10 +0800
Message-ID: <5139840A.6020204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, KVM <kvm@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jpirko@redhat.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all:

I meet an issue when testing multiqueue virtio-net. When I testing guest
small packets stream sending performance with netperf. I find an
regression of multiqueue. When I run 2 sessions of TCP_STREAM test with
1024 byte from guest to local host, I get following result:

1q result: 3457.64
2q result: 7781.45

Statistics shows that: compared with one queue, multiqueue tends to send
much more but smaller packets. Tcpdump shows single queue has a much
higher possibility to produce a 64K gso packet compared to multiqueue.
More but smaller packets will cause more vmexits and interrupts which
lead a degradation on throughput.

Then problem only exist for small packets sending. When I test with
larger size, multiqueue will gradually outperfrom single queue. And
multiqueue also outperfrom in both TCP_RR and pktgen test (even with
small packets). The problem disappear when I turn off both gso and tso.

I'm not sure whether it's a bug or expected since anyway we get
improvement on latency. And if it's a bug, I suspect it was related to
TCP GSO batching algorithm who tends to batch less in this situation. (
Jiri Pirko suspect it was the defect of virtio-net driver, but I didn't
find any obvious clue on this). After some experiments, I find the it
maybe related to tcp_tso_should_defer(), after
1) change the tcp_tso_win_divisor to 1
2) the following changes
the throughput were almost the same (but still a little worse) as single
queue:

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fd0cea1..dedd2a6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1777,10 +1777,12 @@ static bool tcp_tso_should_defer(struct sock
*sk, struct sk_buff *skb)
 
        limit = min(send_win, cong_win);
 
+#if 0
        /* If a full-sized TSO skb can be sent, do it. */
        if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
                           sk->sk_gso_max_segs * tp->mss_cache))
                goto send_now;
+#endif
 
        /* Middle in queue won't get any more data, full sendable
already? */
        if ((skb != tcp_write_queue_tail(sk)) && (limit >= skb->len))

Git history shows this check were added for both westwood and fasttcp,
I'm not familiar with tcp but looks like we can easily hit this check
under when multiqueue is enabled for virtio-net. Maybe I was wrong but I
wonder whether we can still do some batching here.

Any comments, thoughts are welcomed.

Thanks

