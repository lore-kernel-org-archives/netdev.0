From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 11:30:51 -0700
Message-ID: <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	 <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	 <20080424.234628.170849475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:41179 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765636AbYD1SbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:31:06 -0400
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id m3SIUqSK019952
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 19:30:52 +0100
Received: from wx-out-0506.google.com (wxct5.prod.google.com [10.70.121.5])
	by spaceape23.eur.corp.google.com with ESMTP id m3SIUAM2020005
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 19:30:52 +0100
Received: by wx-out-0506.google.com with SMTP id t5so4206216wxc.16
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 11:30:52 -0700 (PDT)
In-Reply-To: <20080424.234628.170849475.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 11:46 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Thu, 24 Apr 2008 17:49:33 -0700
>
>
>  > One question: I currently use skb_shinfo(skb)->dataref == 1 for skb's on the
>  > sk_write_queue list as the heuristic to determine if a packet has hit the wire.
>
>  This doesn't work for the reasons that you mention in detail next :-)
>
>
>  > Is there a better solution than checking against dataref to determine if a pkt
>  > has hit the wire?
>
>  Unfortunately, no there isn't.
>
>  Part of the issue is that the driver is only working with a clone, but
>  if a packet gets resent before the driver gives up it's reference,
>  we'll make a completely new copy.
>
>  But even assuming we could say that the driver gets a clone all the
>  time, the "sent" state would need to be in the shared data area.
>
>
>  > Also the code to determine when/how much to defer in the TSO path seems
>  > too aggressive. It's currently based on a percentage
>  > (sysctl_tcp_tso_win_divisor)
>  > of min(snd_wnd, snd_cwnd). Would it be too much if the value is large? E.g.,
>  > when I disable sysctl_tcp_tso_win_divisor, the cwnd of my simple netperf run
>  > drops exactly 1/3 from 1037 (segments) to 695. It seems to me the TSO
>  > defer factor should be based on an absolute count, e.g., 64KB.
>
>  This is one of the most difficult knobs to get right in the TSO code.
>
>  If the percentage is too low, you'll notice that cpu utilization
>  increases because you aren't accumulating enough data to send down the
>  largest possible TSO frames.
>
>  But yes you are absolutely right that we should have a hard limit
>  of 64K here, since we can't build a larger TSO frame anyways.
>
>  In fact I thought we had something like that here already :-/
>
>  Wait, in fact we do, it's just hidden behind a variable now:
>
>         /* If a full-sized TSO skb can be sent, do it. */
>         if (limit >= sk->sk_gso_max_size)
>                 goto send_now;
>
>  :-)

Correct, but its counterpart doesn't exist in tcp_is_cwnd_limited(). So
cwnd will continue to grow when left < cwnd/sysctl_tcp_tso_win_divisor,
which can be very large when cwnd is large.

If I change tcp_tso_win_divisor to 0, cwnd max out at 695 rather than 1037,
exactly off by 1/3. I tried to add the same check to tcp_is_cwnd_limited():

diff -c /tmp/tcp.h.old tcp.h
*** /tmp/tcp.h.old      Mon Apr 28 11:00:44 2008
--- tcp.h       Mon Apr 28 10:54:10 2008
***************
*** 828,833 ****
--- 828,835 ----
                return 0;

        left = tp->snd_cwnd - in_flight;
+       if (left >= 65536)
+               return 0;
        if (sysctl_tcp_tso_win_divisor)
                return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
        else

>

But it doesn't seem to help (cwnd still grows to 1037).

Jerry
