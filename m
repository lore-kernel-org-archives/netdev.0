From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/2] ufp: UDP Fast Port
Date: Sat, 26 Jul 2014 15:29:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407261517500.27021@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:58610 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaGZW3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 18:29:20 -0400
Received: by mail-qa0-f73.google.com with SMTP id s7so967532qap.0
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 15:29:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements a fast path for UDP receive and enables
that for VXLAN. The idea is to perform a simple demux lookup on
the received destination port which is done in lieu of performing a
normal socket lookup on a match. This is modeled after the packet_type
lookup mechanism (including registeration functions). The advantage of
this is that we don't need to perform a socket lookup or access the
socket (paricularly avoids expensive socket references).

The primary use of this is expected to be UDP tunneling where the
UDP header is nothing more than a shim and demux is always done on
destination port. The mechanism is essentially equivalent to binding
to the port and INADDR_ANY. When used this will overshadow connected
sockets on the same port, and more specific bindings (like local
address). A user of this interface should do a normal bind to the
port and INADDR_ANY before registering the port for UFP.

Performance results with VXLAN using UFP. Tested with super_netperf
using 200 TCP_RR streams.

Without UFP
  94.57 CPU utilization
  153/245/455 90/95/995% latencies
  1.18699e+06 tps

With UFP enabled
  94.58 CPU utilization
  147/230/408 90/95/995% latencies
  1.20311e+06 tps

Also verified no noticeable regression using normal UDP sockets.
