From: Hans Nieser <hnsr@xs4all.nl>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Fri, 25 Feb 2011 14:45:42 +0100
Message-ID: <1298641542.18103.48.camel@krikkit>
References: <1298396007.23906.27.camel@krikkit>
	 <20110223095538.GA12662@electric-eye.fr.zoreil.com>
	 <1298463704.31256.29.camel@krikkit>  <1298485893.31256.40.camel@krikkit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298485893.31256.40.camel@krikkit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-23 at 19:31 +0100, Hans Nieser wrote:
> On Wed, 2011-02-23 at 13:21 +0100, Hans Nieser wrote:

> > On Wed, 2011-02-23 at 10:55 +0100, Francois Romieu wrote:
> > You may enable PCIEASPM_DEBUG, force 'pcie_aspm=off' and switch from
> > SLUB to SLAB but it's a bit cargo-cultish.

This seemed to have no effect sadly

> Ok, I just tried 2.6.34, and after over 5 hours of running my script,
> the system is still up and running, with only 24 'link up' messages on
> dmesg, and having transferred 2.1TiB of data (1428042421 rx_packets, 45
> rx_missed). So I'm going to assume the problem isn't present with this
> kernel and try a bisect between it and 2.6.35

After spending the entire day yesterday and this morning bisecting this,
I haven't gotten anywhere :/ I ended up at an unrelated commit as being
the first known bad commit (84d4db0e22965334ae8272f324d31fb4657465aa), I
think I may have marked a bad commit as good.. To properly bisect this
issue I probably need to test each commit for a several hours across
multiple reboots, but that is going to be too much time. I've at least
been able to establish that following v2.6.34, the following commits are
bad:

c222fb2efaf1a421f5bf74403df40a9384ccf516
4a973f2495fba8775d1c408b3ee7f2c19b19f13f
84d4db0e22965334ae8272f324d31fb4657465aa

After that I've been trying other various things (on 2.6.38-rc6+) and
made some interesting and confusing discoveries;

- Setting pci=nomsi causes instant reboot when I start my test script

- Enabling only one CPU core in the BIOS seems to solve the whole lock
  up problem, I have not been able to reproduce it after a few hours of
  testing (nor on 2.6.35). (Normally on 2.6.38-rc6 it would crash in
  just a few seconds.)

  Additionally, when I force wget to use IPv4 with only one core
  enabled, I'm suddenly getting a solid 112MB/s instead of the lousy
  9-12MB/s I have been getting since 2.6.36 - but only when using one
  core. With all 4 cores enabled, performance is bad again even when
  forcing wget to use IPv4..

  Using only one CPU core also reduces the 'link up' messages a lot, I
  only got a couple instead of hundreds/thousands.

- Enabling Tickless System (NO_HZ) kernel option seems to make lock up
  occur less frequently (but it still happens), also much less 'link up'
  messages, but also causes an occasional "NOHZ: local_softirq_pending
  08" to appear on dmesg.

- Enabling HyperThreading (I disable it by default due to an issue with
  VirtualBox) in BIOS causes performance to get even worse, just 2-3MB/s
  instead of 9-12MB/s


I've also attempted to bisect the issue I have been having with slow
transfer speed (I don't know if its related to the hang, but I figure if
the hang ever gets fixed, this will have to be fixed as well to make
r8169 usable for me), which started somewhere between v2.6.35 (good) and
v2.6.36 (bad), unfortunately this too ended up at a seemingly unrelated
commit:

af5ab277ded04bd9bc6b048c5a2f0e7d70ef0867 - clockevents: Remove the per
cpu tick skew

Just for kicks I attempted to revert this change on 2.6.38-rc6+, which
seemed to reduce the frequency of 'link up' messages, but no other real
change noticed.
