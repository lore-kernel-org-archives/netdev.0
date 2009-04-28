From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 11:00:16 -0400
Message-ID: <49F71A00.5090701@myri.com>
References: <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761518AbZD1PBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 11:01:18 -0400
In-Reply-To: <20090428061225.GA1591@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
 > On Mon, Apr 27, 2009 at 04:05:01PM +0800, Herbert Xu wrote:
 >> On Fri, Apr 24, 2009 at 12:16:08PM -0400, Andrew Gallatin wrote:
 >>> These results are indeed quite close, so the performance problem seems
 >>> isolated to AMD CPUS, and perhaps due to the smaller caches.
 >>> Do you have any AMD you can use as a receiver?
 >> I now have an AMD with 512K cache to test this.  Unfortunately
 >> I'd just locked it up before I got a chance to do any serious
 >> testing.  So it might take a while.
 >
 > OK that's been fixed up.  Indeed the AMD can't do wire speed.
 > But still the performance seems comparable.  Both of them sit
 > between 6600Mb/s and 7100Mb/s.  The sender is running at about
 > 66% idle in either case.

Its strange, I still consistently see about 1Gb/s better performance
from LRO than GRO on this weak machine (6.5Gb/s LRO, 5.5Gb/s GRO)
when binding everything to the same CPU. Mpstat -P 0 shows roughly
10% more time spent in "soft" when using GRO vs LRO:

GRO:
  10:17:45     CPU   %user   %nice %system %iowait    %irq   %soft 
%idle    intr/s
10:17:46       0    0.00    0.00   54.00    0.00    0.00   46.00    0.00 
  11754.00
10:17:47       0    0.00    0.00   54.00    0.00    1.00   45.00    0.00 
  11718.00
10:17:48       0    0.00    0.00   47.00    0.00    2.00   51.00    0.00 
  11639.00


LRO:
10:21:55     CPU   %user   %nice %system %iowait    %irq   %soft   %idle 
    intr/s
10:21:56       0    0.00    0.00   66.00    0.00    1.00   33.00    0.00 
  13228.00
10:21:57       0    0.00    0.00   65.35    0.00    1.98   32.67    0.00 
  13118.81
10:21:58       0    0.00    0.00   63.00    0.00    1.00   36.00    0.00 
  13238.00


According to oprofile, the top 20 samples running GRO are:
CPU: AMD64 processors, speed 2050.03 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a 
unit mask of 0x00 (No unit mask) count 100000
samples  %        image name               app name 
symbol name
4382     30.5408  vmlinux                  vmlinux 
copy_user_generic_string
534       3.7218  myri10ge.ko              myri10ge 
myri10ge_poll
463       3.2269  vmlinux                  vmlinux 
_raw_spin_lock
394       2.7460  vmlinux                  vmlinux 
rb_get_reader_page
382       2.6624  vmlinux                  vmlinux 
acpi_pm_read
356       2.4812  vmlinux                  vmlinux 
inet_gro_receive
293       2.0421  oprofiled                oprofiled                (no 
symbols)
268       1.8679  vmlinux                  vmlinux 
find_next_bit
268       1.8679  vmlinux                  vmlinux 
tg_shares_up
257       1.7912  vmlinux                  vmlinux 
ring_buffer_consume
247       1.7215  myri10ge.ko              myri10ge 
myri10ge_alloc_rx_pages
247       1.7215  vmlinux                  vmlinux 
tcp_gro_receive
228       1.5891  vmlinux                  vmlinux 
__free_pages_ok
219       1.5263  vmlinux                  vmlinux 
skb_gro_receive
167       1.1639  vmlinux                  vmlinux 
skb_gro_header
149       1.0385  bash                     bash                     (no 
symbols)
141       0.9827  vmlinux                  vmlinux 
skb_copy_datagram_iovec
132       0.9200  vmlinux                  vmlinux 
rb_buffer_peek
129       0.8991  vmlinux                  vmlinux 
_raw_spin_unlock
123       0.8573  vmlinux                  vmlinux 
delay_tsc

Nothing really stands out for me.  Here is LRO:


Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a 
unit mask of 0x00 (No unit mask) count 100000
samples  %        image name               app name 
symbol name
4884     33.1164  vmlinux                  vmlinux 
copy_user_generic_string
721       4.8888  myri10ge.ko              myri10ge 
myri10ge_poll
580       3.9327  vmlinux                  vmlinux 
_raw_spin_lock
409       2.7733  vmlinux                  vmlinux 
acpi_pm_read
306       2.0749  vmlinux                  vmlinux 
rb_get_reader_page
293       1.9867  oprofiled                oprofiled                (no 
symbols)
286       1.9392  myri10ge.ko              myri10ge 
myri10ge_get_frag_header
253       1.7155  vmlinux                  vmlinux 
__lro_proc_segment
250       1.6951  vmlinux                  vmlinux 
rb_buffer_peek
247       1.6748  vmlinux                  vmlinux 
ring_buffer_consume
232       1.5731  vmlinux                  vmlinux 
__free_pages_ok
211       1.4307  myri10ge.ko              myri10ge 
myri10ge_alloc_rx_pages
206       1.3968  vmlinux                  vmlinux 
tg_shares_up
175       1.1866  vmlinux                  vmlinux 
skb_copy_datagram_iovec
158       1.0713  vmlinux                  vmlinux 
find_next_bit
146       0.9900  vmlinux                  vmlinux 
lro_tcp_ip_check
131       0.8883  oprofile.ko              oprofile 
op_cpu_buffer_read_entry
127       0.8611  vmlinux                  vmlinux 
delay_tsc
125       0.8476  bash                     bash                     (no 
symbols)
125       0.8476  vmlinux                  vmlinux 
_raw_spin_unlock


If I can't figure out why LRO is so much faster in some cases, then I
think maybe I'll just put together a patch which keeps LRO, and does
GRO only if LRO is disabled.  Kind of ugly, but better than loosing
15% performance on some machines.

Drew
