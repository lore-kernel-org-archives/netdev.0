From: Phil Oester <kernel@linuxace.com>
Subject: Netfilter owner match breakage
Date: Tue, 27 Aug 2013 13:24:45 -0700
Message-ID: <20130827202445.GA3114@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49918 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab3H0UYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:24:52 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5291237pad.19
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:24:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 90ba9b19 (tcp: tcp_make_synack() can use alloc_skb()), Eric changed
the call to sock_wmalloc in tcp_make_synack to alloc_skb.  In doing so,
the netfilter owner match lost its ability to block the SYNACK packet on
outbound listening sockets.  For example:

[phil@f19_main ~]$ id
uid=1000(phil) gid=1000(phil) groups=1000(phil)

[phil@f19_main ~]$ sudo iptables -A OUTPUT -p tcp -m owner --uid-owner 1000 -j REJECT

[phil@f19_main ~]$ echo hi | nc -l -p 8888

Before this commit, attempting to connect to the port 8888 listener generated
this:

10.10.10.1.47457 > 10.10.10.110.8888: Flags [S], seq 1855270582 [...]
10.10.10.110 > 10.10.10.110: ICMP 10.10.10.1 tcp port 47457 unreachable, length 68

After this commit, the session is established but the first packet of the
session gets rejected:

10.10.10.1.47453 > 10.10.10.110.8888: Flags [S], seq 2089355862 [...]
10.10.10.110.8888 > 10.10.10.1.47453: Flags [S.], seq 2554257713, ack 2089355863 [...]
10.10.10.1.47453 > 10.10.10.110.8888: Flags [.], ack 1, win 115 [...]
10.10.10.110 > 10.10.10.110: ICMP 10.10.10.1 tcp port 47453 unreachable, length 63

Reverting 90ba9b19 (and adjusting for the removal of s_data_desired) fixes the
problem.  Is there a better way to do this?

Phil
