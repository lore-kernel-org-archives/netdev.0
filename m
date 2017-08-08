From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/7] rtnetlink: allow to run selected handlers without rtnl
Date: Tue,  8 Aug 2017 18:02:29 +0200
Message-ID: <20170808160236.28562-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35524 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752104AbdHHQCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RTNL mutex is used to serialize both rtnetlink calls and dump requests.
Its also used to protect other things such as the list of current netns.

Unfortunately RTNL mutex is a performance issue, e.g. a cpu adding an
ip address prevents other cpus from seemingly unrelated tasks such as
dumping tc classifiers.

This patch set attempts to add basic infrastructure to start pushing the
rtnl lock down to those places that need it, or even elide it entirely in
some cases.

Subsystems can now indicate that their doit() callback can run without
RTNL mutex.  Such callbacks can then run in parallel.

This will obviously need a lot of followup work; all current users need
to be audited/changed to benefit from this.

Initial no-rtnl spots are ip6 fib add/del and netns new/getid.

Dumps are another problem entirely, see
commit 2907c35ff64708065 ("net: hold rtnl again in dump callbacks"),
this patchset doesn't touch them.
