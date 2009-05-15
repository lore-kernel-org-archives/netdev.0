From: Antonio Almeida <vexwek@gmail.com>
Subject: HTB accuracy for high speed
Date: Fri, 15 May 2009 15:49:31 +0100
Message-ID: <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net,
	davem@davemloft.net, devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:56318 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbZEOOtd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 10:49:33 -0400
Received: by fg-out-1718.google.com with SMTP id d23so140361fga.17
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 07:49:32 -0700 (PDT)
In-Reply-To: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I've been using HTB in a Linux bridge and recently I noticed that, for
high speed, the configured rate/ceil is not respected as for lower
speeds.
I'm using a packet generator/analyser to inject over 950Mpbs, and see
what returns back to it, in the other side of my bridge. Generated
packets have 800bytes. I noticed that, for several tc HTB rate/ceil
configurations the amount of traffic received by the analyser stays
the same. See this values:

HTB conf=A0=A0=A0=A0=A0 Analyser reception
476000Kbit=A0=A0=A0 544.260.329
500000Kbit=A0=A0=A0 545.880.017
510000Kbit=A0=A0=A0 544.489.469
512000Kbit=A0=A0=A0 546.890.972
-------------------------
513000Kbit=A0=A0=A0 596.061.383
520000Kbit=A0=A0=A0 596.791.866
550000Kbit=A0=A0=A0 596.543.271
554000Kbit=A0=A0=A0 596.193.545
-------------------------
555000Kbit=A0=A0=A0 654.773.221
570000Kbit=A0=A0=A0 654.996.381
590000Kbit=A0=A0=A0 655.363.253
605000Kbit=A0=A0=A0 654.112.017
-------------------------
606000Kbit=A0=A0=A0 728.262.237
665000Kbit=A0=A0=A0 727.014.365
-------------------------

There are these steps and it looks like doesn't matter if I configure
HTB to 555Mbit or to 605Mbit - the result is the same: 654Mbit. This
is 18% more traffic than the configured value. I also realise that for
smaller packets it gets worse, reaching 30% more traffic than what I
configured. For packets of 1514bytes the accuracy is quiet good.
I'm using kernel 2.6.25

My 'tc -s -d class ls dev eth1' output:

class htb 1:10 parent 1:2 rate 1000Mbit ceil 1000Mbit burst 126375b/8
mpu 0b overhead 0b cburst 126375b/8 mpu 0b overhead 0b level 5
=A0Sent 51888579644 bytes 62067679 pkt (dropped 0, overlimits 0 requeue=
s 0)
=A0rate 653124Kbit 97656pps backlog 0b 0p requeues 0
=A0lended: 0 borrowed: 0 giants: 0
=A0tokens: 113 ctokens: 113

class htb 1:1 root rate 1000Mbit ceil 1000Mbit burst 126375b/8 mpu 0b
overhead 0b cburst 126375b/8 mpu 0b overhead 0b level 7
=A0Sent 51888579644 bytes 62067679 pkt (dropped 0, overlimits 0 requeue=
s 0)
=A0rate 653123Kbit 97656pps backlog 0b 0p requeues 0
=A0lended: 0 borrowed: 0 giants: 0
=A0tokens: 113 ctokens: 113

class htb 1:2 parent 1:1 rate 1000Mbit ceil 1000Mbit burst 126375b/8
mpu 0b overhead 0b cburst 126375b/8 mpu 0b overhead 0b level 6
=A0Sent 51888579644 bytes 62067679 pkt (dropped 0, overlimits 0 requeue=
s 0)
=A0rate 653124Kbit 97656pps backlog 0b 0p requeues 0
=A0lended: 0 borrowed: 0 giants: 0
=A0tokens: 113 ctokens: 113

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
=A0Sent 51888579644 bytes 62067679 pkt (dropped 27801917, overlimits 0 =
requeues 0)
=A0rate 653124Kbit 97656pps backlog 0b 0p requeues 0
=A0lended: 62067679 borrowed: 0 giants: 0
=A0tokens: -798 ctokens: -798

As you can see, class htb 1:108 rate's is 653124Kbit! Much bigger that
it's ceil.

I also note that, for HTB rate configurations over 500Mbit/s on leaf
class, when I stop the traffic, in the output of "tc -s -d class ls
dev eth1" command, I see that leaf's rate (in bits/s) is growing
instead of decreasing (as expected since I've stopped the traffic).
Rate in pps is ok and decreases until 0pps. Rate in bits/s increases
above 1000Mbit and stays there for a few minutes. After two or three
minutes it becomes 0bit. The same happens for it's ancestors (also for
root class).Here's tc output of my leaf class for this situation:

class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
=A0Sent 120267768144 bytes 242475339 pkt (dropped 62272599, overlimits =
0
requeues 0)
=A0rate 1074Mbit 0pps backlog 0b 0p requeues 0
=A0lended: 242475339 borrowed: 0 giants: 0
=A0tokens: 8 ctokens: 8


=A0 Antonio Almeida
