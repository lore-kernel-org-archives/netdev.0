From: Michael Smith <michael@hurts.ca>
Subject: Weird TCP retransmit behaviour in recent kernels
Date: Fri, 14 May 2010 19:01:37 -0400 (EDT)
Message-ID: <alpine.LNX.2.00.1005141815560.3517@pentagram.it.hurts.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.rog.mail.re2.yahoo.com ([68.142.225.205]:20122 "HELO
	smtp107.rog.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751800Ab0ENXIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 19:08:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm struggling with TCP sessions stalling when Windows XP SP2 clients
connect to a SUSE Linux Enterprise 11 server (kernel 2.6.27.x). The
problem doesn't occur with kernel 2.6.18.8 on the server, and I'm
wondering if something's changed since then in the retransmit logic.

It seems like when consecutive packets are lost, the SLES11
server retransmits the first packet when the timeout fires. The client
ACKs, but the server doesn't retransmit the next lost packet; instead,
it sends a couple more new packets, which don't get ACKed. The new
packets don't show up in Wireshark - either something in the network is
dropping them, or maybe Windows doesn't forward them to WinPcap because
there's a hole in the sequence. The timeout fires again after double
the time, and the second packet is retransmitted and ACKed, then
more brand new packets are sent out. The transfer quickly grinds to a
halt.

There's a WAN and VPN between the clients and the server. HTTP downloads
from the server stall at various points depending on the client. The
point at which the connection stalls seems to be dependent on latency.
For example, if the RTT to the client is 12 ms, the connection might
usually stall after 120 KB; if it's 20 ms, it might stall at 1200 KB.

The problem doesn't occur when a Windows client talks to a Windows
server.  When a Linux client talks to the SLES11 server, the connection
doesn't stall completely but slows to a crawl (~3 KB/sec, as opposed to
typical 50-200 KB/sec).

I was able to work around the problem for most clients by locking the
TCP congestion window to a maximum of 6 on the SLES11 server. Some sites
are pathologically bad and the connection stalls unless I lock the
congestion window to 1 (!!).

I've put up a couple of sample traces from a pathological site where
the problem shows up with cwnd locked to 3:

http://www.hurts.ca/sles11.router.pcap.gz - view from the server's firewall
http://www.hurts.ca/sles11.windows.pcap.gz - view from a client PC

On the firewall, you can see the problem around packets 93-104. The server
sends sequence 66781, 68041, 69301; retransmits 66781, gets an ACK, then
sends 70561, 71821; retransmits 68041, gets an ACK, then sends 73081,
74341, and so on. On the client, the "future" sequence packets after
the ACK never show up in Wireshark.

I've tried all of the obvious things:
- disabling TCP segment/checksum offloading functions on client and server;
- disabling SACK;
- trying all available congestion control algorithms on SLES11
   (cubic, reno, veno, illinois);
- turning off anti-virus on the client.

The only 100% reliable workaround seems to be to proxy the connections
through a kernel 2.6.18.8 machine on the same subnet. It seems like
the problem exists with a vanilla 2.6.31 kernel, too.

Has anyone seen something like this before? Any ideas where to go next? 
I'm pretty sure there's nothing strange in the network - just plain old 
Cisco routers and site-to-site VPNs.

Thanks,
Mike

PS: the frame with the HTTP request will show as having a bad checksum
because I hand edited the IP in the Host: header, poorly. Also, the
transfer recovered briefly about 231 seconds in - I couldn't figure out
why, but the SLES11 server finally filled in the sequence hole for a
bit.
