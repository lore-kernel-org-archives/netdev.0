From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 23:48:29 +0200
Message-ID: <20080616214829.GA9334@orion.carnet.hr>
References: <20080616140454.GD5350@solarflare.com> <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com> <20080616191354.GA11760@orion.carnet.hr> <20080616213821.GA8844@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	mirrors@debian.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:45315 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbYFPVsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 17:48:32 -0400
Content-Disposition: inline
In-Reply-To: <20080616213821.GA8844@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 11:38:21PM +0200, Josip Rodin wrote:
> > > Josip, please provide more information such as driver version from
> > > ethtool -i, lspci, which version did you first see the problem, and
> > > whether the latest in 2.6.25 has the same problem.  Thanks.
> > 
> > The version with the problem is 2.6.22.18. The machine is fairly new
> > (HP DL360 G5), it only ever ran the .22 kernel. It was running this kernel
> > just fine for 112 days prior to the first incident on 2008-06-03, and since
> > then, the crash happened a total of 17 times. Our big rsync runs happen
> > twice a day, so it's a pretty bad record.
> > 
> > I can't verify that the crash was caused by the same thing every time
> > because I don't have console logs, but the symptoms are always the same - a
> > few minutes into the rsync run, it goes down, logging nothing in syslog.
> > 
> > I'll be rebooting into 2.6.25.6 shortly, and then I'll have information
> > relevant to that in about a day or two.
> 
> Crap, it just crashed again, with 2.6.25.6.

I should mention that I might have a clue - around the time the crashes
started, I started using HTB with the following configuration:

tc qdisc add dev eth0 root handle 1: htb default 100
tc class  add dev eth0 parent 1: classid  1:1  htb rate 500mbit ceil 1gbit burst 5m
tc class  add dev eth0 parent 1:1 classid 1:2  htb rate 100mbit ceil 1gbit burst 1m prio 0
tc qdisc  add dev eth0 parent 1:2  handle 2:  sfq
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dport 22 0xffff   flowid 1:2
tc class  add dev eth0 parent 1:1 classid 1:3  htb rate 100mbit ceil 1gbit burst 1m prio 1
tc qdisc  add dev eth0 parent 1:3  handle 3:  sfq
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dport 873 0xffff   flowid 1:3
tc class  add dev eth0 parent 1:1 classid 1:16 htb rate 50mbit ceil 100mbit burst 512k prio 3
tc qdisc  add dev eth0 parent 1:16 handle 16: sfq
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 161.53.160.16 flowid 1:16
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip src 161.53.160.16 flowid 1:16
tc class  add dev eth0 parent 1:1 classid 1:100 htb rate 100mbit ceil 300mbit burst 1m prio 2
tc qdisc  add dev eth0 parent 1:100 handle 100: sfq

HTB actually complains a little bit about r2q/quantum (too big), but that's
not supposed to be so harmful.

-- 
     2. That which causes joy or happiness.
