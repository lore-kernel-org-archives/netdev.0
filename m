From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 17:49:33 -0700
Message-ID: <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "rick.jones2" <rick.jones2@hp.com>,
	davem@davemloft.net
To: "John Heffner" <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:32726 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbYDYAtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 20:49:40 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m3P0nZEq027346
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 01:49:35 +0100
Received: from wx-out-0506.google.com (wxct8.prod.google.com [10.70.121.8])
	by zps77.corp.google.com with ESMTP id m3P0nXO2013685
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 17:49:34 -0700
Received: by wx-out-0506.google.com with SMTP id t8so3378864wxc.30
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 17:49:33 -0700 (PDT)
In-Reply-To: <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 9:32 AM, John Heffner <johnwheffner@gmail.com> wrote:
>
> On Wed, Apr 23, 2008 at 4:29 PM, Jerry Chu <hkchu@google.com> wrote:
> >
> > I've been seeing the same problem here and am trying to fix it.
> >  My fix is to not count those pkts still in the host queue as "prior_in_flight"
> >  when feeding the latter to tcp_cong_avoid(). This should cause
> >  tcp_is_cwnd_limited() test to fail when the previous in_flight build-up
> >  is all due to the large host queue, and stop the cwnd to grow beyond
> >  what's really necessary.
>
> Sounds like a useful optimization.  Do you have a patch?

Am working on one, but still need to completely rootcause the problem first,
and do a lot more testing. I, like Rick Jones, have for a while thought either
the autotuning, or the Congestion Window Validation (rfc2861) code should
dampen the cwnd growth so the bug must be there, until last week when I
decided to get to the bottom of this problem.

One question: I currently use skb_shinfo(skb)->dataref == 1 for skb's on the
sk_write_queue list as the heuristic to determine if a packet has hit the wire.
This seems a good solution for the normal cases without requiring changes
to the driver to notify TCP in the xmit completion path. But I can imagine there
may be cases where another below-IP consumer of skb, e.g., tcpdump, can
nullify the above heuristic. If the below IP consumer causes the skb ref count
to drop to 1 prematurally, well the inflated cwnd problem comes back but it's
no worse than before. What if the below IP skb reader causes the skb
ref count to remain > 1 while pkts have long hit the wire? This may cause the
fix to prevent cwnd from growing when needed, hence hurting performance.
Is there a better solution than checking against dataref to determine if a pkt
has hit the wire?

Also the code to determine when/how much to defer in the TSO path seems
too aggressive. It's currently based on a percentage
(sysctl_tcp_tso_win_divisor)
of min(snd_wnd, snd_cwnd). Would it be too much if the value is large? E.g.,
when I disable sysctl_tcp_tso_win_divisor, the cwnd of my simple netperf run
drops exactly 1/3 from 1037 (segments) to 695. It seems to me the TSO
defer factor should be based on an absolute count, e.g., 64KB.

Jerry

>
>  -John
>
