From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Tue, 27 Nov 2007 14:55:37 -0800
Message-ID: <20071127145537.6bf1af68@freepuppy.rosehill>
References: <18252.26472.319078.165019@robur.slu.se>
	<20071127140904.20c4cba8@freepuppy.rosehill>
	<474C9B84.5090103@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37613 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752896AbXK0W4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:56:16 -0500
In-Reply-To: <474C9B84.5090103@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 14:34:44 -0800
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 27 Nov 2007 19:52:24 +0100
> > Robert Olsson <Robert.Olsson@data.slu.se> wrote:
> > 
> >> Hello!
> >>
> >> I've discovered a bug while testing the new multiQ NAPI code. In hi-load 
> >> situations when we take down an interface we get a kernel panic. The
> >> oops is below.
> >>
> >> From what I see this happens when driver does napi_disable() and clears
> >> NAPI_STATE_SCHED. In net_rx_action there is a check for work == weight 
> >> a sort indirect test but that's now not enough to cover the load situation. 
> >> where we have NAPI_STATE_SCHED cleared by e1000_down in my case and still 
> >> full quota. Latest git but I'll guess the is the same in all later kernels.
> >> There might be different solutions... one variant is below:
> > 
> > It is considered a driver bug in 2.6.24 to call netif_rx_complete (clear NAPI_STATE_SCHED)
> > and do a full quota. That bug already had to be fixed in other drivers,
> > look like e1000 has same problem.
> 
> Stephen,
> 
> please enlighten me, can you e.g. show me a commit of other drivers where you
> fixed this up?
> 
> Thanks,
> 
> Auke

Author: David S. Miller <davem@sunset.davemloft.net>  2007-10-11 18:08:29
Committer: David S. Miller <davem@sunset.davemloft.net>  2007-10-11 18:08:29
Parent: b9f2c0440d806e01968c3ed4def930a43be248ad ([netdrvr] Stop using legacy hooks ->self_test_count, ->get_stats_count)
Child:  266918303226cceac7eca38ced30f15f277bd89c ([SKY2]: status polling loop (post merge))
Branches: master, origin
Follows: v2.6.23
Precedes: v2.6.24-rc1

    [NET]: Fix NAPI completion handling in some drivers.
    
    In order for the list handling in net_rx_action() to be
    correct, drivers must follow certain rules as stated by
    this comment in net_rx_action():
    
    		/* Drivers must not modify the NAPI state if they
    		 * consume the entire weight.  In such cases this code
    		 * still "owns" the NAPI instance and therefore can
    		 * move the instance around on the list at-will.
    		 */
    
    A few drivers do not do this because they mix the budget checks
    with reading hardware state, resulting in crashes like the one
    reported by takano@axe-inc.co.jp.
    
    BNX2 and TG3 are taken care of here, SKY2 fix is from Stephen
    Hemminger.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
