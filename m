From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 04/17] drivers/net/intel: use napi_complete_done()
Date: Fri, 13 Nov 2015 08:49:22 -0800
Message-ID: <1447433362.22599.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444945404-30654-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1447391896.22599.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56460A86.2000501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33674 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444AbbKMQtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 11:49:24 -0500
Received: by pabfh17 with SMTP id fh17so105067005pab.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 08:49:24 -0800 (PST)
In-Reply-To: <56460A86.2000501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-13 at 08:06 -0800, Alexander Duyck wrote:

> Yes, I'm pretty certain you cannot use this napi_complete_done with 
> anything that support busy poll sockets.  The problem is you need to 
> flush any existing lists before yielding to the socket polling in order 
> to avoid packet ordering issues between the NAPI polling routine and the 
> socket polling routine.

My plan is to make busy poll independent of GRO / RPS / RFS, and generic
if possible, for all NAPI drivers. (No need to absolutely provide
ndo_busy_poll()

I really do not see GRO being a problem for low latency : RPC messages
are terminated by PSH flag that take care of flushing GRO engine.

For mixed use, (low latency and other kind of flows), GRO is a win.

With the following sk_busy_loop() , we :

- allow tunneling traffic to use busy poll as well as native traffic.
- allow RFS/RPS being used (sending IPI to other cpus if needed)
- use the 'lets burn cpu cycles' to do useful work (like TX completions, RCU callbacks...)
- Implement busy poll for all NAPI drivers.

        rcu_read_lock();
        napi = napi_by_id(sk->sk_napi_id);
        if (!napi)
                goto out;
        ops = napi->dev->netdev_ops;

        for (;;) {
                local_bh_disable();
                rc = 0;
                if (ops->ndo_busy_poll) {
                        rc = ops->ndo_busy_poll(napi);
                } else if (napi_schedule_prep(napi)) {
                        rc = napi->poll(napi, 4);
                        if (rc == 4) {
                                napi_complete_done(napi, rc);
                                napi_schedule(napi);
                        }
                }
                if (rc > 0)
                        NET_ADD_STATS_BH(sock_net(sk),
                                         LINUX_MIB_BUSYPOLLRXPACKETS, rc);
                local_bh_enable();

                if (rc == LL_FLUSH_FAILED ||
                    nonblock ||
                    !skb_queue_empty(&sk->sk_receive_queue) ||
                    need_resched() ||
                    busy_loop_timeout(end_time))
                        break;

                cpu_relax();
        }
        rcu_read_unlock();
