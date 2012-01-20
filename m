From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 20 Jan 2012 13:07:02 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:50515 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914Ab2ATSHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:07:47 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change log v1 -> v2
- rewrite a patch description based on replies to v1 patchset
- add local port number to tracedata

Sometimes network packets are dropped for some reason. In enterprise
systems which require strict RAS functionality, we must know the
reason why it happened and explain it to our customers even if using
TCP. When we investigate the incidents, at first we try to find out
whether the packet drop is in the server(kernel, application) or else
(router, hub etc). Once we find it happened in the kernel, we try to
get more details.

Currently, there are some tools/interfaces, e.g. tcpdump,
dropwatch/skb:kfree_skb(tracepoint), netstat, /proc, systemtap etc, 
which help us analyze situations.
But unfortunately, they are too much for one, not enough for
the other. tcpdump captures all the packet but it's overkill because
we don't need all the packets' data but just dropped one. We can
get statistics via netstat and/or /proc but we need more information
to analyze the situation. skb:kfree_skb tracepoint is very useful
for detecting packet drop and analyzing it. In addition to it, if
we have tracepoints in TCP layer in particular retransmit path,
it is very helpful for us to dig into situations because with TCP
the kernel tries to resend packets before dropping them.

With this tracepoint, we can know whether the packet drop occurred
in the server (moreover in the kernel) or not. For example, if we
finds that retransmission failed (tcp_retransmit_skb() returned
negative value), it means the kernel may have some troubles at
that time and we can drill down on issues in the kernel based on
trace data. OTOH, if retransmission succeeded, packet is dropped
outside the kernel/server.


Satoru Moriya (2):
  tcp: refactor tcp_retransmit_skb() for a single return point
  tcp: add tracepoint for tcp retransmission

 include/trace/events/tcp.h |   38 ++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |    1 +
 net/ipv4/tcp_output.c      |   34 ++++++++++++++++++++++++----------
 3 files changed, 63 insertions(+), 10 deletions(-)
 create mode 100644 include/trace/events/tcp.h

-- 
1.7.6.4
