From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 06:33:17 -0700
Message-ID: <1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35976 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbbE0NdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 09:33:19 -0400
Received: by iepj10 with SMTP id j10so13302048iep.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 06:33:19 -0700 (PDT)
In-Reply-To: <CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 00:09 -0700, Gopakumar Choorakkot Edakkunni wrote:
> Hi Eric,
> 
> Thanks a lot for the response, and sorry about the 3-times-email, was
> not sure whether majordomo accepted my subscription or not and hence
> the retx :)
> 
> So if a sequence happens as below
> 
> 1. Client sends the first SYN with some TSval X
> 2. Server responds SYN-ACK with TSecr X
> 3. The SYN-ACK just gets dropped on the way back to the client
> 4. Client sends a SYN retry after N seconds with a new TSval Y
> 5. Server responds SYN-ACK with TSecr X

This not what happens.

Here is the problem I think :

1. Client sends the first SYN with some TSval X

Then application canceled the connect(), like doing a close() or exit()
or core dump.

RST packet is sent. But lost by the network.

<~20 seconds later>  port is reused by client doing another
socket()/connect(same target). We have only ~30000 available source
port, so they are going to be reused at some point, depending on the
number of ports in use.

1. Client sends another SYN with Tsval X+20000.


2. Server responds SYN-ACK with TSecr X because it did not forget about
original SYN.
3. The SYN-ACK is dropped by client because of PAWS (RFC 7323)

> 
> And if there is some firewall in between in the amazon environment
> where the firewall expects to see the SYN-ACK with TSecr Y, then I
> guess it matches the problem I saw ? In my case clearly the SYN-ACKs
> never reached the client no matter how many times they were
> retransmitted. So this would mean that if there is such a wierd
> firewall in between, then one missing SYN-ACK can cause the tcp
> connection to eventually timeout ! This of course is just guesswork
> based on what we saw as the behaviour from tcpdump on server and
> client side when the timeouts were happening. Does this sound like a
> possibility - has anyone come across "interesting" firewalls like this
> ?
> 
> And about your question: "Are you establishing many active sessions
> per minute to this particular target ?" - in my particular case there
> were not more than three linux client boxes sitting behind a NAT
> (sharing the same public IP) and talking to the same server. And each
> client box opens a tcp socket once in 30 seconds to the server. So the
> number of active sessions per 30 seconds is not more than 3 sessions.
> Now if the NAT device had some bug and ended up NAT-ing more than one
> client SYN packet to the same source port, then of course thats
> another theory for why this TSecr/TSval mismatch can happen (other
> than the SYN-ACK drop theory above).

I really not think a NAT is  the problem here.

The problem is in linux code itself. Please try the patch I sent ?
(On the client)

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
