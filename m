From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] ixgbe: napi_poll must return the work done
Date: Wed, 15 Jun 2016 17:43:47 +0200
Message-ID: <1466005427.24431.18.camel@redhat.com>
References: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
	 <CAKgT0UeU7tfo=i5O1j9ORwBJUVYGta5Z-NLw+xKGVLeHQ=PPtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439AbcFOPnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:43:51 -0400
In-Reply-To: <CAKgT0UeU7tfo=i5O1j9ORwBJUVYGta5Z-NLw+xKGVLeHQ=PPtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-15 at 08:20 -0700, Alexander Duyck wrote:
> On Wed, Jun 15, 2016 at 6:37 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > Currently the function ixgbe_poll() returns 0 when it clean completely
> > the rx rings, but this foul budget accounting in core code.
> > Fix this returning the actual work done, capped to weight - 1, since
> > the core doesn't allow to return the full budget when the driver modifies
> > the napi status
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> I think the origin of reporting 0 was actually compatibility with some
> NAPI code floating around from before the 2.6.24 kernel.
> 
> I'd be curious to know how much this is actually fouling things up.
> Can you point to any specific issues it was causing?  

I noticed this while instrumenting the napi poll loop for another
patch. 

It's not easy to reproduce the bugged scenario, several NICs receiving a
relevant amount of traffic on napi instances scheduled on the same
softirq are needed. 

If any/some of them has the buggy poll() method, the napi_poll() loop
may process (much) more than netdev_budget packets per invocation,
possibly delaying others softirq more than needed/expected. 

The maxium delay will be no matter what capped to a couple of jiffies,
due to the time-based loop end condition, so in the worst possible
scenario (most probably not a real thing), this adds a latency of 2
jiffies - <time required to process netdev_budget packets> (~1.8ms on
recent h/w with HZ==1000).

> If you end up
> having to submit a v2 for any reason it might be useful if you can
> provide the additional details on what actual issue it was causing.
> 
> You might also want to look at the other Intel drivers, specifically
> ixgbevf and fm10k as I believe we have similar code in those drivers
> as well.

Thank you for the head-up. I need to get an hand on that h/w, first!

Paolo

> 
> Acked-by: Alexander Duyck <aduyck@mirantis.com>
