From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 10:36:11 -0700
Message-ID: <17082.62219.353794.762348@napali.hpl.hp.com>
References: <20050622180654.GX14251@wotan.suse.de>
	<20050622.132241.21929037.davem@davemloft.net>
	<42B9DA4D.5090103@cosmosbay.com>
	<20050622.152325.15263910.davem@davemloft.net>
	<1119528852.11975.65.camel@localhost.localdomain>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Lennert Buytenhek <buytenh@wantstofly.org>, davidm@hpl.hp.com,
        netdev <netdev@oss.sgi.com>, dada1@cosmosbay.com, ak@suse.de,
        leonid.grossman@neterion.com, becker@scyld.com, rick.jones2@hp.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1119528852.11975.65.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Thu, 23 Jun 2005 08:14:11 -0400, jamal <hadi@cyberus.ca> said:

  Jamal> For the fans of the e1000 (or even the tg3 deprived people),
  Jamal> heres a patch which originated from David Mosberger that i
  Jamal> played around (about 9 months back) - it will need some hand
  Jamal> patching for the latest driver.  Similar approach: prefetch
  Jamal> skb->data,twiddle twiddle not little star, touch header.

  Jamal> I found the aggressive mode effective on a xeon but i belive
  Jamal> David is using this on x86_64. So Lennert, I lied to you
  Jamal> saying it was never effective on x86. You just have to do the
  Jamal> right juju such as factoring in the memory load-latency and
  Jamal> how much cache you have on your specific CPU.  CCing davidm
  Jamal> (in addition To: davem of course ;->) so he may provide more
  Jamal> insight on his tests.

I didn't remember what experiments I did, but I found the original
mail, with all the data.  The experiments were done on ia64 (naturally
;-).

Enjoy,

	--david

---
From: David Mosberger <davidm@linux.hpl.hp.com>
To: hadi@cyberus.ca
Cc: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@davemloft.net>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Lennert Buytenhek <buytenh@wantstofly.org>, davidm@hpl.hp.com,
        eranian@linux.hpl.hp.com, grundler@parisc-linux.org
Subject: Re: prefetch
Date: Thu, 30 Sep 2004 06:51:29 -0700
Reply-To: davidm@hpl.hp.com
X-URL: http://www.hpl.hp.com/personal/David_Mosberger/

>>>>> On 27 Sep 2004 11:08:00 -0400, jamal <hadi@cyberus.ca> said:

  Jamal> one of the top abusers of cpu cycles in the netcode is
  Jamal> eth_type_trans() on x86 type hardware. This is where the
  Jamal> first time the skb->data is touched (hence a cache miss).
  Jamal> Clearly a good place to prefecth is in eth_type_trans itself
  Jamal> maybe right at the top you could prefetch skb->data or after
  Jamal> skb_pull() you could prefetch skb->mac.ethernet.

  Jamal> oprofile shows me the cycles being abused
  Jamal> (GLOBAL_POWER_EVENTS on xeon box) went down when i do either;
  Jamal> i cut down more cycles on doing skb->mac.ethernet that
  Jamal> skb->data - but thats a different topic.

  Jamal> My test is purely forwarding: packets come in through eth0,
  Jamal> get exercised by routing code and come out eth1. So the
  Jamal> important parameters for my test case are primarly throughput
  Jamal> and secondary is latency.  Adding the prefetch above while
  Jamal> showing lower CPU cycles, results in decreeased throughput
  Jamal> numbers and higher latency numbers.  What gives?

  Jamal> I am CCing the HP folks since they have some interesting
  Jamal> tools i heard David talk about at SUCON.

I don't have a good setup to measure packet forwarding performance.
However, prefetching skb->data certainly does reduce CPU utilization
on ia64 as the measurements below show.

I tried three versions:

 - original 2.6.9-rc3 (ORIGINAL)
 - 2.6.9-rc3 with a prefetch in e1000_clean_rx_irq (OBVIOUS)
 - 2.6.9-rc3 which prefetches the _next_ rx buffer (AGGRESSIVE)

All 3 cases use an e1000 board with NAPI enabled.

netperf results for 3 runs of ORIGINAL and AGGRESSIVE:

ORIGINAL:

$ netperf -l30 -c -C -H 192.168.10.15 -- -m1 -D
TCP STREAM TEST to 192.168.10.15 : nodelay
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time   Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.  10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384      1    30.00       1.59   99.93    10.94    5155.593  2257.461
 87380  16384      1    30.00       1.62   99.87    11.19    5045.549  2260.294
 87380  16384      1    30.00       1.62   99.89    11.29    5045.269  2281.327


AGGRESSIVE:

$ netperf -l30 -c -C -H 192.168.10.15 -- -m1 -D
TCP STREAM TEST to 192.168.10.15 : nodelay
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time   Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.  10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384      1    30.00       1.62   99.98    10.51    5062.204  2128.695
 87380  16384      1    30.00       1.62   99.99    10.51    5064.528  2128.940
 87380  16384      1    30.00       1.62   99.98    10.67    5053.365  2156.333

As you can see, not much of a throughput difference (I'd not expect
that, given the test...), but service demand on the receiver is down
significantly.  This is also confirmed with the following three
profiles (collected with q-syscollect):

ORIGINAL:

% time      self     cumul     calls self/call  tot/call name
 53.73     32.05     32.05      471k     68.1u     68.1u default_idle
  4.59      2.74     34.79     12.0M      228n      259n eth_type_trans

OBVIOUS:

% time      self     cumul     calls self/call  tot/call name
 55.72     33.25     33.25      469k     70.8u     70.8u default_idle
  4.49      2.68     35.93     12.0M      222n      278n tcp_v4_rcv
  2.84      1.70     37.63      473k     3.59u     32.6u e1000_clean
  2.81      1.68     39.30     12.2M      137n      525n tcp_rcv_established
  2.71      1.62     40.92     12.1M      134n      711n netif_receive_skb
  2.39      1.43     42.34     12.0M      119n      148n eth_type_trans

AGGRESSIVE:

% time      self     cumul     calls self/call  tot/call name
 57.51     34.34     34.34      395k     86.9u     86.9u default_idle
  4.40      2.62     36.96     12.3M      214n      265n tcp_v4_rcv
  3.12      1.86     38.82      455k     4.09u     31.3u e1000_clean
  3.09      1.84     40.66     12.0M      154n      584n tcp_rcv_established
  2.89      1.72     42.39     12.0M      144n      723n netif_receive_skb
  1.94      1.16     43.55      918k     1.26u     1.26u _spin_unlock_irq
  1.90      1.13     44.68     12.3M     92.4n      115n ip_route_input
  1.87      1.11     45.79     12.6M     88.4n     89.6n kfree
  1.87      1.11     46.91     12.1M     91.8n      572n ip_rcv
  1.68      1.00     47.91     12.1M     82.4n      351n ip_local_deliver
  1.21      0.72     48.63     12.6M     57.7n     58.9n __kmalloc
  1.01      0.60     49.23     12.3M     48.8n     53.7n sba_unmap_single
  1.00      0.59     49.83     12.0M     49.4n     81.0n eth_type_trans

Comparing ORIGINAL and AGGRESSIVE, we see that the latter spends an
additional 2.29 seconds in the idle-loop (default_idle), which
corresponds closely to the 2.19 seconds savings we're seeing in
eth_type_trans(), so the saving the prefetch achieves is real and not
offset by extra costs in other places.

The above also shows that the OBVIOUS prefetch is unable to cover the
entire load-latency.  Thus, I suspect it would really be best to use
the AGGRESSIVE prefetching policy.  If we were to do this, then the
code at label next_desc could be simplified, since we already
precomputed the next value of i/rx_desc as part of the prefetch.

It would be interesting to know how (modern) x86 CPUs behave.  If
somebody wants to try this, I attached a patch below (setting
AGGRESSIVE to 1 gives you the AGGRESSIVE version, seting it to 0 gives
you the OBVIOUS version).

Cheers,

	--david

===== drivers/net/e1000/e1000_main.c 1.134 vs edited =====
--- 1.134/drivers/net/e1000/e1000_main.c	2004-09-12 16:52:48 -07:00
+++ edited/drivers/net/e1000/e1000_main.c	2004-09-30 06:05:11 -07:00
@@ -2278,12 +2278,30 @@
 	uint8_t last_byte;
 	unsigned int i;
 	boolean_t cleaned = FALSE;
+#define AGGRESSIVE 1
 
 	i = rx_ring->next_to_clean;
+#if AGGRESSIVE
+	prefetch(rx_ring->buffer_info[i].skb->data);
+#endif
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
 
 	while(rx_desc->status & E1000_RXD_STAT_DD) {
 		buffer_info = &rx_ring->buffer_info[i];
+# if AGGRESSIVE
+		{
+			struct e1000_rx_desc *next_rx;
+			unsigned int j = i + 1;
+
+			if (j == rx_ring->count)
+				j = 0;
+			next_rx = E1000_RX_DESC(*rx_ring, j);
+			if (next_rx->status & E1000_RXD_STAT_DD)
+				prefetch(rx_ring->buffer_info[j].skb->data);
+		}
+# else
+		prefetch(buffer_info->skb->data);
+# endif
 #ifdef CONFIG_E1000_NAPI
 		if(*work_done >= work_to_do)
 			break;
