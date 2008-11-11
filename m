From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 00/13] hardware time stamping + igb example
	implementation
Date: Tue, 11 Nov 2008 15:44:57 +0100
Message-ID: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23511 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755908AbYKKO4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:56:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all!

This patch series is related to Octavian's proposals a while ago ("net:
support for TX timestamps", "net: support for hardware timestamps"). It
mostly implements the revised plan discussed recently ("hardware time
stamps + existing time stamp usage").

As part of that discussion there was no consensus on storing hardware
time stamps in sk_buff. One suggested solution for avoiding a new field
was based on storing a transformed hardware time stamp in the existing
field (thus keeping the existing code happy) and then transforming back
to the original hardware time base if needed.

This patch series follows that approach, but the utility code which is
used to transform from hardware time to system time doesn't implement
the necessary inverse transformation. This means that although access to
the original, raw hardware time stamp is part of the API, the
corresponding value is never actually reported by the existing code. If
this value is required, then the final patch shows how a separate
hardware time stamp field solves the problem with a lot less hassle.

If the extra field is considered acceptable unconditionally, then the
#ifdefs become redundant and the code much cleaner. I would prefer this
solution, but I don't know what the performance impact of a larger
sk_buff really is.

This patch series is currently based on v2.6.27. If it is considered for
inclusion, then I'd make sure that PTPd indeed works with this patch
(currently it has only been tested with the included example program)
and resubmit the patch based on the latest netdev branch. This is my
first contribution to the Linux kernel; it hasn't been discussed inside
Intel either. So please give it the treatment that a newbie patch
deserves: thorough, but not too harsh critisism ;-) Thanks!

I'm sure there will be things to correct. To spare you the trouble of
searching for them, here are some I already know of:
      * there's currently no locking of the newly added fields in the
        igb private data structure; I don't quite understand how locking
        currently works in the igb driver (or net_device in general) 
      * because of the missing locking I also haven't fully implemented
        the part which matches TX time stamps with the right outgoing
        packet and the "time stamp all packets" mode
      * as noted in the patch, the assumption that skb->sk is still
        valid after net_device->hard_start_xmit is not always true (this
        was what I mentioned earlier on this list, without actually
        understanding what was happening at that time)
      * in combination with IP_MULTICAST_LOOP packets which already
        carry a time stamp reach dev_start_hard_xmit(), which conflicts
        with the use of the time stamp field to carry time stamping
        requests

Any tips regarding them are very much appreciated.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

