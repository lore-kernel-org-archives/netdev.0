From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Mon, 29 Sep 2014 22:14:31 +0200
Message-ID: <20140929221431.3e322aab@redhat.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
	<20140925102505.494acab1@redhat.com>
	<54240F34.1050707@mojatatu.com>
	<CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
	<20140925165738.646d0783@redhat.com>
	<CA+mtBx9ZW0qYh+_BEEVTgZ79Xbq0bH1Agfss_7kdEus_syeMhA@mail.gmail.com>
	<20140925172329.7460f787@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?UTF-8?B?SMO4aWxh?= =?UTF-8?B?bmQtSsO4cmdlbnNlbg==?=
	<toke@toke.dk>, Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbaI2UPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 16:15:09 -0400
In-Reply-To: <20140925172329.7460f787@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 25 Sep 2014 17:23:29 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
 
> I will redo the tests, once I get home to my testlab, as the remote lab
> I'm using now is annoyingly slow rebooting machines, as we not longer
> have a runtime option for enable/disable (I'm currently in Switzerland).   

I'm going to change the bulking "budget" from 8 packet to 7 packets,
based on my netperf-wrapper test.

I've designed some tests for the tool "netperf-wrapper" that tries to
measure the HoL blocking effect.  I've turned down the link speed to
100Mbit/s on driver igb.  And uses a single TXQ setup
(cmdline: ethtool -L eth1 combined 1).

I can now show some kind of HoL blocking effect.  The strange part is
the HoL effect only occurs above 8 packets, 7 packet and below show no
bad effect of this bulking patch.

Results 100Mbit/s test qdisc_prio_hol, latency in high prio band:
 * GSO: stable average on 2.23ms
 * TSO: varies between min 4.13ms to 4.41ms (range 0.28ms)
 * No bulking: stable average on 1.71ms (3x outliners on 1.95ms)
 * Bulking(8): varies between 1.71ms to 1.95ms (range 0.24ms)
 * Bulking(7): stable average on 1.71ms (1x outliner  on 1.95ms)
 * Bulking(6): stable average on 1.71ms (3x outliners on 1.91ms)
 * Bulking(5): stable average on 1.71ms (1x outliner  on 1.91ms)
 * Bulking(5): stable average on 1.71ms (1x outliner  on 1.91ms)
 * Bulking(4): stable average on 1.71ms (0x outliner)

Bulking(8) the calculation:
 * Added delay were 0.24ms (1.95 - 1.71ms) corrosponding to 3000 bytes
 * 1500 bytes *8 / 100Mbit = 0.12 ms
 * (100*10^6)*(1.95/10^3)/8 = 24375 bytes
 * (100*10^6)*(1.71/10^3)/8 = 21375 bytes
 * Added HoL: 3000 bytes
 * Still compared to TSO and GSO, the added HoL blocking is small.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
