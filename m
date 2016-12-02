From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net] tcp: warn on bogus MSS and try to amend it
Date: Fri, 2 Dec 2016 08:07:36 -0200
Message-ID: <20161202100736.GC6650@localhost.localdomain>
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
Received: from mx1.redhat.com ([209.132.183.28]:34722 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932914AbcLBKHn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:07:43 -0500
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
> 
> Also, we have skb->dev available here most likely, so prefixing the message with
> skb->dev->name would make analyzing this situation even easier for someone hitting
> this.

It's not avaliable anymore.. It's NULLified before we get there:

tcp_v4_rcv()   (same for v6)
{
	...
	skb->dev = NULL;
	...
        if (!sock_owned_by_user(sk)) {
                if (!tcp_prequeue(sk, skb))
                        ret = tcp_v4_do_rcv(sk, skb);
        } else if (tcp_add_backlog(sk, skb)) {
	...
}

I'll update the msg as above and post v2.

Thanks,
Marcelo
