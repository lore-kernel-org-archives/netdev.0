From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: avoid soft lockup in bnx2x_poll()
Date: Tue, 08 Dec 2015 10:03:37 -0800
Message-ID: <1449597817.6639.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CO2PR11MB00881A410C4E35D3859CB84C97080@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33836 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbLHSDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:03:39 -0500
Received: by pfbg73 with SMTP id g73so15980761pfb.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:03:39 -0800 (PST)
In-Reply-To: <CO2PR11MB00881A410C4E35D3859CB84C97080@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-08 at 17:02 +0000, Yuval Mintz wrote:
> > Under heavy TX load, bnx2x_poll() can loop forever and trigger soft lockup bugs.
> > 
> > A napi poll handler must yield after one TX completion round, risk of livelock is
> > too high otherwise.
> > 
> > Bug is very easy to trigger using a debug build, and udp flood, because of added
> > cpu cycles in TX completion, and we do not receive enough packets to break the
> > loop.
> 
> Eric - I understand what you're doing and it looks fine [to me, at least].
> Out of curiosity, do you know whether removing the loop damages any
> other flow, i.e., by slowing transmitter as transmission rings gets filled
> completely between consecutive NAPI runs? 

I saw no downsides yet. Most of the time TX are blocked by BQL these
days, before complete TX ring filling.

I added some instrumentation, and even after the patch and a non debug
kernel we can see :

bnx2x: bnx2x_poll() took 455036 nsec

455 usec on one bnx2x_poll() is already quite big, but one can tweak TX
ring (ethtool -G eth1 tx ....) if latencies are a serious concern.

Note that my patch should not slow transmitters, only give a chance for
other softirqs being serviced, and eventually give control to ksoftirqd
under stress.
