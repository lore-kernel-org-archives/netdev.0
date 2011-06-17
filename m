From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH 0/2] Tracepoints for queueing skb to rcvbuf
Date: Fri, 17 Jun 2011 17:56:55 -0400
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindmx01.hds.com ([207.126.252.12]:40548 "EHLO
	usindmx01.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875Ab1FQV5N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:57:13 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Kernel may drops packets when it queues them to socket receive buffer. 
Currently We can detect packet drop events and know when and where it
happened via kfree_skb tracepoint. But it's difficult to know a detailed
reason because there are some possibilities. 

In UDP case, core function for queueing skb to socket rcvbuf is 
__udp_queue_rcv_skb and its call chain is following:

__udp_queue_rcv_skb
 ip_queue_rcv_skb
  sock_queue_rcv_skb
   sk_rmem_schedule
    __sk_mem_schedule

We can catch a packet drop event in __udp_queue_rcv_skb and it means
ip_queue_rcv_skb/sock_queue_rcv_skb returned negative value.
In sock_queue_rcv_skb there are 3 possibilities-(*) where it returns
negative value but we can't separate them. Moreover sock_queue_rcv_skb calls
__sk_mem_schedule and there are several if satetements to decide whether
kernel should drop the packet.

To separate these reasons, this patchset adds 3 tracepoints.

1st one is added to __udp_queue_rcv_skb to get return value of
ip_queue_rcv_skb. Analyzing it we can separate above (*) (3 possibilities).

2nd and 3rd one are to get more detailed information. We can collect status 
of socket receive queue and related parameters(some of them are sysctl knob
e.g. /proc/sys/net/ipv4/udp_mem, etc. for UDP) and then we can tune kernel
behavior easily.

Any comments and feedback are welcome.


Satoru Moriya (2):
  udp: add tracepoint for queueing skb to rcvbuf
  core: add tracepoints for queueing skb to rcvbuf

 include/trace/events/sock.h |   68 +++++++++++++++++++++++++++++++++++++++++++
 include/trace/events/udp.h  |   32 ++++++++++++++++++++
 net/core/net-traces.c       |    2 +
 net/core/sock.c             |    5 +++
 net/ipv4/udp.c              |    2 +
 5 files changed, 109 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/sock.h
 create mode 100644 include/trace/events/udp.h


