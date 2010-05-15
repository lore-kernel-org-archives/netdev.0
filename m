From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Weird TCP retransmit behaviour in recent kernels
Date: Sun, 16 May 2010 01:45:11 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005160118240.30522@melkinpaasi.cs.helsinki.fi>
References: <alpine.LNX.2.00.1005141815560.3517@pentagram.it.hurts.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Michael Smith <michael@hurts.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59071 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab0EOWpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 May 2010 18:45:13 -0400
In-Reply-To: <alpine.LNX.2.00.1005141815560.3517@pentagram.it.hurts.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 May 2010, Michael Smith wrote:

> I'm struggling with TCP sessions stalling when Windows XP SP2 clients
> connect to a SUSE Linux Enterprise 11 server (kernel 2.6.27.x). The
> problem doesn't occur with kernel 2.6.18.8 on the server, and I'm
> wondering if something's changed since then in the retransmit logic.
> 
> It seems like when consecutive packets are lost, the SLES11
> server retransmits the first packet when the timeout fires. The client
> ACKs, but the server doesn't retransmit the next lost packet; instead,
> it sends a couple more new packets,

Which is expected and desired change, known as FRTO (RFC 5682).

> which don't get ACKed.

This is where your problem is, they should get acked in a _compliant_ 
network (with duplicate ACKs).

> The new packets don't show up in Wireshark - either something in the 
> network is dropping them,

There's some non-compliant middlebox in the network?

> or maybe Windows doesn't forward them to WinPcap because
> there's a hole in the sequence. The timeout fires again after double
> the time, and the second packet is retransmitted and ACKed, then
> more brand new packets are sent out. The transfer quickly grinds to a
> halt.
>
> There's a WAN and VPN between the clients and the server. HTTP downloads
> from the server stall at various points depending on the client. The
> point at which the connection stalls seems to be dependent on latency.
> For example, if the RTT to the client is 12 ms, the connection might
> usually stall after 120 KB; if it's 20 ms, it might stall at 1200 KB.
> 
> The problem doesn't occur when a Windows client talks to a Windows
> server.  When a Linux client talks to the SLES11 server, the connection
> doesn't stall completely but slows to a crawl (~3 KB/sec, as opposed to
> typical 50-200 KB/sec).
> 
> I was able to work around the problem for most clients by locking the
> TCP congestion window to a maximum of 6 on the SLES11 server. Some sites
> are pathologically bad and the connection stalls unless I lock the
> congestion window to 1 (!!).
> 
> I've put up a couple of sample traces from a pathological site where
> the problem shows up with cwnd locked to 3:
> 
> http://www.hurts.ca/sles11.router.pcap.gz - view from the server's firewall
> http://www.hurts.ca/sles11.windows.pcap.gz - view from a client PC
> 
> On the firewall, you can see the problem around packets 93-104. The server
> sends sequence 66781, 68041, 69301; retransmits 66781, gets an ACK, then
> sends 70561, 71821; retransmits 68041, gets an ACK, then sends 73081,
> 74341, and so on. On the client, the "future" sequence packets after
> the ACK never show up in Wireshark.
> 
> I've tried all of the obvious things:
> - disabling TCP segment/checksum offloading functions on client and server;
> - disabling SACK;
> - trying all available congestion control algorithms on SLES11
>   (cubic, reno, veno, illinois);
> - turning off anti-virus on the client.
> 
> The only 100% reliable workaround seems to be to proxy the connections
> through a kernel 2.6.18.8 machine on the same subnet. It seems like
> the problem exists with a vanilla 2.6.31 kernel, too.
> 
> Has anyone seen something like this before? Any ideas where to go next? I'm
> pretty sure there's nothing strange in the network - just plain old Cisco
> routers and site-to-site VPNs.

Some have seen similar phenomena, every time it has been fault in some 
middlebox/peer that does not do what it should. You can disable frto 
using tcp_frto sysctl if you like, however, I disagree with you as I'm 
pretty sure there is some broken middlebox in the network (which is trying 
to be too intelligent).

-- 
 i.
