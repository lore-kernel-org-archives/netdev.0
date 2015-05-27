From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 00:08:38 -0700
Message-ID: <1432710518.4060.363.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36170 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbbE0HIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 03:08:41 -0400
Received: by iepj10 with SMTP id j10so6866474iep.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 00:08:40 -0700 (PDT)
In-Reply-To: <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 23:23 -0700, Eric Dumazet wrote:
> On Tue, 2015-05-26 at 23:12 -0700, Eric Dumazet wrote:
> > On Tue, 2015-05-26 at 22:47 -0700, Gopakumar Choorakkot Edakkunni wrote:
> > > All,
> > > 
> > > The original query I had posted is here :
> > > http://stackoverflow.com/questions/30414350/tcp-syn-ack-tsecr-not-matching-tsval-in-syn
> > > .. The summary is that once in a while, the TSval in SYN is not what
> > > is getting echoed in TSecr, and looks like something on amazon aws
> > > side is very strict about that and drops those packets. Any clues on
> > > this - whether its a known issue/fixed elsewhere etc. would be of
> > > great help.
> > 
> > I guess that if you send SYN packets 3 times as your email did on
> > netdev, that might cause some issues...
> > 
> > More seriously, server has a SYN_RECV socket with same tuple, because of
> > a SYN sent earlier :
> > 
> > 8:36:00.593136 IP XX.YY.ZZ.VV.24548 > AA.BB.CC.DD.443: Flags [S], seq
> > 1204544933, win 29200, options [mss 1320,sackOK,TS val 6032576 ecr
> > 0,nop,wscale 7], length 0
> > 
> > 18:36:00.593171 IP AA.BB.CC.DD.443 > XX.YY.ZZ.VV.24548: Flags [S.], seq
> > 986069863, ack 1204544934, win 14480, options [mss 1460,sackOK,TS val
> > 180940028 ecr 6001497,nop,wscale 5], length 0
> > 
> > 18:36:00.992699 IP AA.BB.CC.DD.443 > XX.YY.ZZ.VV.24548: Flags [S.], seq
> > 986069863, ack 1204544934, win 14480, options [mss 1460,sackOK,TS val
> > 180940128 ecr 6001497,nop,wscale 5], length 0
> > 
> > 
> > From these traces, we can guess a SYN packet was sent about 31 seconds
> > earlier.
> > 
> > SYNACK rtx do not update the TSECR : Initial SYN TSval value (6001497)
> > is mirrored.
> > 
> > Are you establishing many active sessions per minute to this particular
> > target ?
> > 
> 
> Here is a packetdrill test to demonstrate behavior :
> 
> // Test that SYNACK rtx tsecr is not changed (original SYN tsval)
> 
> `../common/defaults.sh
> `
> 
> // Create a socket.
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 
> 0.000 bind(3, ..., ...) = 0
> 0.000 listen(3, 1) = 0
> 
> // Establish a connection.
> 0.100 < S 0:0(0) win 20000 <mss 1000,sackOK,TS val 100 ecr 0>
> +0    > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 100 ecr 100>
> 
> +0.100 < S 0:0(0) win 20000 <mss 1000,sackOK,TS val 199 ecr 0>
> // check rtx tsecr is sill 100, not 199
> +0     > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 200 ecr 100>
> 
> +0.100 < . 1:1(0) ack 1 win 20000 <nop,nop,TS val 300 ecr 200>
> +0    accept(3, ..., ...) = 4
> 

Reading again https://tools.ietf.org/html/rfc7323#section-4.3 

I am not sure we do the right thing here. :(

Yuchung, Neal, what do you think ?

If we receive a SYN matching an existing SYN_RECV, should we update
TS.recent with latest SYN.tsval ? I see nothing wrong with that.

Patch would be :

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index df7fe3c31162e77b96f81399ef7d893485ab3d91..70db6572d241e132c28c381dfc1155b150c9557b 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -588,6 +588,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (TCP_SKB_CB(skb)->seq == tcp_rsk(req)->rcv_isn &&
 	    flg == TCP_FLAG_SYN &&
 	    !paws_reject) {
+		if (tmp_opt.saw_tstamp &&
+		    after(tmp_opt.rcv_tsval, req->ts_recent))
+			req->ts_recent = tmp_opt.rcv_tsval;
 		/*
 		 * RFC793 draws (Incorrectly! It was fixed in RFC1122)
 		 * this case on figure 6 and figure 8, but formal


And updated packetdrill test would be :
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
// check rtx tsecr is 199, not 100
+0     > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 200 ecr 199>

+0.100 < . 1:1(0) ack 1 win 20000 <nop,nop,TS val 300 ecr 200>
+0    accept(3, ..., ...) = 4
