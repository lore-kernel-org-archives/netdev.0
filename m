From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 05:53:14 -0800
Message-ID: <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
	 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	 <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87li0kkhzx.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:65470 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3KSNxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 08:53:09 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb1so8346858pad.38
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 05:53:09 -0800 (PST)
In-Reply-To: <87li0kkhzx.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-19 at 07:44 +0100, Arnaud Ebalard wrote:

> I did some test regarding mvneta perf on current linus tree (commit
> 2d3c627502f2a9b0, w/ c9eeec26e32e "tcp: TSQ can use a dynamic limit"
> reverted). It has Simon's tclk patch for mvebu (1022c75f5abd, "clk:
> armada-370: fix tclk frequencies"). Kernel has some debug options
> enabled and the patch above is not applied. I will spend some time on
> this two directions this evening. The idea was to get some numbers on
> the impact of TCP send window size and tcp_limit_output_bytes for
> mvneta.

Note the last patch I sent was not relevant to your problem, do not
bother trying it. Its useful for applications doing lot of consecutive
short writes, like interactive ssh launching line buffered commands.

>  
> 
> The test is done with a laptop (Debian, 3.11.0, e1000e) directly
> connected to a RN102 (Marvell Armada 370 @1.2GHz, mvneta). The RN102
> is running Debian armhf with an Apache2 serving a 1GB file from ext4
> over lvm over RAID1 from 2 WD30EFRX. The client is nothing fancy, i.e.
> a simple wget w/ -O /dev/null option.
> 
> With the exact same setup on a ReadyNAS Duo v2 (Kirkwood 88f6282
> @1.6GHz, mv643xx_eth), I managed to get a throughput of 108MB/s
> (cannot remember the kernel version but sth between 3.8 and 3.10.
> 
> So with that setup:
> 
> w/ TCP send window set to   4MB: 17.4 MB/s
> w/ TCP send window set to   2MB: 16.2 MB/s
> w/ TCP send window set to   1MB: 15.6 MB/s
> w/ TCP send window set to 512KB: 25.6 MB/s
> w/ TCP send window set to 256KB: 57.7 MB/s
> w/ TCP send window set to 128KB: 54.0 MB/s
> w/ TCP send window set to  64KB: 46.2 MB/s
> w/ TCP send window set to  32KB: 42.8 MB/s

One of the problem is that tcp_sendmsg() holds the socket lock for the
whole duration of the system call if it has not to sleep. This model
doesnt allow for incoming ACKS to be processed (they are put in socket
backlog and will be processed at socket release time), and TX completion
to also queue the next chunk.

These strange results you have tend to show that if you have a big TCP
send window, the web server pushes a lot of bytes per system call and
might stall the ACK clocking or TX refills.

> 
> Then, I started playing w/ tcp_limit_output_bytes (default is 131072),
> w/ TCP send window set to 256KB:
> 
> tcp_limit_output_bytes set to 512KB: 59.3 MB/s
> tcp_limit_output_bytes set to 256KB: 58.5 MB/s
> tcp_limit_output_bytes set to 128KB: 56.2 MB/s
> tcp_limit_output_bytes set to  64KB: 32.1 MB/s
> tcp_limit_output_bytes set to  32KB: 4.76 MB/s
> 
> As a side note, during the test, I sometimes gets peak for some seconds
> at the beginning at 90MB/s which tend to confirm what WIlly wrote,
> i.e. that the hardware can do more.

I would also check the receiver. I suspect packets drops because of a
bad driver doing skb->truesize overshooting.

nstat >/dev/null ; wget .... ; nstat
