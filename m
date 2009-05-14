From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] dropmon: add ability to detect when
	hardwaredropsrxpackets
Date: Thu, 14 May 2009 09:17:28 -0700
Message-ID: <20090514161728.GH6744@linux.vnet.ibm.com>
References: <20090508195026.GB13017@hmsreliant.think-freely.org> <4A05230B.6070806@cosmosbay.com> <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:33524 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbZENQR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 12:17:29 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4EGDGr0014633
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 12:13:16 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4EGHT1W087106
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 12:17:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4EGHTe1021979
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 12:17:29 -0400
Content-Disposition: inline
In-Reply-To: <20090514124407.GP3517@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2009 at 02:44:08PM +0200, Jiri Pirko wrote:
> Thu, May 14, 2009 at 02:33:00PM CEST, nhorman@tuxdriver.com wrote:
> >> 
> >> The purpose of list_add_rcu() and list_del_rcu() is to be able to permit
> >> concurrent readers to traverse the list while you are modifying that same
> >> list.  You still need something to handle concurrent updates to the list.
> >> The usual approach is to use locks, in this case, to hold trace_state_lock
> >> across the addition, given that it is already held across the removal.
> >> 
> >> The reason that I expect holding the lock to be OK is that you cannot
> >> add elements faster than you delete them long-term, so given that you
> >> are willing to hold the lock over deletions, you are probably OK also
> >> holding that same lock over additions.  But please let me know if that
> >> is not the case!
> >> 
> >> 							Thanx, Paul
> >> 
> >
> >
> >Ahh, I did learn something then :).  That makes sense, ok. New patch attached.
> >
> >Patch to add the ability to detect drops in hardware interfaces via dropwatch.
> >Adds a tracepoint to net_rx_action to signal everytime a napi instance is
> >polled.  The dropmon code then periodically checks to see if the rx_frames
> >counter has changed, and if so, adds a drop notification to the netlink
> >protocol, using the reserved all-0's vector to indicate the drop location was in
> >hardware, rather than somewhere in the code.
> >   
> >change notes:
> >1) added use of trace_state_lock around list_add_rcu operation
> >
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >
> >
> > include/linux/net_dropmon.h |    7 ++
> > include/trace/napi.h        |   11 ++++
> > net/core/dev.c              |    5 +
> > net/core/drop_monitor.c     |  115 ++++++++++++++++++++++++++++++++++++++++++--
> > net/core/net-traces.c       |    4 +
> > net/core/netpoll.c          |    2 
> > 6 files changed, 139 insertions(+), 5 deletions(-)
> >
> >diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h

[ . . . ]

> > static int set_all_monitor_traces(int state)
> > {
> > 	int rc = 0;
> >+	struct dm_hw_stat_delta *new_stat = NULL;
> >+
> >+	spin_lock(&trace_state_lock);
> > 
> > 	switch (state) {
> > 	case TRACE_ON:
> > 		rc |= register_trace_kfree_skb(trace_kfree_skb_hit);
> >+		rc |= register_trace_napi_poll(trace_napi_poll_hit);
> > 		break;
> > 	case TRACE_OFF:
> > 		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit);
> >+		rc |= unregister_trace_napi_poll(trace_napi_poll_hit);
> > 
> > 		tracepoint_synchronize_unregister();
> >+
> >+		/*
> >+		 * Clean the device list
> >+		 */
> >+		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> 		^^^^^^^^^^^^^^^^^^^^^^^
> This is meaningless here. Use list_for_each_entry_rcu only under rcu_read_lock.
> Also it would be good to use list_for_each_entry_safe here since you're
> modifying the list.

Either way works, as the list_del_rcu() leaves the forward pointers
intact.  So I don't have an opinion either way on this particular piece
of code.  More experience will be needed to work out which approach is
less confusing.  :-/

If this code was shared between the read side and the update side, then
you really would want to be able to use list_for_each_entry_rcu() on the
update side.

							Thanx, Paul
