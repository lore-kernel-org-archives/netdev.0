From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 14:41:32 +0100
Message-ID: <OF909C1D50.039CA234-ONC1257583.004A94AC-C1257583.004B3666@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <OF0CA19511.F677CAFF-ONC1257583.0047FA24-C1257583.00494BDB@transmode.se> <49C8E039.4040505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:33379 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909AbZCXNle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 09:41:34 -0400
In-Reply-To: <49C8E039.4040505@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote on 24/03/2009 14:29:29:

[SNIP]

> >>>> You could change qhimark from 10000 to 1000 in kernel/rcuclassic.c 
> > (line 
> >>> 80)
> >>>> as a workaround. It should force a quiescent state after 1000 freed 

> >>> conntracks.
> >>>
> >>> right, doing this almost killed all conntrack messages, had to 
stress 
> > it 
> >>> pretty
> >>> hard before I saw handful "nf_conntrack: table full, dropping 
packet"
> >>>
> >>> RCU is not my cup of tea, do you have any ideas were to look?
> >> In a stress situation, you feed more deleted conntracks to call_rcu() 

> > than
> >> the blimit (10 real freeing per RCU softirq invocation). 
> >>
> >> So with default qhimark being 10000, this means about 10000 
conntracks
> >> can sit in RCU (per CPU) before being really freed.
> >>
> >> Only when hitting 10000, RCU enters a special mode to free all queued 

> > items, instead
> >> of a small batch of 10
> >>
> >> To solve your problem we can :
> >>
> >> 1) reduce qhimark from 10000 to 1000 (for example)
> >>    Probably should be done to reduce some spikes in RCU code when 
> > freeing
> >>    whole 10000 elements...
> >> OR
> >> 2) change conntrack tunable (max conntrack entries on your machine)
> >> OR
> >> 3) change net/netfilter/nf_conntrack_core.c to decrement 
net->ct.count
> >>   in nf_conntrack_free() instead of callback.
> >>
> >> [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
> > 
> > The patch fixes the problem and the system feels a bit more responsive 

> > too, thanks.
> > I guess I should probably do both 1) and 3) as my board is pretty slow 

> > too.
> > 
> > Been trying to figure out a good value for NAPI weigth too. Currently 
my
> > HW RX and TX queues are 16 pkgs deep and weigth is 16 too. If I move 
TX 
> > processing
> > to NAPI context AND increase weigth to 32, the system is a lot more 
> > responsive during
> > ping flooding. Does weigth 32 make sense when the HW TX and RX queues 
are 
> > 16?
> 
> If you only have one NIC, I dont understand why changing weight should 
make
> a difference. Are you referring to dev_weight or netdev_budget ?
> 
> # cat /proc/sys/net/core/dev_weight
> 64
> # cat /proc/sys/net/core/netdev_budget
> 300

I mean this call in ucc_geth:
  netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
UCC_GETH_DEV_WEIGHT is 16

Noticed that rcuclassic.c has a 
  module_param(qhimark, int, 0);
But I can't figure out hot to set this qhimark from the cmdline.
 rcuclassic.c is not a module(I don't use modules at all)

 Jocke
 Jocke


