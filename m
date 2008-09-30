From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Tue, 30 Sep 2008 07:08:04 -0700 (PDT)
Message-ID: <20080930.070804.26007839.davem@davemloft.net>
References: <20080929191254.GA20074@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752301AbYI3OIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:08:15 -0400
In-Reply-To: <20080929191254.GA20074@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 29 Sep 2008 15:12:54 -0400

> 	We currently have the ability to disable our route cache secret interval
> rebuild timer (by setting it to zero), but if we do that its possible for an
> attacker (if they guess our route cache hash secret, to fill our system with
> routes that all hash to the same bucket, destroying our performance.  This patch
> provides a backstop for that issues.  In the event that our rebuild interval is
> disabled (or very large), if any hash chain exceeds ip_rt_gc_elasticity, we do
> an emergency hash rebuild.  During the hash rebuild we:
> 1) warn the user of the emergency
> 2) disable the rebuild timer
> 3) invalidate the route caches
> 4) re-enable the rebuild timer with its old value

I just want to clarify what my intentions were when I spoke
with Neil about this stuff last week.

The idea is that we can by default not rebuild the secret
at all.

And only when we notice that chains are growing larger than
"(NUM_RTCACHE_ENTRIES / NUM_HASH_CHAINS) * N", only then
do we do this secret rebuild and flush.  Where N is some
constant of configurable value, the GC elasticity is some
example.

Normally this whole hash secret business is totally unnecessary and
there is zero reason to do it until we notice there is actually some
kind of deep hash chain growth problem.

It's expensive, we flush the whole routing cache, so doing it
every so often by default makes no sense and it is causing
performance problems for people.
