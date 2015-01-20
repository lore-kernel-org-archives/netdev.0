From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Mon, 19 Jan 2015 19:14:11 -0800
Message-ID: <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	 <54B590FB.5040805@dev.mellanox.co.il>
	 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
	 <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54BC286B.8000605@mellanox.com>
	 <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:41179 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbbATDOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 22:14:14 -0500
Received: by mail-ig0-f177.google.com with SMTP id h15so7223780igd.4
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 19:14:14 -0800 (PST)
In-Reply-To: <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-19 at 18:37 -0800, Dave Taht wrote:
> On Mon, Jan 19, 2015 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2015-01-18 at 23:40 +0200, Eyal Perry wrote:
> >
> >> So indeed, interrupt mitigation (tx-usecs 1 tx-frames 1) improves things up
> >> for the "refined TSO autosizing" kernel (from 18.4Gbps to 19.7Gbps). but
> >> in the
> >> other kernel, the BW is remains the same with and without the coalescing.
> >
> > OK thanks for testing.
> >
> > I believe the regression comes from inability for cc to cope with
> > stretch acks.
> >
> > Nowadays on fast networks, each ACK packet acknowledges ~45 MSS, but
> > CUBIC (and others cc) got support for this only during slow start, with
> > commit 9f9843a751d0a2057f9f3d313886e7e5e6ebaac9
> > ("tcp: properly handle stretch acks in slow start")
> >
> > I guess it is time to also handle congestion avoidance phase.
> 
> Are you saying that at long last, delayed acks as we knew them are
> dead, dead, dead?

Sorry, I can not parse what you are saying.

In case you missed it, it has nothing to do with delayed ACK but GRO on
receiver.


> 
> > With following patch (very close to what we use here at Google) I
> > reached 37Gbps instead of 20Gbps :
> >
> > ethtool -C eth1 tx-usecs 4 tx-frames 4
> 
> What is the default here?

16 & 16, see my prior answer in this thread.

> 
> What happens with the default here?

ethtool -C eth1 tx-usecs 16 tx-frames 16
DUMP_TCP_INFO=1 ./netperf -H remote -T2,2 -t TCP_STREAM -l 20
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to remote
() port 0 AF_INET : cpu bind
rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=60 rttvar=2
snd_ssthresh=179 cwnd=243 reordering=3 total_retrans=23 ca_state=0
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    20.00    22923.74   




> 
> >
> > DUMP_TCP_INFO=1 ./netperf -H remote -T2,2 -t TCP_STREAM -l 20
> > MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to remote () port 0 AF_INET : cpu bind
> > rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=67 rttvar=6 snd_ssthresh=263 cwnd=265 reordering=3 total_retrans=4569 ca_state=0
> 
> The above statistics are not dumped by my netperf, and look extremely
> desirable to capture in netperf-wrapper. This is a script parsing some
> other kernel data at the conclusion of the run? or a better netperf?

Thats a 3 lines patch in netperf actually.

> 
> If ECN was on the bottleneck link, I imagine total_retrans would be 0,
> or are packets getting dropped in the kernel?

The receiver drops frames, because we are at the limit of what the NIC
can do on a single RX queue.
