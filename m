From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 05 Feb 2015 05:19:02 -0800
Message-ID: <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:39518 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbBENTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:19:06 -0500
In-Reply-To: <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 04:57 -0800, Eric Dumazet wrote:

> The intention is to control the queues to the following :
> 
> 1 ms of buffering, but limited to a configurable value.
> 
> On a 40Gbps flow, 1ms represents 5 MB, which is insane.
> 
> We do not want to queue 5 MB of traffic, this would destroy latencies
> for all concurrent flows. (Or would require having fq_codel or fq as
> packet schedulers, instead of default pfifo_fast)
> 
> This is why having 1.5 ms delay between the transmit and TX completion
> is a problem in your case.

Note that TCP stack could detect when this happens, *if* ACK where
delivered before the TX completions, or when TX completion happens,
we could detect that the clone of the freed packet was freed.

In my test, when I did "ethtool -C eth0 tx-usecs 1024 tx-frames 64", and
disabling GSO, TCP stack sends a bunch of packets (a bit less than 64),
blocks on tcp_limit_output_bytes.

Then we receive 2 stretch ACKS after ~50 usec.

TCP stack tries to push again some packets but blocks on
tcp_limit_output_bytes again.

1ms later, TX completion happens, tcp_wfree() is called, and TCP stack
push following ~60 packets.


TCP could  eventually dynamically adjust the tcp_limit_output_bytes,
using a per flow dynamic value, but I would rather not add a kludge in
TCP stack only to deal with a possible bug in ath10k driver.

niu has a similar issue and simply had to call skb_orphan() :

drivers/net/ethernet/sun/niu.c:6669:            skb_orphan(skb);
