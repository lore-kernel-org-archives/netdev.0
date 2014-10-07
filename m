From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 7 Oct 2014 22:07:36 +0200
Message-ID: <20141007220736.347ad042@redhat.com>
References: <20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	<1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007.131938.1410434352331637585.davem@davemloft.net>
	<1412703132.11091.144.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007203700.00e883a1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363AbaJGUIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 16:08:05 -0400
In-Reply-To: <20141007203700.00e883a1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2014 20:37:00 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Tue, 07 Oct 2014 10:32:12 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2014-10-07 at 13:19 -0400, David Miller wrote:
> > 
> > > Yes, this makes sense, do a full qdisc_restart() cycle without boundaries,
> > > then check how much quota was used afterwards to guard the outermost loop.
> > 
> > I am testing this, and also am testing the xmit_more patch for I40E.
> 
> Check, I'm also testing both yours and Hannes patch.
> 
> Results at:
>  http://people.netfilter.org/hawk/qdisc/measure18_restore_quota_fairness/
>  http://people.netfilter.org/hawk/qdisc/measure19_restore_quota_erics/
>  http://people.netfilter.org/hawk/qdisc/measure20_no_quota_baseline_at_git_02c0fc1/

These tests are with ixgbe with a single TXQ, in-order to measure the
effect of HoL, by taking advantage of the high prio queue of pfifo_fast.

 (Cmdline trick for a single TXQ: "ethtool -L eth4 combined 1")

In case GSO=off TSO=off, Hannes "wins" with 0.04ms
 http://people.netfilter.org/hawk/qdisc/measure19_restore_quota_erics/compare_rr_latency_eric_vs_hannes_NoneXSO.png
which I guess we should not be concerned with.

In case GSO=on TSO=off, the diff is max 0.01ms (to Hannes advantage ;-))
Notice the extreme zoom level:
 http://people.netfilter.org/hawk/qdisc/measure19_restore_quota_erics/compare_rr_latency_eric_vs_hannes_GSO.png

In case GSO=on TSO=on, there are some spikes, where Eric's version have
the highest spike.
 http://people.netfilter.org/hawk/qdisc/measure19_restore_quota_erics/compare_rr_latency_eric_vs_hannes_TSO.png
Again nothing we should worry about.

Thus, guess we can safely go with Eric's solution, even-thought Hannes
version consistently shows less HoL blocking and less sever spikes, as
the difference is so small.  I'm ACKing Eric's version...


We do need this patch, as can be seen by the baseline test at git
commit 02c0fc1.  Where some bandwidth unfairness to the UDP flows
happens, but only in the case GSO=off TSO=off (others are fine).
  http://people.netfilter.org/hawk/qdisc/measure20_no_quota_baseline_at_git_02c0fc1/NoneXSO_10Gbit_base_02c0fc1_bandwidth_totals_unfairness.png
Kind of strange, but it went away in the two quota tests.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
