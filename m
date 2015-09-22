From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 09:09:10 -0700
Message-ID: <1442938150.29850.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	 <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
	 <8021096.gY5K1ti0Dn@garfield>
	 <1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35616 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758598AbbIVQJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:09:12 -0400
Received: by pacfv12 with SMTP id fv12so13245847pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:09:12 -0700 (PDT)
In-Reply-To: <1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-22 at 07:46 -0700, Eric Dumazet wrote:

> 
> Ahem.
> 
> packetdrill can make this in one script, as you can exactly control the
> packets that the 'remote' peer would answer.
> 
> No need for complex setup. You should try it, and as a bonus we could
> easily reproduce the problem and check the fix.
> 
> Let see if we can cook a packetdrill scenario.


Following packetdrill skeleton will provide you a connexion with cwnd=1
sshtresh=2  (without patching kernel)

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
2.000 write(4, ..., 100) = 100
   +0  > P. 101:201(100) ack 1

// TLP
+.500~+.505 > P. 101:201(100) ack 1
// RTO
+1.200~+1.210 > P. 101:201(100) ack 1

   +0 %{ print "tcpi_snd_cwnd=%d" % tcpi_snd_cwnd }%
   +0 %{ print "tcpi_snd_ssthresh=%d" % tcpi_snd_ssthresh }%


Then we can add a bunch of  +.01 write(4, ..., 100) = 100
