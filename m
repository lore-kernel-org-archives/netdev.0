From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH NET-NEXT 0/10] hardware time stamping with new fields
	in shinfo
Date: Mon, 16 Feb 2009 08:44:54 +0100
Message-ID: <1234770294.10885.24.camel@pohly-MOBL>
References: <1234450670.5914.9.camel@ecld0pohly>
	 <1234450981.5914.11.camel@ecld0pohly>
	 <20090215.231626.160752710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "johnstul@us.ibm.com" <johnstul@us.ibm.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504AbZBPHpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 02:45:00 -0500
In-Reply-To: <20090215.231626.160752710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-02-16 at 09:16 +0200, David Miller wrote:
> Ok, I applied everything and pushed it out to net-next-2.6, let's
> see how this goes :-)

Thanks :-)

> That TX clone wrt. skb_orphan() issue will need a happier solution.
> 
> Can you describe that problem in detail?  Maybe someone can come
> up with a way to avoid that stuff.

Bouncing information about a sent packet back to the sender (in
skb_tstamp_tx()) requires access to the socket via which the packet was
sent (orig_skb->sk).

This information must be available after the packet was handed to
ops->ndo_start_xmit() in order to implement the TX time stamping
software fallback for devices which don't implement hardware time
stamping (not enabled and/or not implemented at all).

The problem now is that some device drivers call skb_orphan() on the skb
in ops->ndo_start_xmit(). I suppose the intention is to free some
resources a bit earlier. The unmodified igb driver did this, the bnx2
one didn't.

If skb_orphan() is called, then TX software time stamping is not
possible. A user space daemon cannot detect this reliably, only make a
guess based on the observation that it doesn't receive any TX time
stamps. This is not fatal: the traditional time stamping method used by
PTPd (multicast loop back) still works.

But it would be nicer if that multicast loop back hack wasn't necessary.
TX software time stamping might also be more accurate (it generates the
time stamp after ops->ndo_start_xmit() returns, not before as in the
looped packet code path).

I see several ways to solve this:
      * Always create another reference to skb->sk before
        ops->ndo_start_xmit() if TX time stamping is requested.
        Drawback: performance penalty for drivers which support TX time
        stamping or don't call skb_orphan().
      * Turn skb_orphan() into a nop during ops->ndo_start_xmit(), again
        only if necessary. I think this can done by temporarily
        overriding the skb destructor. Drawback: looks like a hack to
        me, not sure whether that is really safe.
      * Extend the driver API + another reference. Let drivers which
        implement TX time stamping (and thus know when to avoid
        skb_orphan()) signal that. dev_hard_start_xmit() then can avoid
        the "additional sk reference" thing for these drivers. Drawback:
        requires analyzing and potentially flagging all drivers to have
        a real effect (as for bnx2).

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


