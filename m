From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 14:29:25 -0700
Message-ID: <d1c2719f0804251429l26118ef0j8a386103ee41f0ea@mail.gmail.com>
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
Received: from smtp-out.google.com ([216.239.33.17]:5409 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762040AbYDYV3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 17:29:33 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m3PLTR2r009559
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 22:29:27 +0100
Received: from hs-out-0708.google.com (hsc55.prod.google.com [10.44.3.55])
	by zps78.corp.google.com with ESMTP id m3PLTP3T022442
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 14:29:26 -0700
Received: by hs-out-0708.google.com with SMTP id 55so2640289hsc.10
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 14:29:25 -0700 (PDT)
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

I think we can ignore this case if it happens rarely.

>
>  But even assuming we could say that the driver gets a clone all the
>  time, the "sent" state would need to be in the shared data area.

Ok.

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

Well, there is a fine line to walk before CPU efficiency and traffic
burstiness. The TSO defer code causes a few hundred KB of bursts that
quickly blow away our small switch buffers. The matter may get even
worse for 10GE.

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

Oh, just realized I've been working on a very "old" (2.6.18 :-)
version of kernel.
Will get the latest 2.6.25 and take a look. I can't find "skb_release_all()"
function you pointed in a later mail either. Guess the Linux kernel
code is rewritten every few month :-(.

Jerry

>
>  :-)
>
