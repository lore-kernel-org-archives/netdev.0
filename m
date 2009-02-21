From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH NET-NEXT 0/10] hardware time stamping with new fields
	in shinfo
Date: Sat, 21 Feb 2009 10:15:40 +0100
Message-ID: <1235207740.22598.26.camel@pohly-MOBL>
References: <1234450670.5914.9.camel@ecld0pohly>
	 <1234450981.5914.11.camel@ecld0pohly>
	 <20090215.231626.160752710.davem@davemloft.net>
	 <1234770294.10885.24.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "johnstul@us.ibm.com" <johnstul@us.ibm.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22246 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbZBUJPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2009 04:15:46 -0500
In-Reply-To: <1234770294.10885.24.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-02-16 at 07:44 +0000, Patrick Ohly wrote:
> On Mon, 2009-02-16 at 09:16 +0200, David Miller wrote:
> > That TX clone wrt. skb_orphan() issue will need a happier solution.
> > 
> > Can you describe that problem in detail?  Maybe someone can come
> > up with a way to avoid that stuff.
> 
> Bouncing information about a sent packet back to the sender (in
> skb_tstamp_tx()) requires access to the socket via which the packet was
> sent (orig_skb->sk).
> 
> This information must be available after the packet was handed to
> ops->ndo_start_xmit() in order to implement the TX time stamping
> software fallback for devices which don't implement hardware time
> stamping (not enabled and/or not implemented at all).

There's an even more fundamental problem: the TX software fallback in
net_dev_hard_start_xmit() has to access the skb after ndo_start_xmit()
has returned successfully.

During stress tests LAD colleagues at Intel ran into kernel panics that
pointed to net_dev_hard_start_xmit() as the culprit. Removing the
current TX software fallback code solved this. My apologies for not
realizing earlier that this code is violating skb ownership rules.

We propose to remove the faulty code and then solve it in a proper way
later on. Hardware time stamping will work fine without it. I will
forward the patch separately.

> I see several ways to solve this:
>       * Always create another reference to skb->sk before
>         ops->ndo_start_xmit() if TX time stamping is requested.
>         Drawback: performance penalty for drivers which support TX time
>         stamping or don't call skb_orphan().
[...]
>       * Extend the driver API + another reference. Let drivers which
>         implement TX time stamping (and thus know when to avoid
>         skb_orphan()) signal that. dev_hard_start_xmit() then can avoid
>         the "additional sk reference" thing for these drivers. Drawback:
>         requires analyzing and potentially flagging all drivers to have
>         a real effect (as for bnx2).

Something along these lines with an additional reference to the skb
might work.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


