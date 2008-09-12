From: David Miller <davem@davemloft.net>
Subject: Re: UDP and Raw packet output not scaling with number of cores
 (10G, ixgbe and bnx2x)
Date: Thu, 11 Sep 2008 20:34:50 -0700 (PDT)
Message-ID: <20080911.203450.29338239.davem@davemloft.net>
References: <C499405203244F4F8ECC637C6A8F498B07D8E9ED@sd-exchange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: wurzel@ccpu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752087AbYILDe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:34:56 -0400
In-Reply-To: <C499405203244F4F8ECC637C6A8F498B07D8E9ED@sd-exchange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "wurzel parsons-keir" <wurzel@ccpu.com>
Date: Thu, 11 Sep 2008 20:21:36 -0700

[ netdev is where networking developers live, not linux-net,
  added to CC: ]

> I have a dual-Harpertown box here with Intel and Broadcom 10G NICs.
> I'm trying to get my tx packet rate (either UDP or raw packets)
> over 330,000 packets/second (like 600kpps would be great) but
> I'm not seeing the kind of scaling I would expect.  
> 
> I'm not trying to do anything fancy with QOS or egress rates; basically 
> I just want a program that does
> 	fd = socket()   // either UDP or Raw
>       while (1)  send(fd, buf, 1024)
> to send a many packets as possible.  And if I run two instances of that 
> program, I'd expect to see 1.5-2 times as many packets go out.  Instead
> I'm seeing a slight decrease in packet rate as I add more transmit
> processes (or add more threads in another pthread version of the same
> program).  I'm verifying the actual number of packets transmitted
> with a SmartBits, and it confirms the number of packets my program
> claims it is sending.  Is anyone out there getting significantly better
> packet rates on 10G hardware?
> 
> I read posts from Dave Miller from July 3 about making the tx path 
> multiqueue aware, and also a paper by Zhu Yi and another by Redhat 
> on how all this should make the TX path totally parallel/scalable 
> across my 8 cores, if I understand correctly.
> 
> So I cloned DaveM's net-next-2.6.git and got the latest iproute tools
> and I'm still not seeing any scaling in the TX path.
> 
> When I look at /proc/interrupts, it looks like sending UDP packets
> is making use of the multiple TX queues.  When I send raw packets,
> all of the interrupts chalk up against a single TX queue, so they
> seem to behave differently.
> 
> [root@ATXbox wurzel]# grep eth3 /proc/interrupts
> 2262:          0          0          0          0          0          0
> 0          0   PCI-MSI-edge      eth3:lsc
> 2263:       7716       7550       7463       7705       7631       7626
> 7641       7613   PCI-MSI-edge      eth3:v15-Tx
> 2264:      22340      22458      22032      22206      22062      22187
> 22068      22308   PCI-MSI-edge      eth3:v14-Tx
> 2265:      26367      26530      26563      26541      26658      26449
> 26677      26403   PCI-MSI-edge      eth3:v13-Tx
> 2266:      21365      21567      21041      21213      21418      21251
> 21304      21571   PCI-MSI-edge      eth3:v12-Tx
> 2267:      11455      11599      11492      11439      11616      11487
> 11756      11458   PCI-MSI-edge      eth3:v11-Tx
> 2268:      24506      24374      24475      24220      24128      24447
> 24336      24181   PCI-MSI-edge      eth3:v10-Tx
> 2269:       5325       5177       5248       5170       5309       5287
> 5196       5102   PCI-MSI-edge      eth3:v9-Tx
> 2270:      91019      90886      91388      91214      91104      91082
> 91329      91284   PCI-MSI-edge      eth3:v8-Tx
> 
> ------------------------------
> 
> [root@ATXbox ~]# ~/bin/tc qdisc show
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1
> 1 1 1 1 1
> qdisc pfifo_fast 0: dev eth3 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1
> 1 1 1 1 1
> 
> Previous versions of Documentation/networking/multiqueue.txt mentioned
> a round robin scheduler, but I don't see evidence of that any more.
> 
> Any pointers you can provide would be greatly helpful.  If there's
> any other information I can gather to help you understand
> what I'm doing, please let me know.
> 
> [root@ATXbox net-next-2.6]# cat /proc/version
> Linux version 2.6.27-rc5 (root@ATXbox) (gcc version 4.3.0 20080428 (Red
> Hat 4.3.0-8) (GCC) ) #1 SMP Thu Sep 11 23:29:57 EDT 2008
> 
> (Although this shows 2.6.27-rc5, it was built from a directory obtained
> by
>   git clone
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> just this afternoon)
> 
> I'm relatively new to Git, so if I'm simply not building the right code,
> 
> let me know.  However, I FTP'd in and don't see the net-tx-2.6.git in
> DaveM's
> directory any more, so can I assume it got merged to net-next-2.6
> already?
> 
> 							Many thanks,
> 								-wurzel
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
