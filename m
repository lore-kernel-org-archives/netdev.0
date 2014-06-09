From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 07:33:08 -0700
Message-ID: <1402324388.3645.359.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
		<1402151680-11434-1-git-send-email-per.hurtig@kau.se>
		<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
		<539413BA.7060903@kau.se>
	 <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
	 <5395B2FC.3070205@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52446 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933232AbaFIOdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 10:33:10 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so789857pad.20
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 07:33:09 -0700 (PDT)
In-Reply-To: <5395B2FC.3070205@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 15:13 +0200, Per Hurtig wrote:
> >
> Yes, it needs a SACK that covers one "sequence number", which a FIN
> does. I don't see why it shouldn't generate a SACK? See below for some 
> packet dumps.

I cooked following packetdrill test :

$ cat tlp-10pkt-fin.pkt 
`../common/defaults.sh`
// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4

// Send 8 MSS.
0.200 write(4, ..., 8000) = 8000
+.000 > P. 1:8001(8000) ack 1
+.000   close(4) = 0
+.000 > F. 8001:8001(0) ack 1

// Receiver ACKs 7 packets
0.300 < . 1:1(0) ack 7001 win 257
// check if TLP re-sends the FIN
0.500 > F. 8001:8001(0) ack 1
0.600 < . 1:1(0) ack 7001 win 257 <sack 8001:8001,nop,nop>
// check if fast restransmit is correctly triggered.
0.600 > P. 7001:8001(1000) ack 1

# ../packetdrill tlp-10pkt-fin.pkt
tlp-10pkt-fin.pkt:26: error handling packet: timing error: expected
outbound packet at 0.600000 sec but happened at 1.099761 sec
script packet:  0.600000 P. 7001:8001(1000) ack 1 
actual packet:  1.099761 P. 7001:8001(1000) ack 1 win 457 

So it looks like fast retransmit is not triggered.
