From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] l2tp: Fix a UDP socket reference count bug in the pppol2tp
 driver
Date: Wed, 27 Jan 2010 13:14:56 +0000
Message-ID: <4B603C50.20406@katalix.com>
References: <20100121161009.5223.34288.stgit@bert.katalix.com> <20100123.015511.83860202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52713 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286Ab0A0NPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 08:15:55 -0500
In-Reply-To: <20100123.015511.83860202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Thu, 21 Jan 2010 16:10:09 +0000
> 
>> The bug can cause a kernel stack trace when a tunnel socket is closed.
>>
>> WARNING: at include/net/sock.h:435 udp_lib_unhash+0x117/0x120()
>> Pid: 1086, comm: openl2tpd Not tainted 2.6.33-rc1 #8
>> Call Trace:
> 
> This fix doesn't look right at all.
> 
> You grab one reference in connect() and then drop a reference
> every single recvmsg() call.

No, one ref is grabbed when the UDP socket is prepared for L2TP. Another
ref is grabbed while processing a skb in the receive path.

> recvmsg() calls to connect() would be many to one, so I can't
> see how this reference counting scheme could possibly work.

Perhaps you missed the sock_hold() in pppol2tp_sock_to_tunnel(), which
is called for every received skb in pppol2tp_recv_core()?

When userspace closes all session sockets in the tunnel, including the
special tunnel pppol2tp socket which has session_id==0, the ref on the
UDP tunnel socket is dropped, which allows it to be released.

> Why don't you describe the exact sequence of events that lead
> to the trace, so we can figure out how to correct this
> properly?

A way to reproduce the issue is to prepare the UDP socket for L2TP (by
opening a tunnel pppol2tp socket) and then close it before any L2TP
sessions are added to it. The sequence is

Create UDP socket
Create tunnel pppol2tp socket to prepare UDP socket for L2TP
  pppol2tp_connect: session_id=0, peer_session_id=0
L2TP SCCRP control frame received (tunnel_id==0)
  pppol2tp_recv_core: sock_hold()
  pppol2tp_recv_core: sock_put
L2TP ZLB control frame received (tunnel_id=nnn)
  pppol2tp_recv_core: sock_hold()
  pppol2tp_recv_core: sock_put
Close tunnel management socket
  pppol2tp_release: session_id=0, peer_session_id=0
Close UDP socket
  udp_lib_close: BUG

The addition of sock_hold() in pppol2tp_connect() solves the problem.

For data frames, two sock_put() calls were added to plug a refcnt leak
per received data frame. The ref that is grabbed at the top of
pppol2tp_recv_core() must always be released, but this wasn't done for
accepted data frames or data frames discarded because of bad UDP
checksums. This leak meant that any UDP socket that had passed L2TP data
traffic (i.e. L2TP data frames, not just L2TP control frames) using
pppol2tp would not be released by the kernel.

Does the above help?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

