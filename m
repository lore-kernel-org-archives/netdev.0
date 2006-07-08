From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 8 Jul 2006 12:54:51 +0200
Message-ID: <20060708105451.GG14627@postel.suug.ch>
References: <1151697554.5270.241.camel@jzny2> <20060630203034.GN14627@postel.suug.ch> <20060630.133348.68039806.davem@davemloft.net> <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:22207 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751301AbWGHKyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 06:54:31 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151760901.5093.141.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-07-01 09:35
> On Sat, 2006-01-07 at 13:28 +0200, Thomas Graf wrote:
> > Please enlighten me, I may be making a wrong assumption again.
> > 
> > 1) tc_verd is reset to 0 after dq in ri_tasklet()
> > 2) TC_AT is set to AT_EGRESS in dev_queue_xmit()
> > 3) TC_FROM being derived from TC_AT in tcf_mirred() when redirecting
> > 4) TC_FROM has the value AT_EGRESS when entering ifb_xmit()
> > 
> 
> Let me answer the next bit and it may clear this.

It's pretty clear actually, given eth0->ifb0->ifb1 it would look
like:

dev_queue_xmit(eth0)
  tcf_mirred -> ifb0
dev_queue_xmit(ifb0)
  tcf_mirred -> ifb1
dev_queue_xmit(ifb1)
  ifb_xmit(ifb1)
  <QUEUE> /* Here we queue the packet for the first time and
             release the stack of tx locks acquired on the
	     way. TC_FROM was never reset up here so this can't
	     possibly prevent any tx deadlocks. However, the
	     !from check is effective later on ... */
  ri_tasklet(ifb1)
dev_queue_xmit(ifb0)
  ifb_xmit(ifb0) /* classification disabled */
    /* Drop due to !from with input_dev = ifb1 which is
       good as it prevents to loop the packet back to
       ifb1 again which I refered to earlier */

Is this how it was intented?

> using what i said as looping in the case of A->B->C->D->A for the case
> of egress since that is what you are alluding to;
> note that ifb0 will be entered twice: First for example the tasklet in
> ifb0 will emit the packet, and then it will go all the way back to xmit
> on ifb0. This is where the issue is. Does that clear it?

I tried to stay out of A->B->A for now since that's currently
broken due to mirred unless the deadlock is intentional, f.e.
when setting up eth0->ifb0->eth0 like this:

ip link set ifb0 up
tc qdisc add dev ifb0 parent root handle 1: prio
tc qdisc add dev eth0 parent root handle 1: prio
tc filter add dev eth0 parent 1: protocol ip prio 10 u32
          match ip protocol 1 0xff flowid 1:1
	  action mirred egress redirect dev ifb0
tc filter add dev ifb0 parent 1: protocol ip prio 10 u32
          match ip protocol 1 0xff flowid 1:1
	  action mirred egress redirect dev eth0

The following deadlock will ocur:

dev_queue_xmit(eth0)
  tcf_mirred -> ifb0  /* acquire tcf_mirred->lock on eth0 */
dev_queue_xmit(ifb0)
  tcf_mirred -> eth0  /* acquire tcf_mirred->lock on ifb0
dev_queue_xmit(eth0)
  tcf_mirred -> ifb0  /* deadlock */

This is assuming that no tx deadlock happens of course. I
did try this out just to make sure, the machine just hung.
I can't see any code trying to prevent this but this is
another discussion as ifb is not involved in this, I think
it's purely a problem of mirred.
