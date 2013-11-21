From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 65271] New: Acceptable RST packets (with seq number in
 window) are ignored in LAST_ACK state (and previously sent data pending
 acknowledgement)
Date: Wed, 20 Nov 2013 17:35:43 -0800
Message-ID: <1384997743.10637.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131120122211.386c9680@nehalam.linuxnetplumber.net>
	 <1384980072.10637.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: julien.delacroix@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57003 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab3KUBfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:35:45 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so4897307pde.0
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 17:35:44 -0800 (PST)
In-Reply-To: <1384980072.10637.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 12:41 -0800, Eric Dumazet wrote:
> On Wed, 2013-11-20 at 12:22 -0800, Stephen Hemminger wrote:
> > 
> > Begin forwarded message:
> > 
> > Date: Wed, 20 Nov 2013 07:03:59 -0800
> > From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> > To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> > Subject: [Bug 65271] New: Acceptable RST packets (with seq number in window) are ignored in LAST_ACK state (and previously sent data pending acknowledgement)
> > 
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=65271
> > 
> >             Bug ID: 65271
> >            Summary: Acceptable RST packets (with seq number in window) are
> >                     ignored in LAST_ACK state (and previously sent data
> >                     pending acknowledgement)
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.32.59-0.7-default
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >           Assignee: shemminger@linux-foundation.org
> >           Reporter: julien.delacroix@gmail.com
> >         Regression: No
> > 
> > Created attachment 115271
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=115271&action=edit
> > TCP dump showing described scenario
> > 
> > PCAP file of traffic capture is attached.
> > Note that capture was taken directly on server host, so RST packets definitely
> > reached the server host.
> > 
> > 
> > Here is the flow:
> > 
> > 1: Client ---- SYN ----> Server
> > 2: Client <- SYN, ACK -- Server
> > 3: Client ---- ACK ----> Server 
> > 4: Client ---- FIN ----> Server ( server in CLOSE_WAIT state)
> > 5: Client <- PSH, ACK -- Server 
> > 6: Client <- FIN, ACK -- Server ( server in LAST_ACK state)
> > 
> > 7: Client ---- RST ----> Server 
> > 
> > Then repeat N times:
> >     8: Client <- PSH, ACK -- Server 
> >     9: Client ---RST, ACK -> Server 
> > 
> > 
> > Notes:
> > 5: packet contains 3 bytes of data
> > 7: no ACK flag, and sequence number is correct, but RST packet is ignored
> > 8: retransmission of step 5
> > 9: the sequence number is correct as well as the acknowledgment number
> > (acknowledging data in 5, but not yet FIN in 6), but this RST is again ignored.
> > 
> > From this point client keeps retransmitting 5, while server keeps answering
> > with acceptable RST packets.
> > 
> > You can observe this scenario (with 5 retransmissions and 5 RST) in the
> > attached PCAP file.
> > 
> 
> Thanks for the report, you'll take a look.
> 

I could not reproduce the issue here (using latest David Miller net
tree) :

17:28:57.643335 IP 192.0.2.1.47104 > 192.168.0.1.8080: Flags [S], seq 0, win 32792, options [mss 1460,sackOK,nop,nop,nop,wscale 7], length 0
17:28:57.643382 IP 192.168.0.1.8080 > 192.0.2.1.47104: Flags [S.], seq 3351683989, ack 1, win 29200, options [mss 1460,nop,nop,sackOK,nop,wscale 6], length 0
17:28:57.743309 IP 192.0.2.1.47104 > 192.168.0.1.8080: Flags [.], ack 1, win 257, length 0
17:28:57.753309 IP 192.0.2.1.47104 > 192.168.0.1.8080: Flags [F.], seq 1, ack 1, win 46, length 0
17:28:57.754053 IP 192.168.0.1.8080 > 192.0.2.1.47104: Flags [.], ack 2, win 457, length 0
17:28:57.793318 IP 192.168.0.1.8080 > 192.0.2.1.47104: Flags [P.], seq 1:4, ack 2, win 457, length 3
17:28:57.794279 IP 192.168.0.1.8080 > 192.0.2.1.47104: Flags [F.], seq 4, ack 2, win 457, length 0
17:28:57.843310 IP 192.0.2.1.47104 > 192.168.0.1.8080: Flags [R], seq 4168304244, win 0, length 0
17:28:58.295101 IP 192.168.0.1.8080 > 192.0.2.1.47104: Flags [P.], seq 1:4, ack 2, win 457, length 3
17:28:58.710341 IP 192.0.2.1.47104 > 192.168.0.1.8080: Flags [R.], seq 2, ack 4, win 0, length 0

Note that first RST is ignored as its sequence number is out of window.

But the 2nd one is correctly taken by TCP stack

I suspect a netfilter bug (conntrack), 'accepting' the buggy RST packet,
and blocking the other RST.


packetdrill scenario I cooked was :

`../common/defaults.sh`

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4

// Receive FIN segment.
0.210 < F. 1:1(0) ack 1 win 46

// Send one ACK.
+0    > . 1:1(0) ack 2

// Application writes 3 bytes.
0.250 write(4, ..., 3) = 3
+0    > P. 1:4(3) ack 2

0.251 shutdown(4, 2) = 0
+0    > F. 4:4(0) ack 2

// RST : it is ignored because its sequence is out of window
0.300 < R 4168304244:4168304244(0) win 0

// retransmit
0.751 > P. 1:4(3) ack 2

// This RST is OK and accepted
1.167 < R. 2:2(0) ack 4 win 0


// This retransmit should not happen
4.166 > P. 1:4(3) ack 2
