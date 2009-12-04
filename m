From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Fri, 4 Dec 2009 12:41:32 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912040006280.776@melkinpaasi.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
 <4B1820B8.7050500@tvk.rwth-aachen.de> <20091203230339.56a613e1@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-465018470-1259878229=:776"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52384 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbZLDKl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 05:41:27 -0500
In-Reply-To: <20091203230339.56a613e1@houba>
Content-ID: <alpine.DEB.2.00.0912041209110.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-465018470-1259878229=:776
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912040010331.776@melkinpaasi.cs.helsinki.fi>

On Thu, 3 Dec 2009, Frederic Leroy wrote:

> Le Thu, 03 Dec 2009 21:34:00 +0100,
> Damian Lukowski <damian@tvk.rwth-aachen.de> a écrit :
> 
> > Frederic Leroy schrieb:
> > > Le Thu, 03 Dec 2009 15:10:11 +0100,
> > > Damian Lukowski <damian@tvk.rwth-aachen.de> a écrit :
> > >>> I suppose adding || !tp->retrans_stamp into the false condition is
> > >>> fine as long as we don't then have a connection that can cause a
> > >>> connection to hang there forever for some reason (this needs to be
> > >>> understood well enough, not just test driven in stables :-)).
> > >>>
> > >>>> Unluckily, I still cannot reproduce the scp stalls here, so it
> > >>>> would be nice if Frederic printed retrans_stamp together with
> > >>>> icsk_ca_state and icsk_retransmits, please.
> > >>> It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
> > >>> that might have some significant w.r.t what happens because of
> > >>> FRTO.
> > >> I made a patch for Frederic with Codebase
> > >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> > >>
> > >> Thanks for testing.
> > > 
> > > I made a new .11 trace with damian patch.
> > > The copy went to the end. 
> > 
> > Ok, at least this "fix" seems to work at first glance, but the printk
> > is quite useless now. Could you run another test with the printk's but
> > without the retrans_stamp == 0 check, please?
> 
> Done, it's .13
> 
> It stalled.
> 
> I only manage to make a failing stream only once. It seems
> after 23h the network is not interferenced.

...Your neighbors fall early into sleep :-).

It seems that TCP was in recovery (ca_state 3) when the timeout triggered 
but for some reason no retransmissions in flight. Also, TCPCB_LOST was 
marked for skbs, thus making them available for retransmission. I've read 
tcp_xmit_retransmit_queue multiple times through (and also 
tcp_mark_head_lost) but cannot find out what would prevent the rexmit 
loop from sending the retransmissions. And they seem to work for the
opposite end though.

But there is more, also for the working case and RTOs (.12.) we see 
rexmits not always flying out, see this:

t, sacked_out: 208867, 208867, 1, 1, 6, 1, 1, 1, 4
t, sacked_out: 209426, 0, 0, 3, 6, 0, 0, 1, 5
t, sacked_out: 209426, 0, 0, 3, 6, 0, 0, 1, 5
t, sacked_out: 209426, 0, 1, 1, 6, 0, 1, 1, 5
t, sacked_out: 210256, 0, 1, 1, 6, 0, 1, 1, 5
t, sacked_out: 210256, 0, 1, 1, 6, 0, 1, 1, 5
t, sacked_out: 210256, 210256, 2, 1, 6, 1, 1, 1, 5
t, sacked_out: 210855, 0, 0, 3, 6, 0, 0, 1, 4

The fourth row has increase isck_retransmit (in tcp_retransmit_timer, 
called near the end) but there are no retransmission in flight (and that 
previous line is printed right before that so there is no room for races 
or so)? ...I suspect we find the problem from tcp_retransmit_skb or from 
the stuff it calls into if looking carefully enough. Besides, that is the 
only common denominator for fast recovery retransmissions and for the RTO 
retransmission.


-- 
 i.
---696230645-465018470-1259878229=:776--
