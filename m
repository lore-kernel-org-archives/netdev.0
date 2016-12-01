From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net] tcp: warn on bogus MSS and try to amend it
Date: Thu, 1 Dec 2016 18:46:08 -0200
Message-ID: <20161201204608.GB6650@localhost.localdomain>
References: <0d41deb00d57206f518e6bffae1b0be355bbc726.1480511277.git.marcelo.leitner@gmail.com>
 <20161201.152949.1953888486413180001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jmaxwell37@gmail.com,
        alexandre.sidorenko@hpe.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        tlfalcon@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54496 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754747AbcLAUqR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 15:46:17 -0500
Content-Disposition: inline
In-Reply-To: <20161201.152949.1953888486413180001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 03:29:49PM -0500, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Wed, 30 Nov 2016 11:14:32 -0200
> 
> > There have been some reports lately about TCP connection stalls caused
> > by NIC drivers that aren't setting gso_size on aggregated packets on rx
> > path. This causes TCP to assume that the MSS is actually the size of the
> > aggregated packet, which is invalid.
> > 
> > Although the proper fix is to be done at each driver, it's often hard
> > and cumbersome for one to debug, come to such root cause and report/fix
> > it.
> > 
> > This patch amends this situation in two ways. First, it adds a warning
> > on when this situation occurs, so it gives a hint to those trying to
> > debug this. It also limit the maximum probed MSS to the adverised MSS,
> > as it should never be any higher than that.
> > 
> > The result is that the connection may not have the best performance ever
> > but it shouldn't stall, and the admin will have a hint on what to look
> > for.
> > 
> > Tested with virtio by forcing gso_size to 0.
> > 
> > Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> I totally agree with this change, however I think the warning message can
> be improved in two ways:
> 
> >  	len = skb_shinfo(skb)->gso_size ? : skb->len;
> >  	if (len >= icsk->icsk_ack.rcv_mss) {
> > -		icsk->icsk_ack.rcv_mss = len;
> > +		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> > +					       tcp_sk(sk)->advmss);
> > +		if (icsk->icsk_ack.rcv_mss != len)
> > +			pr_warn_once("Seems your NIC driver is doing bad RX acceleration. TCP performance may be compromised.\n");
> 
> We know it's a bad GRO implementation that causes this so let's be specific in the
> message, perhaps something like:
> 
> 	Driver has suspect GRO implementation, TCP performance may be compromised.

Okay.

> 
> Also, we have skb->dev available here most likely, so prefixing the message with
> skb->dev->name would make analyzing this situation even easier for someone hitting
> this.

Nice, yes.
And this skb is mostly non-forwardable as it's bigger than the MTU,
so if someone is using net namespaces and this skb would be routed
through some veth interfaces, it would give a false hint then, but
shouldn't happen. Unless it would fit (a larger) veth mtu, but still,
one probably will simplify things up to debug this.

> 
> I'm not certain if an skb->dev==NULL check is necessary here or not, but it is
> definitely something you need to consider.
> 
> Thanks!
> 

Will check. Thanks!

  Marcelo
