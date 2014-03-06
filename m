From: David Laight <David.Laight@ACULAB.COM>
Subject: Can I limit the number of active tx per TCP socket?
Date: Thu, 6 Mar 2014 12:28:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49301 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751724AbaCFM3a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 07:29:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24345-03 for <netdev@vger.kernel.org>;
 Thu,  6 Mar 2014 12:29:27 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it possible to stop a TCP connection having more than one
tx skb (in the ethernet tx ring) at any one time?
The idea is to allow time for short sends from the application
to accumulate so that the transmitted frames are longer.

Basically I have a TCP connection which carries a lot of separate
short 'user buffers'. These are not command-response so
TCP_NODELAY has to be set to avoid long delays. But this means
that the ethernet packet rate is very high - with 3.14 about
2000/sec even though the data rate is well under 1MB/sec.

Anything that reduces this packet rate will help the poor little
embedded ppc that has to receive them!

>From the descriptions I've found I suspect that setting a very
low TCP_NOTSENT_LOWAT (like 1 byte) might have other side effects.
I think that limits the writes into kernel memory - which isn't
really what I'm trying to do.

With a 3.14.0-rc5 kernel reducing the network speed to 10M (from Ge)
halves the number of transmitted packets (with the same aggregate
data rate). But I suspect it could still be reduced further.

Limiting the number of tx packets per TCP connection might also
help stop bulk transfers affecting low-latency connections,
especially if the throughput of individual connections isn't
especially important - as it may not be on a big ftp/web server.

Limiting the window size offered by the remote system won't help me.
The window needs to be large enough several full-sized packets, and
I'm trying to stop large numbers of very short packets being sent.

In this particular case the connection is local, but we have a similar
problem with sigtran m3ua traffic over sctp.
If we are sending 15000 sctp data chunks every second, with an average size
under 300 bytes (possibly nearer 150) then we really want to fill the
ethernet packets.
(That is a real data pattern, not a development test.)

	David
