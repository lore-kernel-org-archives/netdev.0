From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Tue, 27 Nov 2007 16:24:42 -0800
Message-ID: <474CB54A.2060804@intel.com>
References: <18252.26472.319078.165019@robur.slu.se>	<20071127140904.20c4cba8@freepuppy.rosehill>	<474C9B84.5090103@intel.com> <20071127145537.6bf1af68@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2964 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754355AbXK1A3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 19:29:38 -0500
In-Reply-To: <20071127145537.6bf1af68@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 27 Nov 2007 14:34:44 -0800
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Tue, 27 Nov 2007 19:52:24 +0100
>>> Robert Olsson <Robert.Olsson@data.slu.se> wrote:
>>>
>>>> Hello!
>>>>
>>>> I've discovered a bug while testing the new multiQ NAPI code. In hi-load 
>>>> situations when we take down an interface we get a kernel panic. The
>>>> oops is below.
>>>>
>>>> From what I see this happens when driver does napi_disable() and clears
>>>> NAPI_STATE_SCHED. In net_rx_action there is a check for work == weight 
>>>> a sort indirect test but that's now not enough to cover the load situation. 
>>>> where we have NAPI_STATE_SCHED cleared by e1000_down in my case and still 
>>>> full quota. Latest git but I'll guess the is the same in all later kernels.
>>>> There might be different solutions... one variant is below:
>>> It is considered a driver bug in 2.6.24 to call netif_rx_complete (clear NAPI_STATE_SCHED)
>>> and do a full quota. That bug already had to be fixed in other drivers,
>>> look like e1000 has same problem.
>> Stephen,
>>
>> please enlighten me, can you e.g. show me a commit of other drivers where you
>> fixed this up?
>>
>> Thanks,
>>
>> Auke
> 
> Author: David S. Miller <davem@sunset.davemloft.net>  2007-10-11 18:08:29
> Committer: David S. Miller <davem@sunset.davemloft.net>  2007-10-11 18:08:29
> Parent: b9f2c0440d806e01968c3ed4def930a43be248ad ([netdrvr] Stop using legacy hooks ->self_test_count, ->get_stats_count)
> Child:  266918303226cceac7eca38ced30f15f277bd89c ([SKY2]: status polling loop (post merge))
> Branches: master, origin
> Follows: v2.6.23
> Precedes: v2.6.24-rc1
> 
>     [NET]: Fix NAPI completion handling in some drivers.
>     
>     In order for the list handling in net_rx_action() to be
>     correct, drivers must follow certain rules as stated by
>     this comment in net_rx_action():
>     
>     		/* Drivers must not modify the NAPI state if they
>     		 * consume the entire weight.  In such cases this code
>     		 * still "owns" the NAPI instance and therefore can
>     		 * move the instance around on the list at-will.
>     		 */
>     
>     A few drivers do not do this because they mix the budget checks
>     with reading hardware state, resulting in crashes like the one
>     reported by takano@axe-inc.co.jp.
>     
>     BNX2 and TG3 are taken care of here, SKY2 fix is from Stephen
>     Hemminger.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>

OK, I'm not sure what went wrong there with e1000, but I'll send a patch in a second.

Robert, please give that patch a try (it fixes a crash that I had here as well)
and let us know if it works for you.

Auke
