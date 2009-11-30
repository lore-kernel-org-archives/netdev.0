From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 23:37:56 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-329928318-1259616155=:9826"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60310 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbZK3Vhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 16:37:51 -0500
In-Reply-To: <20091130213727.2f4047d2@houba>
Content-ID: <alpine.DEB.2.00.0911302327010.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-329928318-1259616155=:9826
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911302327011.9826@melkinpaasi.cs.helsinki.fi>

On Mon, 30 Nov 2009, Frederic Leroy wrote:

> Le Mon, 30 Nov 2009 22:18:22 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Mon, 30 Nov 2009, Frederic Leroy wrote:
> > 
> > Thanks, at least ....3.... shows that cwnd (congestion window, the
> > 2nd to last field in /proc/net/tcp) goes to zero which it never ever
> > should. ...I'll start reading some code to figure out the cause for
> > that.
> > 
> > How much is your RTT btw?
> 
> The RTT is ~ 1.4ms.
> The following trace has a rtt as big as 5ms but most of the time, it's
> under 1.4ms and periodically grow to 3ms. 
> 
> -------------------------------------------
> 64 bytes from sg (192.168.1.19): icmp_seq=681 ttl=64 time=1.26 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=682 ttl=64 time=1.26 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=683 ttl=64 time=1.34 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=684 ttl=64 time=2.01 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=686 ttl=64 time=2.15 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=687 ttl=64 time=5.07 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=688 ttl=64 time=1.19 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=689 ttl=64 time=1.30 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=690 ttl=64 time=1.19 ms
> 64 bytes from sg (192.168.1.19): icmp_seq=691 ttl=64 time=1.14 ms
> -------------------------------------------

Thanks, quite much what I expected (a low one).

> > The RTO timeout easily goes up to 120
> > secods similar to what I found myself already. Thus I'm not sure if
> > this stall would be "infinite" after all.
> 
> I notice that grep '":0016" /proc/net/tcp' stop to report something when
> it stalls. Is the connection closed ?

...that seems possible because of the reset in the end (however, the 
earlier fin in .3. does not get reset as response for some reason). 
Another option is that the socket is locked so long that grep has to wait 
until read succeeds.

...I might have been wrong with this 120 seconds thing btw, I misread the 
units.

> > I've some problem in .3. case in  matching timing of the proc/net/tcp
> > dump and the tcpdump ... did you perhaps cut it somewhere?
> 
> No, I didn't cut it.

Ok.

> > This might
> > point out to yet another problem, however, I'm not sure what I can
> > atm trust in the logs. ...Timestamps would probably help me a bit
> > (I've changed also sleep to do 0.01 granularity):
> > 
> > while [ : ]; do date "+%s.%N"; grep ":0016" /proc/net/tcp; sleep
> > 0.01; done | tee scp_stall-houba.x.proc_net_tcp
>  
> > (Please run start while loop before starting the transfer and all the
> > way until the connection is already killed and only then stop the
> > loop).
> 
> I took care to timings this time. I did as you said.
> 
> > What happened in .2. case I've very little idea, proc/net/tcp does
> > claim retransmission would have happened on TCP layer but that never
> > went into tcpdump log (the kind of thing might have happened in
> > the .3. case too which is why I asked for the timestamps for matching
> > captures more exactly but there were some retransmissions earlier in
> > the log so I cannot be sure). Can you also check that tcpdump doesn't
> > lose any packets, it should show: "0 packets dropped by kernel" when
> > you ctrl-c it.
> 
> I still have the logs, O packet dropped : 
> 
> -------------------------------------------
> houba tmp # tcpdump -i wlan1 -s 1500 -w /tmp/ssh_stall-houba.1.pcap -vv
> ether host 00:40:45:09:3f:3f tcpdump: listening on wlan1, link-type
> EN10MB (Ethernet), capture size 1500 bytes ^C8923 packets captured
> 8923 packets received by filter
> 0 packets dropped by kernel
> houba tmp # tcpdump -i wlan1 -s 1500 -w /tmp/scp_stall-houba.3.pcap
> -vv ether host 00:40:45:09:3f:3f tcpdump: listening on wlan1, link-type
> EN10MB (Ethernet), capture size 1500 bytes ^C17045 packets captured
> 17045 packets received by filter
> 0 packets dropped by kernel
> houba tmp # 

Ok. Just wanted to confirm since it can be that that not all packets are 
in the tcpdump that TCP was sending. For what reason is unknown at the 
moment. Any fancy firewall (iptables) rules on houba that could do such a 
trick here? Also, have you changed sysctl settings from the defaults?

Could you try btw to disable frto (set tcp_frto sysctl to zero), in theory 
it could cause zero cwnd if something else is wrong too (I haven't yet 
read them all through so there might be other places where a zero cwnd 
can be set). Also I'm interested what happens if you disable timestamps, 
is the problem still reproducable.

-- 
 i.
---696230645-329928318-1259616155=:9826--
