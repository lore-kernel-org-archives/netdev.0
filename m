From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Tue, 17 Jul 2012 19:39:33 +0200
Message-ID: <1342546773.2626.909.camel@edumazet-glaptop>
References: <1341307524.2583.115.camel@edumazet-glaptop>
	 <CAPVr9VP7DniPZj4vZi_myJWfL5JLYKYTXXtrXcKHo9LjEQzjYw@mail.gmail.com>
	 <20120716232600.GI3415@nuttenaction>
	 <1342501947.2626.9.camel@edumazet-glaptop>
	 <CAPVr9VMCYFO-7uEzO6ft2vpPhVvRgHB3EWJJG62OqGqux1LsZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>
To: Mark Gordon <msg@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57524 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab2GQRji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 13:39:38 -0400
Received: by yhmm54 with SMTP id m54so648336yhm.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 10:39:38 -0700 (PDT)
In-Reply-To: <CAPVr9VMCYFO-7uEzO6ft2vpPhVvRgHB3EWJJG62OqGqux1LsZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please Mark :

1) Dont top post on netdev

2) Dont write HTML mails on netdev (your mail never went to netdev,
   only to CCed people). Only text mails are allowed.

On Tue, 2012-07-17 at 10:20 -0700, Mark Gordon wrote:
> Even the static delay case seems wrong with the new patch.  Assume all
> packets have the same sched_time.  Then if you spam packets that get
> processed at the same time by netem they will all get scheduled with
> the same time_to_send because the first packet will get time_to_send
> of [1] = clock_time + sched_time.  Then packet n compute 'now' as
> [n-1] and delay as sched_time - (clock_time - [1]) = 0 so that [n] =
> [n-1].  Therefore every packet gets scheduled at the same time.
> 
> 
> The above modification seems to fix the issue when latency/jitter is 0
> but suffers from a missing non-linearity when delay is present.  Is
> there a technical reason I'm missing that prevents us from doing rate
> and latency here?  Why wouldn't the 'official' patch have correct
> rate?

Because delay is variable (jitter)

netem as is is not working correctly if you have both a rate limit and
delay.

Hagen is working on a solution, but there is no easy fix.

The right solution is to have :

1) A rate stage, using a child qdisc (that you can graft to install your
own qdisc hierarchy if needed, say if you want codel or fq_codel ;))

  Thats basically a TBF...

2) skb orphan

3) drops/reorders/corrupt/additional delay (variable delay)
   using an internal tfifo, to mimic real networks behavior.

Thats the reverse of how its currently done.

Alternatively, this could be implemented as a special network device,
like bonding, instead of a qdisc.
