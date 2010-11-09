From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 15:16:18 +0100
Message-ID: <1289312178.17448.20.camel@traveldev.cxnet.dk>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:52525 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0KIOQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 09:16:21 -0500
In-Reply-To: <1289311159.17448.9.camel@traveldev.cxnet.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-09 at 14:59 +0100, Jesper Dangaard Brouer wrote:
> On Mon, 2010-11-08 at 16:06 +0100, Eric Dumazet wrote:
> ...
> > > > > > I noticed that the loopback performance has gotten quite bad:
> > > > > > 
> > > > > > http://www.phoronix.com/scan.php?page=article&item=linux_2612_2637&num=6

> > Their network test is basically :
> > 
> > netcat -l 9999 >/dev/null &
> > time dd if=/dev/zero bs=1M count=10000 | netcat  127.0.0.1 9999
> 
> Should it not be:
>  netcat -l -p 9999 >/dev/null &
> 
> When I run the commands "dd | netcat", netcat never finish/exits, I have
> to press Ctrl-C to stop it.  What am I doing wrong? Any tricks?

To fix this I added "-q 0" to netcat.  Thus my working commands are:

 netcat -l -p 9999 >/dev/null &
 time dd if=/dev/zero bs=1M count=10000 | netcat -q0 127.0.0.1 9999

Running this on my "big" 10G testlab system, Dual Xeon 5550 2.67GHz,
kernel version 2.6.32-5-amd64 (which I usually don't use)
The results are 7.487 sec:

time dd if=/dev/zero bs=1M count=10000 | netcat -q0 127.0.0.1 9999
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB) copied, 7,48562 s, 1,4 GB/s

real    0m7.487s
user    0m0.224s
sys     0m9.785s

Using vmstat I see approx 400000 context switches per sec.

Perf top says:
            samples  pcnt function                  DSO
             _______ _____ _________________________ ___________

             6442.00 16.3% copy_user_generic_string  [kernel]   
             2226.00  5.6% __clear_user              [kernel]   
              912.00  2.3% _spin_lock_irqsave        [kernel]   
              773.00  2.0% _spin_lock_bh             [kernel]   
              736.00  1.9% schedule                  [kernel]   
              582.00  1.5% ipt_do_table              [ip_tables]
              569.00  1.4% _spin_lock                [kernel]   
              505.00  1.3% get_page_from_freelist    [kernel]   
              451.00  1.1% _spin_unlock_irqrestore   [kernel]   
              434.00  1.1% do_select                 [kernel]   
              354.00  0.9% tcp_sendmsg               [kernel]   
              348.00  0.9% tick_nohz_stop_sched_tick [kernel]   
              347.00  0.9% tcp_transmit_skb          [kernel]   
              345.00  0.9% zero_fd_set               [kernel]   

Perf also complains about it cannot resolve netcat debug symbols.


-- 
Jesper Dangaard Brouer
ComX Networks A/S

