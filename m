From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 08:32:13 +0200
Message-ID: <1340778733.2028.110.camel@localhost>
References: <1340440962.17495.39.camel@edumazet-glaptop>
	 <1340686296.10893.115.camel@edumazet-glaptop>
	 <20120625.215537.169465424900682764.davem@davemloft.net>
	 <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	David Miller <davem@davemloft.net>,
	"subramanian.vijay@gmail.com" <subramanian.vijay@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"therbert@google.com" <therbert@google.com>,
	Martin Topholm <mph@hoth.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab2F0Gc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 02:32:26 -0400
In-Reply-To: <1340730156.10893.359.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 19:02 +0200, Eric Dumazet wrote:
> On Tue, 2012-06-26 at 07:34 +0200, Hans Schillstrom wrote:
> 
> > This patch didn't give much in gain actually.
> 
> With a 100Mbps link it does.
> 
> With a 1Gbps link we are cpu bounded for sure.

I'm using a 10G link

> > The big cycle consumer during a syn attack is SHA sum right now, 
> > so from that perspective it's better to add aes crypto (by using AES-NI) 
> > to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.

How are you avoiding the lock bh_lock_sock_nested(sk) in tcp_v4_rcv()?


> My dev machine is able to process ~280.000 SYN (and synack) per second
> (tg3, mono queue), and sha_transform() takes ~10 % of the time according
> to perf.

With my parallel SYN cookie/brownies patches, I could easily process 750
Kpps (limited by the generator, think the owners of the big machine did
a test where they reached 1400 Kpps).

I also had ~10% CPU usage from sha_transform() but across all cores...


> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
> second.

IMHO a faster hash is not the answer... parallel processing of SYN
packets is a better answer.  But I do think, adding this faster hash as
a sysctl switch might be a good idea, for people with smaller embedded
hardware.  Using it as default, might be "dangerous" and open an attack
vector on SYN cookies in Linux.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
