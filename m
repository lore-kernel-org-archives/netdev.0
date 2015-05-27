From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Tue, 26 May 2015 23:23:30 -0700
Message-ID: <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:32968 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbE0GXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 02:23:32 -0400
Received: by iebgx4 with SMTP id gx4so6362942ieb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 23:23:32 -0700 (PDT)
In-Reply-To: <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 23:12 -0700, Eric Dumazet wrote:
> On Tue, 2015-05-26 at 22:47 -0700, Gopakumar Choorakkot Edakkunni wrote:
> > All,
> > 
> > The original query I had posted is here :
> > http://stackoverflow.com/questions/30414350/tcp-syn-ack-tsecr-not-matching-tsval-in-syn
> > .. The summary is that once in a while, the TSval in SYN is not what
> > is getting echoed in TSecr, and looks like something on amazon aws
> > side is very strict about that and drops those packets. Any clues on
> > this - whether its a known issue/fixed elsewhere etc. would be of
> > great help.
> 
> I guess that if you send SYN packets 3 times as your email did on
> netdev, that might cause some issues...
> 
> More seriously, server has a SYN_RECV socket with same tuple, because of
> a SYN sent earlier :
> 
> 8:36:00.593136 IP XX.YY.ZZ.VV.24548 > AA.BB.CC.DD.443: Flags [S], seq
> 1204544933, win 29200, options [mss 1320,sackOK,TS val 6032576 ecr
> 0,nop,wscale 7], length 0
> 
> 18:36:00.593171 IP AA.BB.CC.DD.443 > XX.YY.ZZ.VV.24548: Flags [S.], seq
> 986069863, ack 1204544934, win 14480, options [mss 1460,sackOK,TS val
> 180940028 ecr 6001497,nop,wscale 5], length 0
> 
> 18:36:00.992699 IP AA.BB.CC.DD.443 > XX.YY.ZZ.VV.24548: Flags [S.], seq
> 986069863, ack 1204544934, win 14480, options [mss 1460,sackOK,TS val
> 180940128 ecr 6001497,nop,wscale 5], length 0
> 
> 
> From these traces, we can guess a SYN packet was sent about 31 seconds
> earlier.
> 
> SYNACK rtx do not update the TSECR : Initial SYN TSval value (6001497)
> is mirrored.
> 
> Are you establishing many active sessions per minute to this particular
> target ?
> 

Here is a packetdrill test to demonstrate behavior :

// Test that SYNACK rtx tsecr is not changed (original SYN tsval)

`../common/defaults.sh
`

// Create a socket.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0

0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

// Establish a connection.
0.100 < S 0:0(0) win 20000 <mss 1000,sackOK,TS val 100 ecr 0>
+0    > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 100 ecr 100>

+0.100 < S 0:0(0) win 20000 <mss 1000,sackOK,TS val 199 ecr 0>
// check rtx tsecr is sill 100, not 199
+0     > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 200 ecr 100>

+0.100 < . 1:1(0) ack 1 win 20000 <nop,nop,TS val 300 ecr 200>
+0    accept(3, ..., ...) = 4
