From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: Force updating pcount after skb_pull()
 during mtu probing
Date: Tue, 09 Jun 2015 10:59:13 -0700
Message-ID: <1433872753.27504.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433551592-3596877-1-git-send-email-kafai@fb.com>
	 <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150608175833.GB390474@devbig242.prn2.facebook.com>
	 <1433787073.29864.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1433869585.29864.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150609174510.GE390474@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f196.google.com ([209.85.223.196]:33431 "EHLO
	mail-ie0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbbFIR7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:59:18 -0400
Received: by ierx19 with SMTP id x19so3077026ier.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 10:59:17 -0700 (PDT)
In-Reply-To: <20150609174510.GE390474@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-09 at 10:45 -0700, Martin KaFai Lau wrote:
> On Tue, Jun 09, 2015 at 10:06:25AM -0700, Eric Dumazet wrote:
> > I've been working on this, but still can get the bug triggering in
> > tcp_fragment(), no matter what (Neal patch , yours, mine...)
> Can you describe the test case that can reproduce it?

This might not be easy : I used a 40Gb testbed and following.

Warning triggers in about 30 minutes, but this might be related to some
unrelated traffic.

echo 4 >/proc/sys/net/ipv4/tcp_min_tso_segs
echo 0 >/proc/sys/kernel/timer_migration
echo fq >/proc/sys/net/core/default_qdisc
tc qd replace dev eth1 root mq
./super_netperf 1500 --google-pacing-rate 3028000 -H lpaa24 -l 10000 &

You might implement the pacing stuff using regular netperf with

for ETH in eth1
do
 tc qd del dev $ETH root 2>/dev/null
 tc qd add dev $ETH root handle 1: mq
 for i in `seq 1 16`
 do
  slot=$( printf %x $(( i )) )
  tc qd add dev $ETH parent 1:$slot fq maxrate 3028000
 done
done


(Change eth1 by eth0 or something, and 16 by number of TX queues.)
