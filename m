From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression from routing cache removal?
Date: Wed, 05 Jun 2013 11:13:17 -0700
Message-ID: <1370455997.24311.290.camel@edumazet-glaptop>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:37489 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904Ab3FESNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 14:13:19 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa12so2128870pbc.25
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 11:13:18 -0700 (PDT)
In-Reply-To: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 12:57 -0500, Shawn Bohrer wrote:
> I've got a performance regression that I've been trying to track down
> for the last couple of days.  The last known good kernel was 3.4 and
> now I'm testing 3.10 so there has been a lot of changes in between.
> The workload I'm testing has a single machine receiving UDP multicast
> packets across approximately 350 multicast groups.  We've got one
> socket per multicast address receiving the data.  The traffic is small
> packets and tends to be very bursty.  With the 3.10 kernel I'm seeing
> occasional spikes in one-way latency that are in the 100-500
> millisecond range, and regularly in the 10 millisecond range.  I've
> started a git bisect which has narrowed me down to:
> 
> bad f5b0a8743601a4477419171f5046bd07d1c080a0
> good fa0afcd10951afad2022dda09777d2bf70cdab3d
> 
> The remaining commits are all part of the routing cache removal so
> I've stopped my bisection for now.  I can bisect further if anyone
> thinks it will be valuable.

> 
> Digging through the git history the ip_check_mc_rcu appears to be the
> result of the routing cache removal. 

Yes, ip_check_mc_rcu() does a linear scan of your ~350 groups :

for_each_pmc_rcu(in_dev, im) {
    if (im->multiaddr == mc_addr)
          break;
}
