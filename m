From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 22:18:22 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-2096650738-1259608748=:9826"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52589 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZK3USQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:18:16 -0500
In-Reply-To: <20091130195004.38dbc319@houba>
Content-ID: <alpine.DEB.2.00.0911302158320.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-2096650738-1259608748=:9826
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911302158321.9826@melkinpaasi.cs.helsinki.fi>

On Mon, 30 Nov 2009, Frederic Leroy wrote:

> Le Sat, 28 Nov 2009 13:31:14 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Sat, 28 Nov 2009, Frederic Leroy wrote:
> > 
> > > Le Sat, 28 Nov 2009 00:12:23 +0200 (EET),
> > > "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> > > 
> > > > On Fri, 27 Nov 2009, Frederic Leroy wrote:
> > > > 
> > > > > I put traces of stall here : 
> > > > > http://www.starox.org/pub/scp_stall/
> > [...]
> > Perhaps having the /proc/net/tcp would at least tell what state the
> > timer is (if I cannot reproduce right away). ...It is rather strange
> > that two independent mechanisms for loss recovery seem both to fail
> > to get triggered here, no traces of retransmission whatsoever. I
> > think it is for now enough to concentrate on what happens on
> > 192.168.1.15 (=houba?) and get tcpdump and proc/net/tcp from there,
> > the other end/direction has very little significance here (except for
> > the fact that bidirectionality might be needed to actually trigger
> > it). You could even think of getting proc/net/tcp a bit more often,
> > right from the start:
> > 
> > while [ : ]; do grep ":0016" /proc/net/tcp; sleep 0.1; done | tee
> > scp_stall-houba.x.proc_net_tcp
> > 
> > ...Please wait at least 2 minutes before hitting ctrl-c or otherwise 
> > artificially intervening.
> 
> You're right, 192.168.1.15 is houba.
> The faulty behaviour comes back today, I did new captures on
> 192.168.1.15 only : 
> http://www.starox.org/pub/scp_stall/scp_stall-houba.2.pcap
> http://www.starox.org/pub/scp_stall/scp_stall-houba.2.proc_net_tcp
> http://www.starox.org/pub/scp_stall/scp_stall-houba.3.pcap
> http://www.starox.org/pub/scp_stall/scp_stall-houba.3.proc_net_tcp
> 
> Which tool do you use to analyze /proc/net/tcp ?

Thanks, at least ....3.... shows that cwnd (congestion window, the 2nd to 
last field in /proc/net/tcp) goes to zero which it never ever should. 
...I'll start reading some code to figure out the cause for that.

How much is your RTT btw? The RTO timeout easily goes up to 120 secods 
similar to what I found myself already. Thus I'm not sure if this stall 
would be "infinite" after all.

I've some problem in .3. case in  matching timing of the proc/net/tcp dump 
and the tcpdump ... did you perhaps cut it somewhere? This might point out 
to yet another problem, however, I'm not sure what I can atm trust in the 
logs. ...Timestamps would probably help me a bit (I've changed also sleep 
to do 0.01 granularity):

while [ : ]; do date "+%s.%N"; grep ":0016" /proc/net/tcp; sleep 0.01; done | tee scp_stall-houba.x.proc_net_tcp

(Please run start while loop before starting the transfer and all the way 
until the connection is already killed and only then stop the loop).

What happened in .2. case I've very little idea, proc/net/tcp does claim 
retransmission would have happened on TCP layer but that never went into 
tcpdump log (the kind of thing might have happened in the .3. case too 
which is why I asked for the timestamps for matching captures more exactly 
but there were some retransmissions earlier in the log so I cannot be 
sure). Can you also check that tcpdump doesn't lose any packets, it 
should show: "0 packets dropped by kernel" when you ctrl-c it.


-- 
 i.
---696230645-2096650738-1259608748=:9826--
