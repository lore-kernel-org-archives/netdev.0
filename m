From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 right-most SACK block
Date: Tue, 7 Jun 2016 12:05:47 -0400
Message-ID: <CADVnQyn_AciWUFpOQdXPA97rih9JYkO8OZQUbC8+ADe0WiRoaA@mail.gmail.com>
References: <CADVnQymeArQhGTUFuTXQb4v3aabzseumybjpJ8UtTugnX=2=cA@mail.gmail.com>
 <1465309834-31942-1-git-send-email-pau.espin@tessares.net> <1465312861.24873.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pau Espin Pedrol <pau.espin@tessares.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34991 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161606AbcFGQGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 12:06:23 -0400
Received: by mail-oi0-f48.google.com with SMTP id s139so45096736oie.2
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 09:06:23 -0700 (PDT)
In-Reply-To: <1465312861.24873.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 7, 2016 at 11:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-06-07 at 16:30 +0200, Pau Espin Pedrol wrote:
>> RFC 5961 advises to only accept RST packets containing a seq number
>> matching the next expected seq number instead of the whole receive
>> window in order to avoid spoofing attacks.
>
>> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

I verified that it passes the following packetdrill test, which is
based on the script posted by Pau in a recent thread on this topic.

Thanks!

neal

----

// Test that we accept an incoming RST if it matches the rightmost
// SACK block end.

0     socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

+0    < S 0:0(0) win 500 <mss 1460,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 win 29200 <mss 1460,nop,nop,sackOK,nop,wscale 7>
+0    < . 1:1(0) ack 1 win 500
+0    accept(3, ..., ...) = 4

// First roundtrip of data client->server (upload)
+0    < P. 1:1001(1000) ack 1 win 500
+0    > . 1:1(0) ack 1001

// A packet arrives without prev packet being seen.
+0    < P. 5001:6001(1000) ack 1 win 500
+0    > . 1:1(0) ack 1001 <nop,nop,sack 5001:6001>

// Another out-of-order packet arrives.
+0    < P. 3001:4001(1000) ack 1 win 500
+0    > . 1:1(0) ack 1001 <nop,nop,sack 3001:4001 5001:6001>

// We send a challenge ACK for a RST matching the right edge of the
inner SACK block:
+0    < R. 4001:4001(0) ack 1 win 500
+0    > . 1:1(0) ack 1001 <nop,nop,sack 3001:4001 5001:6001>

// RST arrives from client, for instance caused by setsockopt(fd,
SOL_SOCKET, SO_LINGER, ...)
// Matches right edge of right-most SACK block, so we reset the connection.
+0    < R. 6001:6001(0) ack 1 win 500

// Verify that the RST caused the kernel to reset the connection:
+.010 write(4, ..., 10000) = -1 ECONNRESET (Connection reset by peer)

// Double-check  that the socket is gone:
+0    < P. 2001:3001(1000) ack 1 win 500
+0    > R 1:1(0) ack 0
