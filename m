From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Thu, 10 Dec 2009 10:24:32 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101019490.23376@melkinpaasi.cs.helsinki.fi>
References: <200912092051.18258.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53671 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760734AbZLJIY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:24:26 -0500
In-Reply-To: <200912092051.18258.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc Damian.

On Wed, 9 Dec 2009, Denys Fedoryshchenko wrote:

> Hi
> 
> I did upgrade of my lusca(squid) proxies and notice that some users getting up 
> to 8-15 Mbit/s flood (while they are shaped to 128Kbit/s). After tracing i end 
> up on  one of proxies host and seems it is bug in kernel tcp stack.
> 
> I check packets inside - it is same repeating content (and even same tcp 
> sequence, so it is almost sure tcp bug). Sender also ignoring ICMP unreachable 
> packets and continue flooding destination
>
> Here is some examples
> ss output for corresponding entry
> 
> ESTAB      0      8267        194.146.153.114:8080         172.16.67.243:2512
> 
> 
> 20:32:08.491470 IP (tos 0x0, ttl 64, id 49493, offset 0, flags [DF], proto TCP 
> (6), length 655)
>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0xce63 
> (correct), seq 0:615, ack 1, win 7504, length 615
> 20:32:08.492487 IP (tos 0x0, ttl 64, id 49494, offset 0, flags [DF], proto TCP 
> (6), length 655)
>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0xce63 
> (correct), seq 0:615, ack 1, win 7504, length 615
> 20:32:08.493468 IP (tos 0x0, ttl 64, id 49495, offset 0, flags [DF], proto TCP 
> (6), length 655)
>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0xce63 
> (correct), seq 0:615, ack 1, win 7504, length 615
> 20:32:08.494463 IP (tos 0x0, ttl 64, id 49496, offset 0, flags [DF], proto TCP 
> (6), length 655)
>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0xce63 
> (correct), seq 0:615, ack 1, win 7504, length 615
> 20:32:08.495463 IP (tos 0x0, ttl 64, id 49497, offset 0, flags [DF], proto TCP 
> (6), length 655)
>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0xce63 
> (correct), seq 0:615, ack 1, win 7504, length 615
> 20:32:08.496467 IP (tos 0x0, ttl 64, id 49498, offset 0, flags [DF], proto TCP 
> (6), length 655)
> 
> 
> One more
> 20:36:13.310718 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.311725 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.312729 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.313717 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.314717 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.315718 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 20:36:13.316725 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags [.], ack 1, 
> win 7469, length 1440
> 
> I run multiple times ss
> 
> ESTAB      0      7730        194.146.153.114:8080          172.16.49.30:1319   
> timer:(on,,172) uid:101 ino:4772596 sk:c0ce84c0
> ESTAB      0      7730        194.146.153.114:8080          172.16.49.30:1319   
> timer:(on,,43) uid:101 ino:4772596 sk:c0ce84c0
> ESTAB      0      7730        194.146.153.114:8080          172.16.49.30:1319   
> timer:(on,,17) uid:101 ino:4772596 sk:c0ce84c0
> 
> After i kill squid it will  switch socket to FIN-WAIT state and flood will 
> stop.
> 
> Some sysctl tuning done during boot (maybe related)
> sysctl -w net.ipv4.tcp_frto=2
> sysctl -w net.ipv4.tcp_frto_response=2
> 
> And most probably it is related to keepalive. I have it set on this socket:
> http_port 8080 transparent tcpkeepalive=30,30,60 http11                                                                                                                                                   
> 
> From manual
> #<----->   tcpkeepalive[=idle,interval,timeout]
> #<-----><------><------>Enable TCP keepalive probes of idle connections
> #<-----><------><------>idle is the initial time before TCP starts probing
> #<-----><------><------>the connection, interval how often to probe, and
> #<-----><------><------>timeout the time before giving up.
> 
> I am not able to reproduce reliably bug, but it is appearing on different 
> cluster pc's randomly for single connection each 5-10 minutes (around 8000 
> established connections to each at moment, 8 pc's in cluster) and dissapearing 
> after 10-50 seconds of flood.

Damian, can you please take a look. ...It's a bit weird after a very brief 
look (as if RTO would trigger way too often). Maybe its backoff is broken 
now?

-- 
 i.
