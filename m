From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 1/4] net: ipv6: Make inet6addr_validator a blocking
 notifier
Date: Wed, 11 Oct 2017 15:56:47 -0600
Message-ID: <8e0a3f28-14fd-337d-c2e0-6b8419cbdddb@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-2-git-send-email-dsahern@gmail.com>
 <20171011.141301.998956921662009292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36152 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbdJKV4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:56:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id z11so3483883pfk.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:56:49 -0700 (PDT)
In-Reply-To: <20171011.141301.998956921662009292.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 3:13 PM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Tue, 10 Oct 2017 09:41:02 -0700
> 
>> +	/* validator notifier needs to be blocking;
>> +	 * do not call in softirq context
>> +	 */
>> +	if (!in_softirq()) {
> 
> I think we can test this better.

The callchain we are protecting against is
            7fff8149d0dd ipv6_add_addr ([kernel.kallsyms])
            7fff814a161b addrconf_prefix_rcv ([kernel.kallsyms])
            7fff814afb8a ndisc_router_discovery ([kernel.kallsyms])
            7fff814b0310 ndisc_rcv ([kernel.kallsyms])
            7fff814b62da icmpv6_rcv ([kernel.kallsyms])
            7fff81499c37 ip6_input_finish ([kernel.kallsyms])
            7fff81499e96 ip6_input ([kernel.kallsyms])
            7fff8149a519 ip6_mc_input ([kernel.kallsyms])
            7fff81499f9d ip6_rcv_finish ([kernel.kallsyms])
            7fff8149a349 ipv6_rcv ([kernel.kallsyms])
            7fff813fbe12 __netif_receive_skb_core ([kernel.kallsyms])
            7fff813fc04c __netif_receive_skb ([kernel.kallsyms])
            7fff813ff97c netif_receive_skb_internal ([kernel.kallsyms])

> 
> You should be able to audit the call sites and for each one set the
> value of a new boolean argument properly, and this way you can also
> give the boolean argument a descriptive name.

The safest is an in_atomic() check, but to your point I'll see if the
caller can pass in atomic vs blocking option as a bool.

> 
> Furthermore, we can also then pull the inet6_addr allocation out of
> the locking paths and thus use GFP_KERNEL when possible.
> 

Yes, I was thinking about that as a follow on -- how far down can the
rcu_read_lock_bh be pushed.
