From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 04 Nov 2014 17:20:45 -0800
Message-ID: <1415150445.1458.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
		<f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com>
	 <CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
	 <54593C59.6070004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:40372 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbaKEBUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 20:20:47 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so8519525iec.23
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:20:46 -0800 (PST)
In-Reply-To: <54593C59.6070004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 18:51 -0200, Marcelo Ricardo Leitner wrote:

> And thank you guys for all the assistance on it. Btw, would you send me that 
> packetdrill script? I'm curious to see how such corner case could be written 
> on it.

One of the script I saw was :

You might have to adapt preconditions (tcp_rmem[]/tcp_wmem[])

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
// Set a 10s timeout
+.000 setsockopt(3, SOL_TCP, TCP_USER_TIMEOUT, [10000], 4) = 0
+.000 bind(3, ..., ...) = 0
+.000 listen(3, 1) = 0
+.000 < S 0:0(0) win 32792 <mss 1460,nop,wscale 7>
+.000 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 6>
+.010 < . 1:1(0) ack 1 win 257
+.000 accept(3, ..., ...) = 4
+.000 write(4, ..., 1000) = 1000
+.000 > P. 1:1001(1000) ack 1
+.625 > P. 1:1001(1000) ack 1
+.020 < . 1:1(0) ack 1001 win 257
// Purposely write more after the specified timeout for testing
+11.0 write(4, ..., 1000) = 1000
+.000 > P. 1001:2001(1000) ack 1
+1.25 > P. 1001:2001(1000) ack 1
// socket is killed when the 2nd RTO fires at +2.50 w/o this patch
// so the next write returns ETIMEOUT
+2.60 write(4, ..., 1000) = 1000
