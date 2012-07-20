From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 09:03:45 -0700
Message-ID: <CADVnQy=nJz33pzd+o1WoCOR6Mk2pbB2x+bujqbfLUi8-+J=hGA@mail.gmail.com>
References: <1342796553.2626.7389.camel@edumazet-glaptop>
	<CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:57451 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab2GTQDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:03:46 -0400
Received: by gglu4 with SMTP id u4so4132004ggl.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 09:03:46 -0700 (PDT)
In-Reply-To: <CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 8:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Fri, Jul 20, 2012 at 8:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>         tp->snd_cwnd_cnt += cnt;
>>         while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {

Nice catch, Eric.

One thing that's always bothered me about the tp->snd_cwnd_cnt code is
that the slow start and congestion avoidance use different criteria
for incrementing snd_cwnd_cnt. tcp_slow_start() increments
snd_cwnd_cnt by snd_cwnd for each ACKed packet, and congestion
avoidance increases snd_cwnd_cnt by just 1 for each packet.

This means that if we exit slow start and enter congestion avoidance,
then we think we can have a "credit" for a bunch of ACKs that never
happened (up to snd_cwnd-1), so we can conceivably do our first
additive increase in congestion avoidance up to almost 1RTT too
early. Can we just get rid of the use of snd_cwnd_cnt in slow start,
and just use local variables in tcp_slow_start() rather than trying to
carry state between ACKs?

neal
