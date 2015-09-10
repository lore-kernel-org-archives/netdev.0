From: Dan Streetman <dan.streetman@canonical.com>
Subject: xfrm4_garbage_collect reaching limit
Date: Thu, 10 Sep 2015 17:01:26 -0400
Message-ID: <CAOZ2QJPt=3YmLG=S2Zf70yNPwLf-dbWtiyWJNbfYMRrQ5C6EZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Streetman <ddstreet@ieee.org>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35029 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbIJVCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 17:02:07 -0400
Received: by ioiz6 with SMTP id z6so75971781ioi.2
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 14:02:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

I've been working with Jay on a ipsec issue, which I believe he
discussed with you.  In this case the xfrm4_garbage_collect is
returning error because the number of xfrm4 dst entries has exceeded
twice the gc_thresh, which causes new allocations of xfrm4 dst objects
to fail, thus making the ipsec connection unusable (until dst objects
are removed/freed).

The main reason the count gets to the limit is because the
xfrm4_policy_afinfo.garbage_collect function - which points to
flow_cache_flush (indirectly) - doesn't actually guarantee any xfrm4
dst will get cleaned up, it only cleans up unused entries.

The flow cache hashtable size limit watermark does restrict how many
flow cache entries exist (by shrinking the per-cpu hashtable once it
has 4k entries), and therefore indirectly controls the total number of
xfrm4 dst objects.  However, there's a mismatch between the default
xfrm4 gc_thresh - of 32k objects (which sets a 64k max of xfrm4 dst
objects) - and the flow cache hashtable limit of 4k objects per cpu.
Any system with 16 or less cpus will have a total limit of 64k (or
less) flow cache entries, so the 64k xfrm4 dst entry limit will never
be reached.  However for any system with more than 16 cpus, the flow
cache limit is greater than the xfrm4 dst limit, and so the xfrm4 dst
allocation can fail, rendering the ipsec connection unusable.

The most obvious solution is for the system admin to increase the
xfrm4_gc_thresh value, although it's not really an obvious solution to
the end-user what value they should set it to :-)  Possibly the
default value of xfrm4_gc_thresh could be set proportional to
num_online_cpus(), but that doesn't help when cpus are onlined after
boot.  Also, a warning message indicating the xfrm4_gc_thresh limit
was reached, and a suggestion to increase the limit, may help anyone
who hits the issue.

I'm not sure if something more aggressive is appropriate, like
removing active entries during garbage collection.  Or, removing the
failure condition from xfrm4_garbage_collect so xfrm4 dst_ops can
always be allocated, or just increasing it from gc_thresh * 2 up to *
4 or more.

Also, I refer to xfrm4 above, but I believe this will affect xfrm6 as well.

Any thoughts and/or suggestions?

Thanks!
