From: Patrick Ohly <patrick.ohly@intel.com>
Subject: hardware time stamping with extra skb->hwtstamp
Date: Wed, 19 Nov 2008 13:08:37 +0100
Message-ID: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58043 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433AbYKSMIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series was discussed before on linux-netdev ("hardware
time stamping + igb example implementation"). Since then I have
rebased against net-next and addressed all comments sent so far,
except Octavian's suggestion to include more information in the
packet which is bounced back to the application.

As suggested by David, I'm now also including linux-kernel because:
 * patch 2 adds a new user space API (documentation and example
   program included, but no man page patch yet)
 * patch 8 extends the clocksource struct (mostly adds code, but
   also adds one branch to reading the clock, which may affect
   gettimeofday)
 * patch 10 adds generic code for time synchronization (not
   network specific, so people not subscribed to linux-netdev
   might have comments)

The open question on linux-netdev was whether struct sk_buff
should be extended to hold the additional hardware time
stamp. The previous patch avoided that at the cost of much more
complicated code and side effects on normal time stamping.

This patch now adds a 8 byte field unconditionally. The
implementation is a lot more straight-forward. The user space
API was already designed to cover this case, so it remained
unchanged.

There's one unsolved problem, though: time synchronization with
PTP (the use case I'm working on) requires a transformation of
raw hardware time stamps into system time. Currently this is done
at the socket level by finding the device which created the time
stamp and letting it do the transformation. This fails for
incoming packets because skb->rt points to the "lo" device.

Perhaps the interface number can be used to find the real
hardware device. Alternatively the conversion could be done when
generating the time stamp (might also be more accurate), but then
another 8 byte field is needed. Delta encoding won't help because
one cannot assume that hardware time stamps track system time
closely enough.

I'm posting the patch despite this problem so that the discussion
can move forward. There are other TODOs anyway; in particular the
igb extension is just a proof-of-concept.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.
