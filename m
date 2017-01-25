From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: ignore null_entry on route dumps
Date: Tue, 24 Jan 2017 20:39:32 -0500 (EST)
Message-ID: <20170124.203932.616922168982477148.davem@davemloft.net>
References: <20170122.235829.1911961579892347071.davem@davemloft.net>
        <a1eaeddc-69df-e0fa-c06a-285c3234249c@cumulusnetworks.com>
        <95b123db-a760-b73a-a858-9be0516799fc@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdAYBje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 20:39:34 -0500
In-Reply-To: <95b123db-a760-b73a-a858-9be0516799fc@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 24 Jan 2017 18:35:02 -0700

> On 1/23/17 9:51 AM, David Ahern wrote:
>> On 1/22/17 9:58 PM, David Miller wrote:
>>> David, please slow down.
>>>
>>> How is the NULL entry getting selected to be dumped and passed
>>> down here in the first place?
>> The null_entry might be a 'marker' but is integral to the ipv6 fib.
> 
> As I mentioned in my last response the null_entry is tb6_root.leaf for all tables making it part of the table. Since the dump walks the table and sends each route to rt6_dump_route, the dump includes the null_entry.
> 
> ip6_null_entry->rt6i_idev is NULL because ip6_route_net_init is run before addrconf_init has initialized the loopback device.
> 
> Given that, it seems like a check is needed somewhere ...  be it 'rt == net->ipv6.ip6_null_entry' in rt6_dump_route or fib6_dump_node, or a check for rt6i_idev NULL in rt6_fill_node.
> 
> You marked the last patch as changes needed meaning another needs to be sent.
> 
> Suggestion?

Probably putting the check as high in the call chain as possible, via
fib6_dump_node(), is the best.

Although, it's troubling that we are trying to dump unfinished entries
simply because of initialization order.  It's arguable that this is
the real thing to fix.

The loopback device is a hard dependency which the ipv6 stack has
because of how it does statistics and other things.
