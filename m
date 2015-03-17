From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: No SO_BUSY_POLL for UDP?
Date: Tue, 17 Mar 2015 16:20:01 -0700
Message-ID: <1426634401.11398.245.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5508AA13.3030401@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Lukas Erlacher <erlacher@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33099 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425AbbCQXUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 19:20:04 -0400
Received: by iecvj10 with SMTP id vj10so25228651iec.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 16:20:03 -0700 (PDT)
In-Reply-To: <5508AA13.3030401@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-17 at 23:26 +0100, Lukas Erlacher wrote:
> Hello netdev,
> 
> I am trying to benchmark SO_BUSY_POLL and it appears not to be functioning with UDP.
> 
> I have been trying with netperf as well as with a small udp echo server and a load generator; I am trying to reproduce the Intel benchmarks[1] so I am using X520 NICs with rx-usecs set to 100.
> 
> Performing TCP_RR netperf test with /proc/sys/net/core/busy_{read,poll} set to 0 produces this:
> 
> > root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t TCP_RR -l 5
> > MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate
> > bytes  Bytes  bytes    bytes   secs.    per sec
> >
> > 16384  87380  1        1       5.00     9762.51
> 
> With busy_* set to 50 produces this:
> 
> > root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t TCP_RR -l 5
> > MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate
> > bytes  Bytes  bytes    bytes   secs.    per sec
> >
> > 16384  87380  1        1       5.00     42127.63
> > 16384  87380
> 
>  From that I conclude that the system manages 9700 round-trips per second without busy poll set and 42127 with busy poll enabled. So, busy polling works with TCP.
> 
> However, no matter what busy_* is set to, UDP_RR produces this:
> 
> > root@klaipeda ~/MoonGen (git)-[master] # netperf -H 192.168.1.2,udpv4 -t UDP_RR -l 5
> > MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.2 () port 0 AF_INET : demo : first burst 0
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate
> > bytes  Bytes  bytes    bytes   secs.    per sec
> >
> > 212992 212992 1        1       5.00     9763.20
> > 212992 212992
> 
> Around 9700 round-trips per second no matter the busy_poll setting.
> 
> The Intel whitepaper on busy polling[1] shows a UDP benchmark, so I am assuming that busy polling should be available for UDP sockets. Is this a regression or was the feature intentionally removed? As best I can tell the behaviour is identical on kernels 3.11, 3.16 and 3.19, but on 3.11 and 3.16 I have only tested it with my custom udp echo server.
> 
> Best regards,
> Lukas Erlacher
> 
> [1] http://www.intel.in/content/dam/www/public/us/en/documents/white-papers/open-source-kernel-enhancements-paper.pdf


busypoll should be available on _connected_ UDP sockets. Otherwise, we
would have to look all RX queues of the NIC, not a single one.

Try netperf  -t UDP_RR -- -N -n

    -n                Use the connected socket for UDP locally
    -N                Use the connected socket for UDP remotely

(Although I believe netserver->netperf is ignoring the -N option, that
is a netperf bug)

check with ss -a|grep udp
