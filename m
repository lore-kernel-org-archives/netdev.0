From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: SKY2 vs SK98LIN performance on 88E8053 MAC
Date: Mon, 11 Jun 2007 15:23:26 -0700
Message-ID: <20070611152326.661e9f0e@localhost.localdomain>
References: <20070610092628.4287a935@localhost.localdomain>
	<709767.60054.qm@web52311.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Philip Romanov <philip_romanov@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49774 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753534AbXFKWYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 18:24:14 -0400
In-Reply-To: <709767.60054.qm@web52311.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Jun 2007 12:05:02 -0700 (PDT)
Philip Romanov <philip_romanov@yahoo.com> wrote:

> 
> 
> > > We are doing pure IPv4 forwarding between two
> > Ethernet
> > > interfaces:
> > > 
> > >  IXIA port A<--->System Under Test<--->IXIA Port B
> > > 
> > > Traffic has two IP destinations for each direction
> > and
> > > L4 protocol is UDP. There are two static ARP
> > entries
> > > and only interface routes. Two tests are identical
> > > except that we switch from one driver to another. 
> > > 
> > > Ethernet ports on the SUT are oversubscribed --
> > I'm
> > > sending 60% of line rate (of 256-byte packets) and
> > > measuring percentage of pass-through traffic which
> > > makes to the IXIA port on the other side. Traffic
> > is
> > > bidirectional and system load is close to 100%.
> > > 
> 
> > 
> > Could you post the profiles. Hopefully, others have
> > good ideas
> > as well.
> > 
> > 256 bytes is the size where the copybreak
> > optimization kicks in
> > so you might want to experiment with the copybreak
> > module option
> > to the sky2 driver. copybreak=0 would no packets to
> > be copied,
> > copybreak=1514 would cause all packets to be copied.
> >  Copying is
> > an optimization that helps when receiving small
> > packets locally,
> > but may slow down forwarding path.
> > 
>  
> 
> Profiles were attached to previous posting in the
> thread. I'm pasting them in plain text now at the end.
> There are four profiles: two for the vmlinux and two
> for sky2 and sk98lin drivers.
> 
> Regarding copybreak parameter: it appears that it
> kicks in starting from 128 bytes by default??? 
> 
> ...
> static int copybreak __read_mostly = 128;
> module_param(copybreak, int, 0);
> MODULE_PARM_DESC(copybreak, "Receive copy threshold");
> ...
> 
> Anyway, I tried both copybreak settings of 0 and 1500:
> there is significant slowdown when copybreak is set to
> 1500 with 256-byte traffic. Another clarification:
> 256-byte packets refer to entire Ethernet frame
> including FCS, so when packets make into the driver
> they become 252-byte long. I also tried to switch
> driver to IRQ mode from MSI (SK98LIN is running is IRQ
> mode) -- that did not have any significant effect on
> forwarding performance.
> 
> 
> Oprofile results:
> ================================================
> profile for vmlinux 2.6.21.3 running with sk98lin
> driver:
> 
> CPU: PIII, speed 2000.1 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (clocks processor is
> not halted) with a unit mask of 0x00 (No unit mask)
> count 100000
> samples  %        symbol name
> 1626     14.3222  _raw_spin_trylock

Bogus extra locking in sk98lin, no surprise.
BTW. for a scare run lockdep on it...


> 935       8.2357  dev_hard_start_xmit
> 756       6.6590  sub_preempt_count
> 574       5.0559  __alloc_skb
> 507       4.4658  _raw_spin_unlock
> 462       4.0694  add_preempt_count
>
> ==================================================
> profile for vmlinux 2.6.21.3 running with sky2 driver:
> 
> CPU: PIII, speed 2000.22 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (clocks processor is
> not halted) with a unit mask of 0x00 (No unit mask)
> count 100000
> samples  %        symbol name
> 7894      9.0213  __alloc_skb
> 6475      7.3997  skb_release_data
> 5706      6.5208  dev_hard_start_xmit
> 5656      6.4637  ip_output
> 5652      6.4591  eth_type_trans
> 5432      6.2077  ip_rcv
> 5278      6.0317  netif_receive_skb
> 3499      3.9987  kfree
> 3195      3.6513  _raw_spin_trylock

It looks like it is reallocating for each receive, not sure why?
