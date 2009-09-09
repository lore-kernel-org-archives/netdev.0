From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: questions / potential bug: e1000e and tx delay setting in msi-x
 mode
Date: Wed, 9 Sep 2009 14:59:14 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0909091445050.5356@jbrandeb-desk1.amr.corp.intel.com>
References: <4AA80CEE.5030704@ziu.info>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23196 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbZIIV7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 17:59:13 -0400
In-Reply-To: <4AA80CEE.5030704@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I CCd the maintainers list, which since you are talking about the out of 
tree driver (I think) is probably more appropriate for future postings.

On Wed, 9 Sep 2009, Michal Soltys wrote:

> While experimenting a bit with intel PRO/1000 CT nic (reported by lspci as Intel 
> Corporation 82574L Gigabit Network Connection), I noticed following issues (?):
> 
> 1) under default IntMode (MSI-X), TxAbsIntDelay doesn't seem to limit interrupt 
> rate (as seen via /proc/interrupts), although it is capped by InterruptThrottleRate 
> (or not at all, if this one is disabled).

Tx[Abs]IntDelay is not meant to work when MSI-X mode is enabled.  The only 
interrupt throttling you should need is the InterruptThrottleRate (btw you 
can use ethtool -C ethX rx-usecs <usecs between interrupts> to modify this 
on the fly.)

> For example: with TxIntDelay 100 and TxAbsIntDelay 1000 - rate (as read from 
> /proc/interrupts) under simple udp netcat bombarding (1k packet size):
> 
> nc -u somehost someport </dev/zero
> 
> ... will be around 115k int/sec - expected value w/o any interrupt moderation.
> 
> When IntMode is set to 0 or 1 (so either regular or MSI) - both TxIntDelay and 
> TxAbsIntDelay  seem to work properly - in the above example, rate would stay below 
> 1500 int/sec. But ...
> 
> 2) ... at the same time, cpu load (as reported by mpstat -P ALL 1) is barely better 
> in the latter case. Furthermore, if I disable any delays, e.g. load e1000e module with:
> 
> options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=1
> 
> .. then netcat test will max cpu core, and it will be unable to reach full 1gbit, while:
> 
> options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2
> 
> .. will easily handle 1gbit with ~50%+ idle core (in my case at least).
> 
> 
> Should the difference between MSI and MSI-X modes be so large ?

It is, because in the case of MSI-X we don't have to check the ICR 
register, which avoids a huge amount of CPU stall to read the single 
register.  It is the main reason for using MSI-X and MSI (in our case we 
still have to read ICR in the case of MSI on some hardware - hardware bug)

> Earlier tests (pt. #1):
> 
> options e1000e TxIntDelay=100 TxAbsIntDelay=1000 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=1
> 
> .. handles 1gbit with ~60%+ idle core.
> 
> and:
> 
> options e1000e TxIntDelay=100 TxAbsIntDelay=1000 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2
> options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2
> 
> .. are roughly identical as far as cpu load goes.
> 

what it comes down to is that the TxAbsIntDelay and TxIntDelay registers 
were introduced in the time before InterruptThrottleRate, back in the day 
where we only had PCI and PCI-X adapters.  Later PCI/PCI-X/PCIe adapters 
have the hardware to support the InterruptThrottleRate.

These module parameters equate directly to registers in our NIC
TADV = TxAbsIntDelay
TIDV = TxIntDelay
ITR  = InterruptThrottleRate

The 82574L datasheet[1] mentions that in MSI-X mode the IDE (interrupt 
delay enable) bit should *NOT* be set, and the TADV and TIDV registers do 
nothing when the IDE bit is not set, so that pretty well explains what you 
see.  Because the ITR register uses a different mechanism to coalese 
interrupts, it will still apply even without IDE enabled.
 
> Those quick tests were done with nic interrupt(s) and netcat pinned at the same core.
> 
> 
> Tested with current 2.6.31-rc9 and stable 2.6.30 tree.

[1] http://download.intel.com/design/network/datashts/82574.pdf


