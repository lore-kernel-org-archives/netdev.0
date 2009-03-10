From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 20:55:15 -0700
Message-ID: <1e41a3230903092055q2317e0cas3721d18fb4cef062@mail.gmail.com>
References: <20090309112521.GB37984@bts.sk>
	 <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	 <20090309200505.GA58375@bts.sk>
	 <20090309.170927.130334650.davem@davemloft.net>
	 <49B5B5A7.8090502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, md@bts.sk,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f167.google.com ([209.85.217.167]:32995 "EHLO
	mail-gx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbZCJDzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 23:55:19 -0400
Received: by gxk11 with SMTP id 11so620604gxk.13
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 20:55:15 -0700 (PDT)
In-Reply-To: <49B5B5A7.8090502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 5:34 PM, Rick Jones <rick.jones2@hp.com> wrote:
> If I recall correctly, when I have asked about this behaviour in the =
past, I
> was told that the autotuning receiver would always try to offer the s=
ender
> 2X what the receiver thought the sender's cwnd happened to be. =A0Is =
my
> recollection incorrect, or is this then:
>
> [root@dl5855 ~]# netperf -t omni -H sut42 -- -k foo -s 128K
> OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sut42.west (10.208=
=2E0.45)
> port 0 AF_INET
> THROUGHPUT=3D941.30
> LSS_SIZE_REQ=3D131072
> LSS_SIZE=3D262142
> LSS_SIZE_END=3D262142
> RSR_SIZE_REQ=3D-1
> RSR_SIZE=3D87380
> RSR_SIZE_END=3D3900000
>
> not intended behaviour? =A0LSS =3D=3D Local Socket Send; RSR =3D=3D R=
emote Socket
> Receive. =A0dl5855 is running RHEL 5.2 (2.6.18-92.el5) sut42 is runni=
ng a
> nf-next-2.6 about two or three weeks old with some of the 32-core sca=
ling
> patches applied (2.6.29-rc5-nfnextconntrack)
>
> I'm assuming that by setting the SO_SNDBUF on the netperf (sending) s=
ide to
> 128K/256K that will be the limit on what it will ever put out onto th=
e
> connection at one time, but by the end of the 10 second test over the=
 local
> GbE LAN the receiver's autotuned SO_RCVBUF has grown to 3900000.


Hi Rick,

(Pretty sure we went over this already, but once more..)  The receiver
does not size to twice cwnd.  It sizes to twice the amount of data
that the application read in one RTT.  In the common case of a path
bottleneck and a receiving application that always keeps up, this
equals 2*cwnd, but the distinction is very important to understanding
its behavior in other cases.

In your test where you limit sndbuf to 256k, you will find that you
did not fill up the bottleneck queues, and you did not get a
significantly increased RTT, which are the negative effects we want to
avoid.  The large receive window caused no trouble at all.

  -John
