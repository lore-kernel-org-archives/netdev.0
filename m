From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Mon, 29 Sep 2014 22:23:36 +0200
Message-ID: <20140929222336.30b0527c@redhat.com>
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
	<CA+mtBx990LcBrZVhfNk224cofpDWGeOD=F0Nbe0DWoEF=LvOUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58095 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946AbaI2UYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 16:24:08 -0400
In-Reply-To: <CA+mtBx990LcBrZVhfNk224cofpDWGeOD=F0Nbe0DWoEF=LvOUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, 25 Sep 2014 08:58:54 -0700 Tom Herbert <therbert@google.com> wrote:

> On Thu, Sep 25, 2014 at 8:23 AM, Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > On Thu, 25 Sep 2014 08:05:38 -0700 Tom Herbert <therbert@google.com> wrote:
> >
> >> On Thu, Sep 25, 2014 at 7:57 AM, Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >> > On Thu, 25 Sep 2014 07:40:33 -0700 Tom Herbert <therbert@google.com> wrote:
> >> >
[...]
> >>
> >> That's great. In commit log, would be good to have results with
> >> TCP_STREAM also and please report aggregate CPU utilization changes
> >> (like from mpstat).
> >
> > The TCP_STREAM is not a good test for this, because unless disabling
> > both TSO and GSO the packets will not hit the code path (that this
> > patch changes).  When we later add support for TSO and GSO bulking,
> > then it will make sense to include TCP_STREAM testing, not before.
> >
> Disabling TSO and GSO is fine. I'm interested to see interactions with TCP.

TCP already benefit from bulking, via TSO and especially for GSO
segmented packets, and this patch does not bulk TSO and GSO packets.

Testing effect for TCP involves disabling TSO and GSO, but I had to
enable GRO on the receiver, which reduces ACK packets, else the system
could not exceed the 10Gbit/s link capacilty with none-bulking.

Test cmd:
 * netperf -H 192.168.8.2 -t TCP_STREAM -l 1000 -D 1 -n -N

The measured perf diff benefit for TCP_STREAM were 4.66% less CPU used
on calls to _raw_spin_lock() (mostly from sch_direct_xmit()).

Tool mpstat, while stressing the system with netperf 24x TCP_STREAM, shows:
 * Disabled bulking: 8.30% soft 88.75% idle
 * Enabled  bulking: 7.80% soft 89.36% idle

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
