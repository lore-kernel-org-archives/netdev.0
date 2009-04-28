From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 17:12:20 -0400
Message-ID: <49F77134.9030907@myri.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2023 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757947AbZD1VNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 17:13:18 -0400
In-Reply-To: <20090428152047.GB7549@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For variety, I grabbed a different "slow" receiver.  This is another
2 CPU machine, but a dual-socket single-core opteron (Tyan S2895)

processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 37
model name      : AMD Opteron(tm) Processor 252
stepping        : 1
cpu MHz         : 2611.738
cache size      : 1024 KB
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt 
lm 3dnowext 3dnow rep_good pni lahf_lm
bogomips        : 5223.47
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp

The sender was an identical machine running an ancient RHEL4 kernel
(2.6.9-42.ELsmp) and our downloadable (backported) driver.
(http://www.myri.com/ftp/pub/Myri10GE/myri10ge-linux.1.4.4.tgz)
I disabled LRO, on the sender.

Binding the IRQ to CPU0, and the netserver to CPU1 I see 8.1Gb/s with
LRO and 8.0Gb/s with GRO.

Binding the IRQ to CPU0, and the netserver to CPU0, I see 6.9Gb/s
with LRO and 5.5 Gb/s with GRO.  Monitoring the packet/byte counts
on the interface once per second, LRO looks like this:

        Ipkts       IBytes        Opkts       Obytes
       588992    891733888         9758       644028
       589610    892669540         9771       644886
       589079    891865606         9754       643764

And GRO looks like this:

       480309    727187826         7949       524634
       480032    726768448         7947       524502
       480000    726720000         7943       524238


Similarly, in this same scenario, binding the app/irq to the same
CPU and running mpstat -P 0 1 shows about 60%sys and 40% irq+softirq
while GRO shows about 45% sys and 55% irq+softirq.

I can't put my finger on it, but something about GRO is certainly
more expensive on these types of machines.  I wish there was some
way you could see it, since it happens on every older AMD I try
it on.  If you haven't been able to reproduce it, I'll see if I
can make it happen on a newer "slow" amd64 box I have tomorrow.


Drew
