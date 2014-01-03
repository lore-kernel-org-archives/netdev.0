From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: move rt_genid to different cache line
Date: Thu, 02 Jan 2014 16:38:54 -0800
Message-ID: <1388709534.12212.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37326 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbaACAi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:38:56 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so13197660pab.23
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 16:38:56 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 12:00 -0800, Tom Herbert wrote:
> Running a simple netperf TCP_RR test with 200 clients shows that
> ipv4_dst_check is high on the list of functions in 'perf top'. The
> pertinent action in this function is in the call to rt_is_expired
> which checks the route genid (rt->rt_gentid) against the global value.
> rt_genid is in the same cacheline as dst->__refcnt which is causing
> false sharing.
> 
> This fix moves rt_genid into the first cacheline of the dst structure.
> The dst structue is explicitly packed for cacheline optimization, so to
> make room for the genid, I moved xfrm to cacheline with __refcnt (under
> the assumption it is less likely to be in the critical path).

This looks like a difficult to check assumption to me ....

rcu_head surely could be moved without performance impact.

Again, optimizing network stack for 200 TCP_RR special case is very
questionable. The dst must be refcounted because of special prequeue
mode, where a thread is blocked in a recvmsg() call.

Any modern application handling lot of sockets uses poll()/epoll()
anyway and prequeue is disabled : No refcount is taken, as the dst is
released (no refcount touch because of RCU) before the skb is queued
into socket receive queue.
