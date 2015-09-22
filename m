From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 10:11:42 -0700
Message-ID: <1442941902.29850.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	 <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
	 <8021096.gY5K1ti0Dn@garfield>
	 <1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1442938150.29850.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35816 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbIVRLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 13:11:46 -0400
Received: by pacfv12 with SMTP id fv12so14644166pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 10:11:45 -0700 (PDT)
In-Reply-To: <1442938150.29850.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-22 at 09:09 -0700, Eric Dumazet wrote:
> On Tue, 2015-09-22 at 07:46 -0700, Eric Dumazet wrote:
> 
> > 
> > Ahem.
> > 
> > packetdrill can make this in one script, as you can exactly control the
> > packets that the 'remote' peer would answer.
> > 
> > No need for complex setup. You should try it, and as a bonus we could
> > easily reproduce the problem and check the fix.
> > 
> > Let see if we can cook a packetdrill scenario.
> 
> 
> Following packetdrill skeleton will provide you a connexion with cwnd=1
> sshtresh=2  (without patching kernel)
> 

A more complete packetdrill scenario would be

# cat cwv.pkt
// Establish a connection and send 1 MSS.
0     socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 65535 <mss 1000,sackOK,nop,nop>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
+.200 < . 1:1(0) ack 1 win 65535
   +0 accept(3, ..., ...) = 4

   +0 write(4, ..., 100) = 100
   +0 > P. 1:101(100) ack 1
+.000 %{ print  tcpi_rto }%

// TLP
+.500~+.505 > P. 1:101(100) ack 1
// RTO
+.600~+.605 > P. 1:101(100) ack 1

+.200 < . 1:1(0) ack 101 win 65535
// cwnd should be 2, ssthresh should be 7
+0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
2.000 write(4, ..., 100) = 100
   +0  > P. 101:201(100) ack 1

// TLP
+.500~+.505 > P. 101:201(100) ack 1
+0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
// RTO
+1.200~+1.210 > P. 101:201(100) ack 1

+0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
+.200 < . 1:1(0) ack 201 win 65535

4.00 write(4, ..., 100) = 100
    +0  > P. 201:301(100) ack 1
4.01 write(4, ..., 100) = 100
	+0 > P. 301:401(100) ack 1
4.02 write(4, ..., 100) = 100
4.03 write(4, ..., 100) = 100
4.04 write(4, ..., 100) = 100
4.05 write(4, ..., 100) = 100
4.06 write(4, ..., 100) = 100
4.07 write(4, ..., 100) = 100
4.08 write(4, ..., 100) = 100
4.09 write(4, ..., 100) = 100
4.10 write(4, ..., 100) = 100
4.11 write(4, ..., 100) = 100
4.12 write(4, ..., 100) = 100
4.13 write(4, ..., 100) = 100
4.14 write(4, ..., 100) = 100
4.15 write(4, ..., 100) = 100
4.16 write(4, ..., 100) = 100
4.17 write(4, ..., 100) = 100
4.18 write(4, ..., 100) = 100
4.19 write(4, ..., 100) = 100

4.20 write(4, ..., 100) = 100
4.20 < . 1:1(0) ack 301 win 65535
4.20 > . 401:1401(1000) ack 1

4.21 write(4, ..., 100) = 100
4.21 < . 1:1(0) ack 401 win 65535
4.21 > P. 1401:2401(1000) ack 1
   +0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
4.22 write(4, ..., 100) = 100
4.23 write(4, ..., 100) = 100
4.24 write(4, ..., 100) = 100
4.25 write(4, ..., 100) = 100
4.26 write(4, ..., 100) = 100
4.27 write(4, ..., 100) = 100
4.28 write(4, ..., 100) = 100
4.29 write(4, ..., 100) = 100
4.31 write(4, ..., 100) = 100
4.32 write(4, ..., 100) = 100
4.33 write(4, ..., 100) = 100
4.34 write(4, ..., 100) = 100
4.35 write(4, ..., 100) = 100
4.36 write(4, ..., 100) = 100
4.37 write(4, ..., 100) = 100
4.38 write(4, ..., 100) = 100
4.39 write(4, ..., 100) = 100

4.40 write(4, ..., 100) = 100
4.40 < . 1:1(0) ack 1401 win 65535
4.40 > . 2401:3401(1000) ack 1
4.41 write(4, ..., 100) = 100
4.41 < . 1:1(0) ack 2401 win 65535
4.41 > P. 3401:4301(900) ack 1
   +0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
4.42 write(4, ..., 100) = 100
4.43 write(4, ..., 100) = 100
4.44 write(4, ..., 100) = 100
4.45 write(4, ..., 100) = 100
4.46 write(4, ..., 100) = 100
4.47 write(4, ..., 100) = 100
4.48 write(4, ..., 100) = 100
4.49 write(4, ..., 100) = 100
4.50 write(4, ..., 100) = 100
4.51 write(4, ..., 100) = 100
4.52 write(4, ..., 100) = 100
4.53 write(4, ..., 100) = 100
4.54 write(4, ..., 100) = 100
4.55 write(4, ..., 100) = 100
4.56 write(4, ..., 100) = 100
4.57 write(4, ..., 100) = 100
4.58 write(4, ..., 100) = 100
4.59 write(4, ..., 100) = 100
4.60 write(4, ..., 100) = 100
4.60 < . 1:1(0) ack 3401 win 65535
4.60 > . 4301:5301(1000) ack 1
4.61 write(4, ..., 100) = 100
4.61 < . 1:1(0) ack 4301 win 65535
4.61 > P. 5301:6301(1000) ack 1
   +0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
4.62 write(4, ..., 100) = 100
4.63 write(4, ..., 100) = 100
4.64 write(4, ..., 100) = 100
4.65 write(4, ..., 100) = 100
4.66 write(4, ..., 100) = 100
4.67 write(4, ..., 100) = 100
4.68 write(4, ..., 100) = 100
4.69 write(4, ..., 100) = 100
4.70 write(4, ..., 100) = 100
4.71 write(4, ..., 100) = 100
4.72 write(4, ..., 100) = 100
4.73 write(4, ..., 100) = 100
4.74 write(4, ..., 100) = 100
4.75 write(4, ..., 100) = 100
4.76 write(4, ..., 100) = 100
4.77 write(4, ..., 100) = 100
4.78 write(4, ..., 100) = 100
4.79 write(4, ..., 100) = 100
4.80 write(4, ..., 100) = 100
4.80 < . 1:1(0) ack 5301 win 65535
4.80 > . 6301:7301(1000) ack 1
4.81 write(4, ..., 100) = 100
4.81 < . 1:1(0) ack 6301 win 65535
   +0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
4.81 > P. 7301:8301(1000) ack 1
4.82 write(4, ..., 100) = 100
4.83 write(4, ..., 100) = 100
4.84 write(4, ..., 100) = 100
4.85 write(4, ..., 100) = 100
4.86 write(4, ..., 100) = 100
4.87 write(4, ..., 100) = 100
4.88 write(4, ..., 100) = 100
4.89 write(4, ..., 100) = 100
4.90 write(4, ..., 100) = 100
4.91 write(4, ..., 100) = 100
4.92 write(4, ..., 100) = 100
4.93 write(4, ..., 100) = 100
4.94 write(4, ..., 100) = 100
4.95 write(4, ..., 100) = 100
4.96 write(4, ..., 100) = 100
4.97 write(4, ..., 100) = 100
4.98 write(4, ..., 100) = 100
4.99 write(4, ..., 100) = 100
5.00 write(4, ..., 100) = 100
5.00 < . 1:1(0) ack 7301 win 65535
5.00 > . 8301:9301(1000) ack 1
5.01 write(4, ..., 100) = 100
5.01 < . 1:1(0) ack 8301 win 65535
5.01 > P. 9301:10301(1000) ack 1
  +0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
5.02 write(4, ..., 100) = 100
5.03 write(4, ..., 100) = 100
5.04 write(4, ..., 100) = 100
5.05 write(4, ..., 100) = 100
5.06 write(4, ..., 100) = 100
5.07 write(4, ..., 100) = 100
5.08 write(4, ..., 100) = 100
5.09 write(4, ..., 100) = 100
5.10 write(4, ..., 100) = 100
5.11 write(4, ..., 100) = 100
5.12 write(4, ..., 100) = 100
5.13 write(4, ..., 100) = 100
5.14 write(4, ..., 100) = 100
5.15 write(4, ..., 100) = 100
5.16 write(4, ..., 100) = 100
5.17 write(4, ..., 100) = 100
5.18 write(4, ..., 100) = 100
5.19 write(4, ..., 100) = 100
5.20 write(4, ..., 100) = 100
5.20 < . 1:1(0) ack 9301 win 65535
5.20 > . 10301:11301(1000) ack 1
5.21 write(4, ..., 100) = 100
5.21 < . 1:1(0) ack 10301 win 65535
5.21 > P. 11301:12301(1000) ack 1
+0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }%
5.22 write(4, ..., 100) = 100
5.23 write(4, ..., 100) = 100
5.24 write(4, ..., 100) = 100
5.25 write(4, ..., 100) = 100
5.26 write(4, ..., 100) = 100
5.27 write(4, ..., 100) = 100
5.28 write(4, ..., 100) = 100
5.29 write(4, ..., 100) = 100
5.30 write(4, ..., 100) = 100
5.31 write(4, ..., 100) = 100
5.32 write(4, ..., 100) = 100
5.33 write(4, ..., 100) = 100
5.34 write(4, ..., 100) = 100
5.35 write(4, ..., 100) = 100
5.36 write(4, ..., 100) = 100
5.37 write(4, ..., 100) = 100
5.38 write(4, ..., 100) = 100
5.39 write(4, ..., 100) = 100
5.40 write(4, ..., 100) = 100
5.40 < . 1:1(0) ack 11301 win 65535
5.40 > . 12301:13301(1000) ack 1
5.41 write(4, ..., 100) = 100
5.41 < . 1:1(0) ack 12301 win 65535
5.41 > P. 13301:14301(1000) ack 1
+0 %{ print "tcpi_snd_cwnd=%d tcpi_snd_ssthresh=%d" % (tcpi_snd_cwnd, tcpi_snd_ssthresh) }% 


Output is :
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=7
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=7
tcpi_snd_cwnd=1 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
tcpi_snd_cwnd=2 tcpi_snd_ssthresh=2
