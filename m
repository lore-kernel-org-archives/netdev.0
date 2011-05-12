From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 20:18:58 +0100
Message-ID: <1305227938.5214.48.camel@bwh-desktop>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
	 <1305221242.5214.36.camel@bwh-desktop>
	 <F9877D83-226B-4C7A-AD01-E9AA441AD1CD@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33623 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755816Ab1ELTTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 15:19:01 -0400
In-Reply-To: <F9877D83-226B-4C7A-AD01-E9AA441AD1CD@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 11:53 -0700, Anirban Chakraborty wrote:
> On May 12, 2011, at 10:27 AM, Ben Hutchings wrote:
> 
> > On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
> >> Driver checks if the previous dump has been cleared before taking the dump.
> >> It doesn't take the dump if it is not cleared.
> >> 
> >> Changes from v2:
> >> Added lock to protect dump data structures from being mangled while
> >> dumping or setting them via ethtool.
> > 
> > Unfortunately it still seems to be possible for the dump length to
> > change between the ethtool core calling qlcnic_get_dump_flag() and
> > qlcnic_get_dump_data().
> 
> dump length is serialized via the driver lock. dump length is a static
> entity for a given capture mask and it can only be changed when there
> is a different capture mask set in the driver (via calling set_dump()
> from ethtool core).

OK.

> Actual dump size is determined during the initial steps of FW dump
> which takes the driver lock to start with. So, I am not sure how the
> dump length could be changed between the calls to get_dump_flag and
> get_dump_data from within the ethtool core without a call to
> set_dump() in between.
[...]

What prevents this sequence:

1. Driver detects firmware dump is required, and creates the dump
(length L1).
2. User changes firmware dump flags through ethtool.
3. User starts to save firmware dump through ethtool:
   a. ethtool utility reads dump length (= L1) and allocates user buffer
   b. ethtool utility reads dump:
   c. ethtool core reads dump length (L1) and allocates kernel buffer
4. Meanwhile, driver detects firmware dump is required again, and
creates a new dump (length L2, since dump flags changed)
5. (Continuation of 3)
   d. ethtool core calls driver to read firmware dump
   e. Driver copies new dump (length L2) into buffer of length L1

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

