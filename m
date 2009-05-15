From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 05:49:47 +0000
Message-ID: <20090515054947.GA4497@ff.dom.local>
References: <20090514172954.GA3867@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:52033 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbZEOFtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 01:49:51 -0400
Received: by fxm2 with SMTP id 2so1711299fxm.37
        for <netdev@vger.kernel.org>; Thu, 14 May 2009 22:49:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090514172954.GA3867@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-05-2009 19:29, Neil Horman wrote:
> On Thu, May 14, 2009 at 02:44:08PM +0200, Jiri Pirko wrote:
>>> +
>>> +		/*
>>> +		 * Clean the device list
>>> +		 */
>>> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
>> 		^^^^^^^^^^^^^^^^^^^^^^^
>> This is meaningless here. Use list_for_each_entry_rcu only under rcu_read_lock.
>> Also it would be good to use list_for_each_entry_safe here since you're
>> modifying the list.
>>
> 
> The definition of list_for_each_entry_rcu specifically says its safe against
> list-mutation primitives, so its fine.  Although you are correct, in that its
> safety is dependent on the protection of rcu_read_lock(), so I'll add that in.
> Thanks for the catch!  New patch attached
> 
> Change notes:
> 1) Add rcu_read_lock/unlock protection around TRACE_OFF event
> 
> Neil
...
>  static int set_all_monitor_traces(int state)
>  {
>  	int rc = 0;
> +	struct dm_hw_stat_delta *new_stat = NULL;
> +
> +	spin_lock(&trace_state_lock);
>  
>  	switch (state) {
>  	case TRACE_ON:
>  		rc |= register_trace_kfree_skb(trace_kfree_skb_hit);
> +		rc |= register_trace_napi_poll(trace_napi_poll_hit);
>  		break;
>  	case TRACE_OFF:
>  		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit);
> +		rc |= unregister_trace_napi_poll(trace_napi_poll_hit);
>  
>  		tracepoint_synchronize_unregister();
> +
> +		/*
> +		 * Clean the device list
> +		 */
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev == NULL) {
> +				list_del_rcu(&new_stat->list);
> +				call_rcu(&new_stat->rcu, free_dm_hw_stat);
> +			}
> +		}
> +		rcu_read_unlock();

IMHO it looks worse now. rcu_read_lock() suggests it's a read side,
and spin_lock(&trace_state_lock) protects something else.

Jarek P.
