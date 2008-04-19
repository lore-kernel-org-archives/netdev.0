From: Jiri Kosina <jkosina@suse.cz>
Subject: TCP_NODELAY vs. skb coalescing
Date: Sat, 19 Apr 2008 03:45:02 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804190337180.12972@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40640 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751320AbYDSBpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 21:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a trivial small test application -- basically all it does is that 
it creates a socket, sets TCP_NODELAY on it, and waits for connections. 
Once the client is connected, it write()s a small amount of data 
(approximately 150 bytes) in a loop for quite some time, and then closes 
the connection.

Now, tcpdump shows:

02:01:35.387623 IP 10.20.10.52.60883 > 10.20.1.91.26714: S 822453287:822453287(0) win 5840 <mss 1460,sackOK,timestamp 10263632 0,nop,wscale 6>
02:01:35.401620 IP 10.20.1.91.26714 > 10.20.10.52.60883: S 2660510287:2660510287(0) ack 822453288 win 5792 <mss 1116,sackOK,timestamp 159602566 10263632,nop,wscale 5>
02:01:35.401707 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 1 win 92 <nop,nop,timestamp 10263635 159602566>
02:01:35.413271 IP 10.20.1.91.26714 > 10.20.10.52.60883: P 1:180(179) ack 1 win 181 <nop,nop,timestamp 159602569 10263635>
02:01:35.413412 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 180 win 108 <nop,nop,timestamp 10263638 159602569>
02:01:35.413623 IP 10.20.1.91.26714 > 10.20.10.52.60883: P 180:359(179) ack 1 win 181 <nop,nop,timestamp 159602569 10263635>
02:01:35.413648 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 359 win 125 <nop,nop,timestamp 10263638 159602569>
02:01:35.414947 IP 10.20.1.91.26714 > 10.20.10.52.60883: P 359:538(179) ack 1 win 181 <nop,nop,timestamp 159602569 10263635>
02:01:35.414973 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 538 win 142 <nop,nop,timestamp 10263638 159602569>
02:01:35.427492 IP 10.20.1.91.26714 > 10.20.10.52.60883: . 538:1642(1104) ack 1 win 181 <nop,nop,timestamp 159602572 10263638>
02:01:35.427565 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 1642 win 187 <nop,nop,timestamp 10263642 159602572>
02:01:35.431643 IP 10.20.1.91.26714 > 10.20.10.52.60883: . 1642:2746(1104) ack 1 win 181 <nop,nop,timestamp 159602572 10263638>
02:01:35.431856 IP 10.20.1.91.26714 > 10.20.10.52.60883: . 2746:3850(1104) ack 1 win 181 <nop,nop,timestamp 159602572 10263638>
02:01:35.432900 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 2746 win 232 <nop,nop,timestamp 10263643 159602572>
02:01:35.432915 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 3850 win 278 <nop,nop,timestamp 10263643 159602572>
02:01:35.434594 IP 10.20.1.91.26714 > 10.20.10.52.60883: . 3850:4954(1104) ack 1 win 181 <nop,nop,timestamp 159602572 10263638>
02:01:35.434625 IP 10.20.10.52.60883 > 10.20.1.91.26714: . ack 4954 win 323 <nop,nop,timestamp 10263643 159602572>

i.e. first three PUSH packets seem to be sent immediately, but after that 
TCP switches to buffering the requests into larger chunks (1104 size, no 
PUSH flag set), which I wouldn't expect with TCP_NODELAY. It seems to me 
like some form of Nagle is still active.

When I slightly increase a delay between the write() calls in the loop, 
this coalescing goes away completely, and only the small packets are sent, 
which is behavior I would expect in all cases when Nagle is turned off.

Is this known/expected behavior?

Thanks,

-- 
Jiri Kosina
