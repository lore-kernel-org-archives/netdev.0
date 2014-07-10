From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: Re: RSS is not efficient when forwarding (ixgbe)
Date: Wed, 9 Jul 2014 21:08:27 -0300
Message-ID: <21437.55675.61176.767736@fisica.ufpr.br>
References: <20140703224408.GA2343@t520.home>
	<20140704193644.GB2343@t520.home>
	<CA+mtBx-dY2eoDzL-1K8F8Br224H+c4fzVtVPu9JmnjLdQKuAOg@mail.gmail.com>
	<20140707105523.GC2343@t520.home>
	<F6FB0E698C9B3143BDF729DF2228664685DCFE12@ORSMSX110.amr.corp.intel.com>
	<20140708002837.GS2346@t520.home>
	<21436.9657.845209.575715@fisica.ufpr.br>
	<20140708172127.GV2346@t520.home>
	<21436.11067.667194.899369@fisica.ufpr.br>
	<20140709052205.GW2346@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Skidmore\, Donald C" <donald.c.skidmore@intel.com>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:37900 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948AbaGJAI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 20:08:29 -0400
In-Reply-To: <20140709052205.GW2346@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner (fbl@redhat.com) wrote on 9 July 2014 02:22:
 >On Tue, Jul 08, 2014 at 02:32:43PM -0300, Carlos Carvalho wrote:
 >> Flavio Leitner (fbl@redhat.com) wrote on 8 July 2014 14:21:
 >>  >On Tue, Jul 08, 2014 at 02:09:13PM -0300, Carlos Carvalho wrote:
 >>  >> Flavio Leitner (fbl@redhat.com) wrote on 7 July 2014 21:28:
 >>  >>  >On Mon, Jul 07, 2014 at 04:33:24PM +0000, Skidmore, Donald C wrote:
 >>  >>  >> 
 >>  >>  >> 
 >>  >>  >> > 
 >>  >>  >> > It's a router forwarding traffic from one interface to another, so I guess it's
 >>  >>  >> > only the kernel. BTW, no firewall.
 >>  >>  >> > 
 >>  >>  >> > Flow Director needs to be enabled and I am using defaults.
 >>  >>  >> 
 >>  >>  >> Flow Director in ATR mode is on by default for ixgbe.  So like Tom mentioned the driver will create hash buckets for egress packets.  You could try disabling ATR and just use RSS.  Which would probably be the right thing to do any way since Flow Director isn't very useful for routing scenarios.  
 >>  >>  >
 >>  >>  >That was it.
 >>  >> 
 >>  >> We have a similar setup and similar problem. How do we disable ATR? I
 >>  >> tried to set ntuple off but this almost zeroed traffic. I also tried
 >>  >> to change rx-flow-hash but ethtool says it's not possible. The docs
 >>  >> say that one can disable ATR by setting AtrSampleRate to 0 but this
 >>  >> parameter doesn't exist in 3.14.10.
 >>  >> 
 >>  >> So, how do we disable ATR and keep RSS?
 >>  > 
 >>  >Keep in mind that this is actually 2 problems. One is enabling the
 >>  >NIC to receive the streams in all queues for this scenario (setting
 >>  >ntuple off and restarting the traffic works for me). The second problem
 >>  >is having all the queue interrupts spread among the CPUs. That's what
 >>  >does irqbalance, tuna, etc...
 >> 
 >> Spreading the interrupts among the cpus is not the issue for us. The
 >> problem is that the number of interrupts is *very* different among the
 >> irq's, so no matter how I distribute them among cores there will
 >> always be a few that get saturated while 70% of the machine capacity
 >> remains idle. Your case seems to be the extreme of ours, where all
 >> the flux goes to a single irq.
 >> 
 >> The problem is in how the NIC distributes traffic among the irq's in
 >> the router. Traffic comes almost only from a single machine and
 >> spreads through several thousand destinations in the internet. That's
 >> why I tried to set the receiving hash mode to the destination IP, but
 >> the NIC or driver refuses. So how do I even out the frequency of irq's?
 >
 >So you see the traffic going to a few queues only and the rest is
 >idle, is that correct?  If so, then RSS seems to be working, but
 >since all the traffic comes from one server and likely one port,
 >maybe the hash is not good enough to distribute among all queues.
 >I'd try using software hashing instead of hw hashing to see if it
 >helps:
 ># ethtool -K <iface> rxhash off

I'm all for using software instead of hardware. However, in this case
this is a fundamental function of the NIC, to distribute the load
among cores; if we do it via software, a single core (or subset of
them) will have to do all the work. So in this particular case I think
the correct way is to try to do it in the NIC.

 >BTW, there was a typo in my previous post, I had to turn on ntuple to
 >disable ATR.

Ah. Here it was off by default, which contradicts what Donald said
above... I turned it on, and nothing changed(?!). The nic was reset
but the distribution among queues is the same.

I checked now and in fact the distribution is almost constant among
16 IRQ's. That's the problem, because it leaves the other 24
cores idle. Not completely, but the difference is 4 orders of
magnitude: 5.41e+08 interruptions in the active 16 IRQ's versus
6.36e+04 in the others. So 60% of the machine is just contributing to
global warming and, importantly, limiting our performance :-(

Is there a configuration that expands the used IRQ's?
