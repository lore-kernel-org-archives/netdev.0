From: "Jerry Chu" <hkchu@google.com>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 03:38:58 -0700
Message-ID: <d1c2719f0807090338k40a081eaoff5a2055448b3f35@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
	 <48728B09.1050801@citi.umich.edu> <48729DAD.8010400@hp.com>
	 <1e41a3230807072033n2f5519e4m42003e191b44cefe@mail.gmail.com>
	 <349f35ee0807090255s58fd040bne265ee117d06d397@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aglo@citi.umich.edu, ranjitm@google.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:4781 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYGIKjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 06:39:14 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m69Ad8Ii006732
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 11:39:09 +0100
Received: from wr-out-0506.google.com (wrac46.prod.google.com [10.54.54.46])
	by zps78.corp.google.com with ESMTP id m69Ad7OU013591
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 03:39:08 -0700
Received: by wr-out-0506.google.com with SMTP id c46so2400153wra.18
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 03:39:07 -0700 (PDT)
In-Reply-To: <349f35ee0807090255s58fd040bne265ee117d06d397@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2008 at 2:55 AM, H.K. Jerry Chu <hkjerry.chu@gmail.com> wrote:
>
>
> ---------- Forwarded message ----------
> From: John Heffner <johnwheffner@gmail.com>
> Date: Mon, Jul 7, 2008 at 8:33 PM
> Subject: Re: setsockopt()
> To: Rick Jones <rick.jones2@hp.com>
> Cc: netdev@vger.kernel.org
>
>
> On Mon, Jul 7, 2008 at 3:50 PM, Rick Jones <rick.jones2@hp.com> wrote:
> > I'm still a triffle puzzled/concerned/confused by the extent to which
> > autotuning will allow the receive window to grow, again based on some
> > netperf experience thusfar, and patient explanations provided here and
> > elsewhere, it seems as though autotuning will let things get to 2x what it
> > thinks the sender's cwnd happens to be.  So far under netperf testing that
> > seems to be the case, and 99 times out of ten my netperf tests will have the
> > window grow to the max.
>
>
> Rick,
>
> I thought this was covered pretty thoroughly back in April.  The
> behavior you're seeing is 100% expected, and not likely to change
> unless Jerry Chu gets his local queued data measurement patch working.
>  I'm not sure what ultimately happened there, but it was a cool idea
> and I hope he has time to polish it up.  It's definitely tricky to get
> right.

Yes most certainly! I've had the non-TSO code mostly working for the
past couple of months (i.e., cwnd grows only to ~50KB on a local 1GbE
setup). But no such luck with TSO. Although the idea (exclusing pkts
still stuck in some queues inside the sending host from "in_flight" when
deciding whether needing to grow cwnd or not) seems simple, getting
the accounting right for TSO seems impossible. After catching and fixing
a slew of cases for 1GbE and seemingly getting close to the end of the
tunnel, I moved my tests to 10GbE last month and discovered accounting
leakage again. Basically my count of all the pkts still stuck inside the host
sometimes becomes larger than total in-flight. I have not figured out what
skb paths I might have missed, or is it possible the over-zealously-tuned
10G drivers are doing something funky?

Not to mention a number of other tricky scenario - e.g., when TSO
is enabled on 1GbE, the code works well for a netperf streaming test but
not the RR test with 1MB request size. After a while I discovered that
tcp_sendmsg() for the 1MB RR tests often runs in a tight loop without
flow control, hence always hitting snd_cwnd, even though acks have come
back. This is because the socket lock is only released during flow control.
The problem went away when I check and let the return traffic in inside the
tcp_sendmsg() loop. This kind of stuff can easily spoil my original simple
algorithm.

Jerry

> Jerry's optimization is a sender-side change.  The fact that the
> receiver announces enough window is almost certainly the right thing
> for it to do, and (I hope) this will not change.
>
> If you're still curious:
> http://www.psc.edu/networking/ftp/papers/autotune_sigcomm98.ps
> http://www.lanl.gov/radiant/pubs/drs/lacsi2001.pdf
> http://staff.psc.edu/jheffner/papers/senior_thesis.pdf
>
>  -John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
