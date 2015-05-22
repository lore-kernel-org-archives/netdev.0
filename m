From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Thu, 21 May 2015 20:43:26 -0700
Message-ID: <1432266206.4060.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150512130855.GA29412@localhost.localdomain>
	 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150521.232541.173137306546517818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com, rapier@psc.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34638 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbEVDn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:43:29 -0400
Received: by igbhj9 with SMTP id hj9so26955265igb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 20:43:28 -0700 (PDT)
In-Reply-To: <20150521.232541.173137306546517818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 23:25 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 May 2015 16:35:41 -0700
> 
> > From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > 
> > This patch tracks the total number of inbound and outbound segments on a
> > TCP socket. One may use this number to have an idea on connection
> > quality when compared against the retransmissions.
> > 
> > RFC4898 named these : tcpEStatsPerfSegsIn and tcpEStatsPerfSegsOut
> > 
> > These are a 32bit field each and can be fetched both from TCP_INFO
> > getsockopt() if one has a handle on a TCP socket, or from inet_diag
> > netlink facility (iproute2/ss patch will follow)
> > 
> > Note that tp->segs_out was placed near tp->snd_nxt for good data
> > locality and minimal performance impact, while tp->segs_in was placed
> > near tp->bytes_received for the same reason.
> > 
> > Join work with Eric Dumazet.
> > 
> > Note that received SYN are accounted on the listener, but sent SYNACK 
> > are not accounted.
> > 
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied to net-next, thanks.

Thanks David.

I'll send a fix for the stuff I added earlier, as the spin_lock_bh() in
get_tcp_info() can deadlock since the caller inet_diag_dump_icsk() might
hold the &hashinfo->ehash_locks[i]

I need to instead use
u64_stats_fetch_begin_irq()/u64_stats_fetch_retry_irq()

(and as a bonus optimize 64bit arches)
