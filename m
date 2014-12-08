From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 0/2] netfilter: conntrack: route cache for forwarded connections
Date: Mon,  8 Dec 2014 16:36:02 +0100
Message-ID: <1418052964-4632-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52445 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376AbaLHPgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 10:36:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Pablo, in case you deem this too late for -next just let me know
and I will resend once its open again ]

This adds an optional forward routing cache extension for netfilter
connection tracking.

The memory cost is an additional 32 bytes per conntrack entry
on x86_64.

Unlike any other currently implemented connection tracking
extension the rtcache has no run-time tunables, it is always active.

Also, unlike other conntrack extensions, it can be built as a module,
in this case modprobe/rmmod are used to enable/disable the cache.

Forward test using netperf UDP_STREAM between two network namespaces
(connected via veth devices), tput:

With conntrack + reverse path filtering (rp_filter sysctl=1):
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.1.12.2 () port 0 AF_INET
Socket  Message  Elapsed      Messages
 Size    Size     Time         Okay Errors   Throughput
 bytes   bytes    secs            #      #   10^6bits/sec

  212992      64   120.00    26333996      0     112.36
  212992           120.00    26279399            112.13

same, but with rtcache (this patch series):
  212992      64   120.00    34508693      0     147.24
  212992           120.00    34507838            147.23

same but with rp_filter=0 and no conntrack modules active:
  212992      64   120.00    42288748      0     180.43
  212992           120.00    42283439            180.41

IOW, this is only useful if conntrack is used anyway.
