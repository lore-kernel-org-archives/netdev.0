From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Wed, 21 Jan 2015 09:01:56 -0800
Message-ID: <1421859716.4832.27.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54BEA91D.1050001@hp.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAD027E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Rick Jones' <rick.jones2@hp.com>, Dave Taht <dave.taht@gmail.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:50472 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbAURCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 12:02:01 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so2280368igb.2
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 09:02:00 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD027E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-21 at 12:26 +0000, David Laight wrote:
> From: Of Rick Jones
> > >> Are you saying that at long last, delayed acks as we knew them are
> > >> dead, dead, dead?
> > >
> > > Sorry, I can not parse what you are saying.
> > >
> > > In case you missed it, it has nothing to do with delayed ACK but GRO on
> > > receiver.
> > 
> > Dave - assuming I've interpreted Eric's comments correctly, I believe
> > the answer to your question is No.  Your desire for a world brimming
> > with ack-every-other purity has not been fulfilled :)
> > 
> > However, the engineers formerly at Mentat are probably pleased that a
> > functional near-equivalent to their ACK avoidance heuristic has ended-up
> > being implemented and tacitly accepted, albeit by the back door :)
> 
> I must recheck something I discovered a while back with more recent kernels.
> There has been a bad interaction between 'slow start' and 'delayed acks'
> when nagle is disabled on 0 RTT local links with uni-directional traffic.
> 
> 'Slow start' would refuse to send more than 4 messages until it received
> an ack (rather than 4 mss of data).
> The receiving system wouldn't send an ack until the timer expired
> (or several mss of data were received) by which time the sender could have
> a lot of data queued.
> 
> Due to the 0 RTT and bursty nature of the data 'slow start' happened
> all the time.

Following packetdrill test suggests that current kernel send up to 10
messages without having to wait for any ACK
(IW10)

// Set up production and experiment configs
`../common/defaults.sh`

// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 6>
0.110 < . 1:1(0) ack 1 win 257
0.110 accept(3, ..., ...) = 4

0.200 %{ assert tcpi_snd_cwnd == 10 }%
+0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

+0.01 write(4, ..., 100) = 100
+0  > P. 1:101(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 101:201(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 201:301(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 301:401(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 401:501(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 501:601(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 601:701(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 701:801(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 801:901(100) ack 1

+0.01 write(4, ..., 100) = 100
+0  > P. 901:1001(100) ack 1
