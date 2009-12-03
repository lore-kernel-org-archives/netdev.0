From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 12:29:39 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51980 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbZLCK3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:29:34 -0500
In-Reply-To: <20091203085933.GD30730@sd-11162.dedibox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've added Greg as CC to make him aware of this issue in early as it now 
affects 2.6.32 too (rather important to get dealt quickly in stable once 
we have a tested solution since TCP is pretty broken with the silent 
deaths this problem seems to cause). ...One possibility would be to just 
queue the tested revert to stable and sort this thing out for 2.6.33 in 
net-2.6.

Opinions, Dave?, Greg?

Now back to the issue...

You said in the other mail that "All further test are on linus-stable 
tree.", which has this contradiction that Linus does not maintain stable 
trees. Which exactly was the tree used for the .9. test, Linus' tree or 
the 2.6.31 stable tree? I suppose the former since the revert wouldn't 
apply to 2.6.31 so I just want to confirm.


On Thu, 3 Dec 2009, Frederic Leroy wrote:
> On Wed, Dec 02, 2009 at 08:17:44PM +0100, Damian Lukowski wrote:
> > could you please printk retrans_stamp just before the return in 
> > include/net/tcp.h:retransmits_timed_out()?
> > If the value is not monotonically increasing but is reset to 0 at some
> > point, this might lead to problems in tcp_write_timeout().
> > It's the only idea I have now.
> 
> Your idea is good.
> Only one out of 4 value is not null.
>
> Logs corresponding on http://wwW.starox.org/pub/scp_stall is .10
> 
> I make 2 attempts. Printk corresponding to .10 are those after the line 
> "wlan1 enter promiscuous mode"

Nice thinking indeed Damian, thanks. ...But but, where exactly did you 
print? ...There are multiple returns and the return false branch is 
expected to have a zero retrans_stamp in a typical case but that is not
a problem because we never use the value.

...Anyway, if I'm wrong with my suspicion and it still holds that we have 
zero retrans_stamp in the substraction too, it could have something to do 
with this snippet:

static void tcp_try_to_open(struct sock *sk, int flag)
{
        struct tcp_sock *tp = tcp_sk(sk);

        tcp_verify_left_out(tp);

        if (!tp->frto_counter && tp->retrans_out == 0)
                tp->retrans_stamp = 0;

...It bit me last time when FRTO was enabled after very small modification 
(without running a full verification after the trivial looking 
modification). ...So I've worked around this clearing for FRTO as you 
can see :-).


Also, we have the another mystery to be solved, the fast retransmission is 
not triggered for some reason (or alternatively not captured in to a 
log), even in the working .9. case. It would be easy to see whether it 
works at all from TCP point of view by looking into mibs once you have 
have some transfers in a working configuration:

grep -A1 TCP /proc/net/netstat

...luckily this fast retransmit issue is less crucial as almost all people 
are pretty happy already if their RTO-based recovery works even if the 
fast recovery would not. So figuring it out can be postponed (if one has 
to prioritize) until the silent death issue is out of the way.


-- 
 i.
