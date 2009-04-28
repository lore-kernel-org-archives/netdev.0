From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 11:44:52 -0400
Message-ID: <49F72474.20506@myri.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760557AbZD1Ppo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 11:45:44 -0400
In-Reply-To: <20090428152047.GB7549@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
 > On Tue, Apr 28, 2009 at 11:00:16AM -0400, Andrew Gallatin wrote:
 >> Its strange, I still consistently see about 1Gb/s better performance
 >> from LRO than GRO on this weak machine (6.5Gb/s LRO, 5.5Gb/s GRO)
 >> when binding everything to the same CPU. Mpstat -P 0 shows roughly
 >> 10% more time spent in "soft" when using GRO vs LRO:
 >
 > Did you check the utilisation of the all the cores on the sender?

Yes.  It is about the same +/- 2%.  The utilization when sending
to GRO is a bit lower, but its going slower.

Here is what might be more interesting.. I'm trying to isolate the
softirq path in oprofile.  So in this test, I bound the IRQ to CPU1,
and the netserver to CPU0.  In these tests, I see near line rate from
both LRO and GRO.  Here is oprofile output separated by CPU, and
sorted on CPU1.  (Sorry about binding to CPU1 and making the output
more confusing; I could not get oprofile to emit samples when the irq
was bound to CPU0).  I've included the top 20 entries:

GRO:
0              0  1414     15.8485  myri10ge.ko              myri10ge 
               myri10ge_poll
0              0  932      10.4461  vmlinux                  vmlinux 
               inet_gro_receive
0              0  705       7.9018  vmlinux                  vmlinux 
               tcp_gro_receive
0              0  681       7.6328  vmlinux                  vmlinux 
               skb_gro_receive
0              0  652       7.3078  vmlinux                  vmlinux 
               skb_gro_header
0              0  517       5.7947  vmlinux                  vmlinux 
               __napi_gro_receive
0              0  316       3.5418  vmlinux                  vmlinux 
               dev_gro_receive
0              0  309       3.4633  myri10ge.ko              myri10ge 
               myri10ge_alloc_rx_pages
415       3.1243  251       2.8133  vmlinux                  vmlinux 
               _raw_spin_lock
0              0  233       2.6115  vmlinux                  vmlinux 
               napi_frags_skb
0              0  178       1.9951  vmlinux                  vmlinux 
               tcp4_gro_receive
306       2.3037  152       1.7037  vmlinux                  vmlinux 
               rb_get_reader_page
0              0  150       1.6812  vmlinux                  vmlinux 
               napi_get_frags
188       1.4153  131       1.4683  vmlinux                  vmlinux 
               rb_buffer_peek
195       1.4680  101       1.1320  vmlinux                  vmlinux 
               ring_buffer_consume
0              0  96        1.0760  vmlinux                  vmlinux 
               ip_rcv_finish
0              0  94        1.0536  vmlinux                  vmlinux 
               napi_gro_frags
0              0  92        1.0312  vmlinux                  vmlinux 
               skb_copy_bits
0              0  86        0.9639  vmlinux                  vmlinux 
               napi_frags_finish
225       1.6939  85        0.9527  oprofile.ko              oprofile 
               op_cpu_buffer_read_entry

LRO:
0              0  1937     15.1281  myri10ge.ko              myri10ge 
               myri10ge_poll
0              0  1876     14.6517  myri10ge.ko              myri10ge 
               myri10ge_get_frag_header
0              0  943       7.3649  vmlinux                  vmlinux 
               __lro_proc_segment
0              0  723       5.6467  myri10ge.ko              myri10ge 
               myri10ge_alloc_rx_pages
0              0  392       3.0615  vmlinux                  vmlinux 
               lro_gen_skb
0              0  369       2.8819  vmlinux                  vmlinux 
               lro_tcp_ip_check
353       2.7435  357       2.7882  vmlinux                  vmlinux 
               _raw_spin_lock
290       2.2538  328       2.5617  vmlinux                  vmlinux 
               rb_get_reader_page
4         0.0311  270       2.1087  vmlinux                  vmlinux 
               csum_partial
26        0.2021  214       1.6714  vmlinux                  vmlinux 
               memset_c
0              0  202       1.5776  vmlinux                  vmlinux 
               lro_add_common
8         0.0622  191       1.4917  vmlinux                  vmlinux 
               __slab_alloc
0              0  188       1.4683  vmlinux                  vmlinux 
               ip_rcv_finish
84        0.6528  183       1.4292  vmlinux                  vmlinux 
               _raw_spin_unlock
0              0  180       1.4058  vmlinux                  vmlinux 
               lro_tcp_data_csum
0              0  180       1.4058  vmlinux                  vmlinux 
               lro_get_desc
167       1.2979  178       1.3902  vmlinux                  vmlinux 
               ring_buffer_consume
0              0  167       1.3043  vmlinux                  vmlinux 
               netif_receive_skb
0              0  143       1.1168  vmlinux                  vmlinux 
               ip_route_input
0              0  125       0.9763  vmlinux                  vmlinux 
               __inet_lookup_established



Does anything strike you as being inordinately expensive for GRO?

Drew
