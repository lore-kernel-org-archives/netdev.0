From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 18 Jul 2008 16:55:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807181617550.24938@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807171715.16265.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807171819160.13775@wrl-59.cs.helsinki.fi>
 <200807181114.53059.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-167444602-1216387871=:24938"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59387 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbYGRNzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:55:39 -0400
In-Reply-To: <200807181114.53059.thomas.jarosch@intra2net.com>
Content-ID: <Pine.LNX.4.64.0807181654140.24938@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-167444602-1216387871=:24938
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0807181649091.24938@wrl-59.cs.helsinki.fi>

On Fri, 18 Jul 2008, Thomas Jarosch wrote:

> On Thursday, 17. July 2008 17:53:01 Ilpo Järvinen wrote:
> > > > One option would be to disable reentry to FRTO when some progress was
> > > > made... Please try with the patch below...
> >
> > Ah, I just forgot that the situation might persist... Try with this
> > one instead...
> 
> Good news everyone: Two connections made it to the finish line.
> 
> The bad part: One transfer took four minutes, the other sixteen minutes.
> A colleague commented it's still much faster than carrying the message
> by plane ;-) A session without FRTO takes around 84 seconds.

...I guess if you would limit ssthresh to some small value you might beat 
that value even without FRTO.

> I've added debug printks() to every return path in tcp_use_frto(),
> so you can see what's going on. They look like this:
> 
> Jul 18 10:20:40 intratest131 kernel: [  957.318006] tcp_use_frto: ENTER: frto_counter: 0, icsk->icsk_ca_state: 0
> Jul 18 10:20:40 intratest131 kernel: [  957.318011] tcp_use_frto: DEFAULT RETURN 1;
> Jul 18 10:21:08 intratest131 kernel: [  984.446006] tcp_use_frto: ENTER: frto_counter: 3, icsk->icsk_ca_state: 0
> Jul 18 10:21:08 intratest131 kernel: [  984.446011] tcp_use_frto: RETURN in "tp->frto_counter > 1 || icsk->icsk_ca_state == TCP_CA_Loss"
> Jul 18 10:21:14 intratest131 kernel: [  991.058006] tcp_use_frto: ENTER: frto_counter: 0, icsk->icsk_ca_state: 0
> Jul 18 10:21:14 intratest131 kernel: [  991.058011] tcp_use_frto: DEFAULT RETURN 1;
> 
> Here are two new dumps and the corresponding debug traces:
> http://www.intra2net.com/de/download/tcpdump/tcp_frto_second_patch.tar.bz2

It seems that with FRTO the retransmission timeout grows much higher which 
causes longer delays when things continue by RTO, this might be plainly 
due to the fact that some timeouts seem indeed spurious, and with FRTO we 
can take RTT measures out of such. I'll keep digging deeper... The 
receiver is definately doing something crazy as well, eg.:

6.1.131.56060: . ack 1995587 win 65535
152.31.131.25: . 1998387:1999787(1400) ack 562 win 7504 (DF)
152.31.131.25: . 1999787:2001187(1400) ack 562 win 7504 (DF)
152.31.131.25: . 2001187:2002587(1400) ack 562 win 7504 (DF)
6.1.131.56060: . ack 1995587 win 8192 (DF)
6.1.131.56060: . ack 1996987 win 8192 (DF)
6.1.131.56060: . ack 1996987 win 8192 (DF)
6.1.131.56060: . ack 1996987 win 8192 (DF)

...The receiver shrunk the window here (it's not the only example) :-), 
though on the bright side, those are duplicate ACKs... :-D

Btw, on which kernel you ran these things (I hope it wasn't 2.6.24.7, 
which has FRTO related bugs anyway that the patches I've sent now won't 
fix)? 

-- 
 i.
---696208474-167444602-1216387871=:24938--
