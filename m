From: Lukas Erlacher <erlacher@in.tum.de>
Subject: No SO_BUSY_POLL for UDP?
Date: Tue, 17 Mar 2015 23:26:27 +0100
Message-ID: <5508AA13.3030401@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.informatik.tu-muenchen.de ([131.159.0.8]:42874 "EHLO
	mail-out1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932730AbbCQWee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 18:34:34 -0400
Received: (Authenticated sender: erlacher)
	by mail.in.tum.de (Postfix) with ESMTPSA id 7236A2400EB
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 23:26:29 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

I am trying to benchmark SO_BUSY_POLL and it appears not to be functioning with UDP.

I have been trying with netperf as well as with a small udp echo server and a load generator; I am trying to reproduce the Intel benchmarks[1] so I am using X520 NICs with rx-usecs set to 100.

Performing TCP_RR netperf test with /proc/sys/net/core/busy_{read,poll} set to 0 produces this:

> root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t TCP_RR -l 5
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       5.00     9762.51

With busy_* set to 50 produces this:

> root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t TCP_RR -l 5
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       5.00     42127.63
> 16384  87380

 From that I conclude that the system manages 9700 round-trips per second without busy poll set and 42127 with busy poll enabled. So, busy polling works with TCP.

However, no matter what busy_* is set to, UDP_RR produces this:

> root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t UDP_RR -l 5
> MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 212992 212992 1        1       5.00     9763.20
> 212992 212992

Around 9700 round-trips per second no matter the busy_poll setting.

The Intel whitepaper on busy polling[1] shows a UDP benchmark, so I am assuming that busy polling should be available for UDP sockets. Is this a regression or was the feature intentionally removed? As best I can tell the behaviour is identical on kernels 3.11, 3.16 and 3.19, but on 3.11 and 3.16 I have only tested it with my custom udp echo server.

Best regards,
Lukas Erlacher

[1] http://www.intel.in/content/dam/www/public/us/en/documents/white-papers/open-source-kernel-enhancements-paper.pdf
