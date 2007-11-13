From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Wed, 14 Nov 2007 09:27:39 +1100
Message-ID: <200711140927.39796.nickpiggin@yahoo.com.au>
References: <200711140436.24492.nickpiggin@yahoo.com.au> <200711140514.28159.nickpiggin@yahoo.com.au> <20071113.223726.40898879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_bTiOHHaIT3a5fkw"
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.mail.mud.yahoo.com ([209.191.85.211]:30388 "HELO
	smtp101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751684AbXKNKaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 05:30:35 -0500
In-Reply-To: <20071113.223726.40898879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_bTiOHHaIT3a5fkw
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 14 November 2007 17:37, David Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>

> > I'm doing some oprofile runs now to see if I can get any more info.

OK, in vanilla kernels, the page allocator definitely shows higher
in the results (than with Herbert's patch reverted).

27516     2.7217  get_page_from_freelist                                        
21677     2.1442  __rmqueue_smallest                                            
20513     2.0290  __free_pages_ok                                               
18725     1.8522  get_pageblock_flags_group             

Just these account for nearly 10% of cycles. __alloc_skb shows up
higher too. free_hot_cold_page() shows a lot lower though, which
might indicate that actually there is more higher order allocation
activity (I'll check that next).

****
SLUB, avg throughput 1548

CPU: AMD64 family10, speed 1900 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit 
mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
94636     9.3609  copy_user_generic_string
38932     3.8509  ipt_do_table
34746     3.4369  tcp_v4_rcv
29539     2.9218  skb_release_data
27516     2.7217  get_page_from_freelist
26046     2.5763  tcp_sendmsg
24482     2.4216  local_bh_enable
22910     2.2661  ip_queue_xmit
22113     2.1873  ktime_get
21677     2.1442  __rmqueue_smallest
20513     2.0290  __free_pages_ok
18725     1.8522  get_pageblock_flags_group
18580     1.8378  tcp_recvmsg
18108     1.7911  __napi_schedule
17593     1.7402  schedule
16998     1.6813  tcp_ack
16102     1.5927  dev_hard_start_xmit
15751     1.5580  system_call
15707     1.5536  net_rx_action
15150     1.4986  __switch_to
14988     1.4825  tcp_transmit_skb
13921     1.3770  kmem_cache_free
13398     1.3253  __mod_timer
13243     1.3099  tcp_rcv_established
13109     1.2967  __tcp_select_window
11022     1.0902  __tcp_push_pending_frames
10732     1.0615  set_normalized_timespec
10561     1.0446  netif_rx
8840      0.8744  netif_receive_skb
7816      0.7731  nf_iterate
7300      0.7221  __update_rq_clock
6683      0.6610  _read_lock_bh
6504      0.6433  sys_recvfrom
6283      0.6215  nf_hook_slow
6188      0.6121  release_sock
6172      0.6105  loopback_xmit
5927      0.5863  __alloc_skb
5707      0.5645  tcp_cleanup_rbuf
5538      0.5478  tcp_event_data_recv
5517      0.5457  tcp_v4_do_rcv
5516      0.5456  process_backlog
****
SLUB, net patch reverted. Avg throughput 1933MB/s
Counted CPU_CLK_UNHALTED , count 100000
samples  %        symbol name
95895     9.5094  copy_user_generic_string
50259     4.9839  ipt_do_table
39408     3.9079  skb_release_data
37296     3.6984  tcp_v4_rcv
31309     3.1047  ip_queue_xmit
31308     3.1046  local_bh_enable
24052     2.3851  net_rx_action
23786     2.3587  __napi_schedule
21426     2.1247  tcp_recvmsg
21075     2.0899  schedule
20938     2.0763  dev_hard_start_xmit
20222     2.0053  tcp_sendmsg
19775     1.9610  tcp_ack
19717     1.9552  system_call
19495     1.9332  set_normalized_timespec
18584     1.8429  __switch_to
17022     1.6880  tcp_rcv_established
14655     1.4533  tcp_transmit_skb
14466     1.4345  __mod_timer
13820     1.3705  loopback_xmit
13776     1.3661  get_page_from_freelist
13288     1.3177  netif_receive_skb
9718      0.9637  _read_lock_bh
9625      0.9545  nf_iterate
9440      0.9361  netif_rx
9148      0.9072  free_hot_cold_page
8633      0.8561  __update_rq_clock
7668      0.7604  sys_recvfrom
7578      0.7515  __tcp_push_pending_frames
7311      0.7250  find_pid_ns
7178      0.7118  nf_hook_slow
6655      0.6599  sysret_check
6313      0.6260  release_sock
6290      0.6237  tcp_cleanup_rbuf
6263      0.6211  __tcp_select_window
6235      0.6183  process_backlog
5920      0.5871  ip_local_deliver_finish
5651      0.5604  ip_rcv
5239      0.5195  ip_finish_output
5058      0.5016  kmem_cache_free
5016      0.4974  thread_return


> Here are some other things you can play around with:
>
> 1) Monitor the values of skb->len and skb->data_len for packets
>    going over loopback.

OK, I've taken a log2 histogram of ->len and ->data_len sizes.
I'll attach the plots (xaxis is byte value of most significant
bit set, y axis is number of occurances, logscale on X so 0 isn't
there :( ). If you want to see the patch or raw data, let me know.

len looks very similar for both kernels, although the reverted
kernel has significantly higher frequency at most points. tbench
unfortunately is only possible to do it time-based, so this is
rougly expected.

data_len has a spike that shifts up to 512-1023, from 256-511,
when reverting Herbert's patch. Again, I believe the magnitudes
of the spikes should actually be pretty close if we were doing
an equal amount of work.

I can't see that these numbers show much useful, unfortunately.


> 2) Try removing NETIF_F_SG in drivers/net/loopback.c's dev->feastures
>    setting.

Will try that now.

--Boundary-00=_bTiOHHaIT3a5fkw
Content-Type: image/png;
  name="data.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="data.png"

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

--Boundary-00=_bTiOHHaIT3a5fkw
Content-Type: image/png;
  name="len.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="len.png"

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

--Boundary-00=_bTiOHHaIT3a5fkw--
