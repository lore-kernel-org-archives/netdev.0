From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Sun, 6 Dec 2009 12:29:20 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912061206490.19391@melkinpaasi.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
 <4B1ADF79.6000101@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1949695512-1260094035=:19391"
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48348 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933243AbZLFK3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 05:29:14 -0500
In-Reply-To: <4B1ADF79.6000101@tvk.rwth-aachen.de>
Content-ID: <alpine.DEB.2.00.0912061207190.19391@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1949695512-1260094035=:19391
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912061207191.19391@melkinpaasi.cs.helsinki.fi>

On Sat, 5 Dec 2009, Damian Lukowski wrote:

> Frederic Leroy schrieb:
> > Le Thu, 03 Dec 2009 15:10:11 +0100,
> > Damian Lukowski <damian@tvk.rwth-aachen.de> a écrit :
> >>> I suppose adding || !tp->retrans_stamp into the false condition is
> >>> fine as long as we don't then have a connection that can cause a
> >>> connection to hang there forever for some reason (this needs to be
> >>> understood well enough, not just test driven in stables :-)).
> >>>
> >>>> Unluckily, I still cannot reproduce the scp stalls here, so it
> >>>> would be nice if Frederic printed retrans_stamp together with
> >>>> icsk_ca_state and icsk_retransmits, please.
> >>> It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
> >>> that might have some significant w.r.t what happens because of FRTO.
> >> I made a patch for Frederic with Codebase
> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> >>
> >> Thanks for testing.
> > 
> > I made a new .11 trace with damian patch.
> > The copy went to the end.
> 
> Could you please make another test and unplug the cable or drop ACKs for
> several seconds, so that some RTO retransmissions are performed?
> I'd like to see if retrans_stamp remains constant. In the dmesg output of
> the 11th run, it seems to change while icsk_retransmits also increases.
> This is kind of bad for connection timeout calculation in the RTO case ...


...Good point, I think that's another bug in this area. We should prevent 
retrans_stamp update when the RTO itself caused tp->retrans_out to become
zero. This bug affects also other things that are based on retrans_stamp, 
not only your code but there the effect is just less devastating.

...Anyway, we know already what happens by reading code when we know the 
case what to look for. If tcp_retransmit_skb encounters any error no 
retrans_stamp is changed (besides, cable might not be enough if you don't 
lose the route, depends on configuration what happens). And if retrans_out 
is zero, the stamp gets updated (assuming the rexmit was successfully 
made without some error condition).

What I think we need is something like this to handle all error cases 
cleanly (plus to fix that another bug I mentioned above):

	if (!icsk->icsk_retransmits)
		return false;

	if (unlikely(!tp->retrans_stamp)) {
		start_ts = TCP_SKB_CB(tcp_write_queue_head(sk))->when;
	} else {
		start_ts = tp->retrans_stamp;
	}

...and then use that timestamp in the substraction. It handles the case 
where retrans_stamp was never updated (agreeably there are corner cases 
even then where the connection doesn't die exactly when we would want when 
retrans_stamp got set on some high icsk_retransmits but still it would 
only be less than double of the specified time). ...We just need to audit 
that tcp_write_queue_head and when are always valid when call happens (I 
think they should be but that has to checked).

-- 
 i.
---696230645-1949695512-1260094035=:19391--
