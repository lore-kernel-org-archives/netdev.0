From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 7 May 2008 11:36:59 -0700
Message-ID: <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <20080425.000547.152086801.davem@davemloft.net>
	 <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	 <20080506.212722.225900091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8441 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbYEGShF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 14:37:05 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m47Ib1iv025965
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 19:37:01 +0100
Received: from wx-out-0506.google.com (wxdi26.prod.google.com [10.70.135.26])
	by zps36.corp.google.com with ESMTP id m47Ib0hi028525
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 11:37:00 -0700
Received: by wx-out-0506.google.com with SMTP id i26so351113wxd.8
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 11:36:59 -0700 (PDT)
In-Reply-To: <20080506.212722.225900091.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2008 at 9:27 PM, David Miller <davem@davemloft.net> wrote:

>
> From: "Jerry Chu" <hkchu@google.com>
> Date: Tue, 6 May 2008 20:57:46 -0700
>
>
> > I fail to see how adding shinfo->in_flight to count how many
> > outstanding clones are there can help accounting for how many
> > "host_inflight" pkts. Part of the problems, as you've mentioned
> > before, is that the driver may not always get a clone.
>
> Sure but it will get one %99.9999 of the time.

I couldn't care less about some rare boundary case either. What I'm
concerned about is if there is some popular below-IP module/feature that,
when turned on, will render my host_inflight check (using dataref==1 as
an indication that the pkt has left the host) completely bogus. Turning on
pkt tapping (e.g., tcpdump) seems to be one such case, although one
may argue that belongs to those edge usage conditions that we don't
need to worry about. (OTOH it may be undesirable for tcpdump to have
significant performance side effect for those who try to use tcpdump to
debug performance problem.) Turning on GSO but not TSO seems to
be another case where the driver gets a copy all the time (kernel version
2.6.18).

If there is no other popular below-IP module/feature that will break the
dataref==1 then perhaps my initial concern was invalid. In either case, I
don't see your patch any better than my dataref==1 check. Neither one
address the below-IP module/feature concern described before.

>
>
> With TCP, as long as that clone is alive the driver has it.  And the
> counter only counts the clones.
>
> Anyways, did you even test my patch and try to use it for your needs
> or is this analysis purely from your inspection of it? :-/

No I haven't tested your patch. I tried to understand skb better before
applying your patch. After I studied bunch of code, I come to the conclusion
that your patch won't work for me. First it tracks # of clones, which is not
what I need. E.g., tcpdump will cause host_inflight to be grossly wrong.
Ok, maybe we can ignore tcpdump, your patch counts # of cloned skb
whereas I need a count of # of pkts. Perhaps this can be fixed also, but it
then dawned on me that wouldn't it be more desirable to add the space
overhead per tcp_sock than per skb?

Jerry

>
>
