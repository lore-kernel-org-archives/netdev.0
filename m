From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 18:08:56 +0200
Message-ID: <1342800536.2626.7670.camel@edumazet-glaptop>
References: <1342796553.2626.7389.camel@edumazet-glaptop>
	 <CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
	 <CADVnQy=nJz33pzd+o1WoCOR6Mk2pbB2x+bujqbfLUi8-+J=hGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61153 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab2GTQJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:09:01 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so3550612bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 09:09:00 -0700 (PDT)
In-Reply-To: <CADVnQy=nJz33pzd+o1WoCOR6Mk2pbB2x+bujqbfLUi8-+J=hGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 09:03 -0700, Neal Cardwell wrote:
> On Fri, Jul 20, 2012 at 8:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> > On Fri, Jul 20, 2012 at 8:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >>         tp->snd_cwnd_cnt += cnt;
> >>         while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
> 
> Nice catch, Eric.
> 
> One thing that's always bothered me about the tp->snd_cwnd_cnt code is
> that the slow start and congestion avoidance use different criteria
> for incrementing snd_cwnd_cnt. tcp_slow_start() increments
> snd_cwnd_cnt by snd_cwnd for each ACKed packet, and congestion
> avoidance increases snd_cwnd_cnt by just 1 for each packet.
> 
> This means that if we exit slow start and enter congestion avoidance,
> then we think we can have a "credit" for a bunch of ACKs that never
> happened (up to snd_cwnd-1), so we can conceivably do our first
> additive increase in congestion avoidance up to almost 1RTT too
> early. Can we just get rid of the use of snd_cwnd_cnt in slow start,
> and just use local variables in tcp_slow_start() rather than trying to
> carry state between ACKs?

Apparently tcp_slow_start() needs the snd_cwnd_cnt in case 
"limited slow start"  is used :

cnt = sysctl_tcp_max_ssthresh >> 1;

So to address your point, maybe we should clear  snd_cwnd_cnt
when leaving slow start for congestion avoidance phase ?
