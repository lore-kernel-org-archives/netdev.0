From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 16:48:13 -0700
Message-ID: <1408060093.6804.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
	 <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53ED4354.9090904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52100 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbaHNXsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:48:15 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so2501767pac.17
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:48:14 -0700 (PDT)
In-Reply-To: <53ED4354.9090904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 16:16 -0700, Alexander Duyck wrote:
> On 08/14/2014 11:46 AM, Eric Dumazet wrote:
> > In real life, applications do not use prequeue, because nobody wants one
> > thread per flow.
> 
> I still say this is just an argument to remove it.  It looks like you
> submitted a patch to allow stripping it from the build about 7 years go.
>  I assume it was rejected.
> 
> > Each socket has its own dst now route cache was removed, but if your
> > netperf migrates cpu (and NUMA node), we do not detect the dst should be
> > re-created onto a different NUMA node.
> 
> Are you sure about each socket having it's own DST?  Everything I see
> seems to indicate it is somehow associated with IP.  For example I can
> actually work around the issue by setting up a second subnet on the same
> port and then running the tests with each subnet affinitized to a
> specific node.

Here is the thing

nh_pcpu_rth_output is a per cpu cache.

But nh_rth_input is not, because we did not optimize the case where dst
has to be refcounted, yet.

Rationale is explained in d26b3a7c4b3b26319f18bb645de93eba8f4bdcd5
("ipv4: percpu nh_rth_output cache")

If you guys really believe we should have a percpu dst, go for it, but
again, if the softirq handler runs on a different cpu than the
application thread, it wont work.

And, given 72 core servers are now on the way, we'll consume more ram,
for netperf users.
