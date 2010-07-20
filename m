From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Tue, 20 Jul 2010 11:33:38 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007201101090.14034@wel-95.cs.helsinki.fi>
References: <1279548555.2553.51.camel@edumazet-laptop> <alpine.DEB.2.00.1007192013010.30181@melkinpaasi.cs.helsinki.fi> <1279561148.2553.150.camel@edumazet-laptop> <20100719.125500.257479409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lennart.schulte@nets.rwth-aachen.de,
	tj@kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, henning.fehrmann@aei.mpg.de,
	carsten.aulbert@aei.mpg.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100719.125500.257479409.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jul 2010, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 19 Jul 2010 19:39:08 +0200
> 
> > Do you know in what exact circumstance the bug triggers ?
> > 
> > It's hard to believe thousand of machines on the Internet never hit
> > it :(
> > 
> > Maybe another problem in congestion control ?
> 
> This is something to investigate, but the conditions under which
> tcp_fastretrans_alert() (the main invoker of tcp_xmit_retransmit_queue())
> does it's thing are complicated enough that I'm going to add this fix
> for the time being and push it out to stable too.

This is so true. ...So far I've managed to twice rule out of the 
possibility of this being really triggerable (ie., it would mean
Lennart's out of tree changes broke it), and once in the middle came
into opposite conclusion. Thus by majority voting we can deduce that it 
won't happen - how reassuring :-/. It seems that tcp_try_undo_recovery 
causes return if TCP remained in CA_Loss/CA_Recovery and that 
tcp_time_to_recover won't really let past return either under normal 
circumstances (more details below), and tcp_simple_retransmit 
requires lost_out to change; seems safe in mainline to me.

Hmm... It seems that I've just solved another report too. ...Somebody a 
while back found out that setting reordering sysctl to zero (ie. to a 
value which does not make too much sense) crashed the kernel. It seems 
that at least then tcp_time_to_recover() would return true and trigger 
this bug (though I'm not sure if that's the only breakage to happen).

Also worth to keep in mind is the bugzilla entry ("New freez in 
TCP" or something like that) so I'm not really sure I could say for sure 
nobody never hit it. The bugzilla one goes away by disable SACK (at least 
for some) but it might mix two different issues. It seems that there 
really are two different issues, the other may have something to do with 
SACK though there are other variables then involved, e.g., the changes in 
retransmission logic/timing, so it's impossible to say if the SACK disable 
really "fixed" the bugzilla one or not. Also Tejun's ->next == NULL 
finding points out to a different bug than this Lennart's one.


-- 
 i.
