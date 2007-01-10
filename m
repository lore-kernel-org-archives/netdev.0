From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 13:19:39 +0100
Message-ID: <45A4D9DB.4000809@trash.net>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103163427.14635.49596.stgit@nienna.balabit> <45A48BD6.5010507@trash.net> <200701101117.47576@nienna>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33494 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbXAJMTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 07:19:42 -0500
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <200701101117.47576@nienna>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KOVACS Krisztian wrote:
> On Wednesday 10 January 2007 07:46, Patrick McHardy wrote:
> 
>>>+			if (sk) {
>>>+				sock_hold(sk);
>>>+				skb->sk = sk;
>>
>>This looks racy, the socket could be closed between the lookup and
>>the actual use. Why do you need the socket lookup at all, can't
>>you just divert all packets selected by iptables?
> 
> 
>   Yes, it's racy, but I this is true for the "regular" socket lookup, too. 
> Take UDP for example: __udp4_lib_rcv() does the socket lookup, gets a 
> reference to the socket, and then calls udp_queue_rcv_skb() to queue the 
> skb. As far as I can see there's nothing there which prevents the socket 
> from being closed between these calls. sk_common_release() even documents 
> this behaviour:
> 
> 	[...]
> 	if (sk->sk_prot->destroy)
> 		sk->sk_prot->destroy(sk);
> 
> 	/*
> 	 * Observation: when sock_common_release is called, processes have
> 	 * no access to socket. But net still has.
> 	 * Step one, detach it from networking:
> 	 *
> 	 * A. Remove from hash tables.
> 	 */
> 
> 	sk->sk_prot->unhash(sk);
> 
> 	/*
> 	 * In this point socket cannot receive new packets, but it is possible
> 	 * that some packets are in flight because some CPU runs receiver and
> 	 * did hash table lookup before we unhashed socket. They will achieve
> 	 * receive queue and will be purged by socket destructor.
> 	 *
> 	 * Also we still have packets pending on receive queue and probably,
> 	 * our own packets waiting in device queues. sock_destroy will drain
> 	 * receive queue, but transmitted packets will delay socket destruction
> 	 * until the last reference will be released.
> 	 */
> 	[...]
>
>   Of course it's true that doing early lookups and storing that reference 
> in the skb widens the window considerably, but I think this race is 
> already handled. Or is there anything I don't see?

You're right, it seems to be handled properly (except I think there is
a race between sk_common_release calling xfrm_sk_free_policy and f.e.
udp calling __xfrm_policy_check, will look into that).

It probably shouldn't be cached anyway, with nf_queue for example
the window could be _really_ large.

