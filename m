From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution function
Date: Sat, 10 May 2014 10:12:20 -0700
Message-ID: <536E5DF4.8010908@gmail.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>	<1399553434-25617-2-git-send-email-amirv@mellanox.com> <20140509.162454.1317479460010270185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>, amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:40773 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbaEJRMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 13:12:24 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so4909118pde.12
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 10:12:23 -0700 (PDT)
In-Reply-To: <20140509.162454.1317479460010270185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2014 01:24 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu,  8 May 2014 15:50:33 +0300
> 
>> From: Ido Shamay <idos@mellanox.com>
>>
>> This commit exposes an header length compution generic function,
>> introduced in some of Intel's Etherent drivers (igb and ixgbe),
>> to net public namespace under the name __net_get_headlen,
>> where it can be used by other vendors and removes code duplication.
>>
>> Signed-off-by: Ido Shamay <idos@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> 
> First of all, this appears (at least to me) to duplicate a lot of
> what the existing flow dissector can do.
> 
> For example, you can probably call skb_flow_dissect() and the
> filled in flow_keys has much of what you need.  If it doesn't
> have everything you need consider extending it.
> 
> Even if that won't work out, you must add a detailed comment, with
> kernel doc, above the declaration for this new interface in the
> header file.
> 
> I honestly still have no idea exactly what this function does and
> exactly what it's trying to achieve.

Actually the flow keys with the exception of maybe thoff and ip_proto
are pretty much useless to us for our purpose.  As is we are left to
then go off and compute the header length of the transport before we get
to the information we need.

The two functions are very similar though.  It might be worth while to
actually park the two next to each other so that it is obvious that when
one gets updated to support a new protocol the other should as well.  So
for example the headlen function could pick up some of the tunnel stuff.

The main difference between __net_get_headlen() and skb_flow_dissect()
is that skb_flow_dissect is meant to work on a packet headed in either
direction, as such there are multiple calls to skb_copy_bits and all the
copies out of the paged area that go with it.  __net_get_headlen() is
meant to be called by the base netdev on a linear buffer to parse
through everything from the start of the Ethernet header to the start of
the data section and determine the length of that region.  So one
obvious difference is that we care about the length of non-l4 headers,
whereas skb_flow_dissect does not.

Thanks,

Alex
