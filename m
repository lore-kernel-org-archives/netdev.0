From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:20:53 -0700 (PDT)
Message-ID: <20170407.122053.201153373954521345.davem@davemloft.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
        <20170407.115315.23470877439489670.davem@davemloft.net>
        <1491591552.5800.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, jiri@resnulli.us
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdDGTU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 15:20:56 -0400
In-Reply-To: <1491591552.5800.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 07 Apr 2017 20:59:12 +0200

> Alexander Shishkin's patch
> https://patchwork.kernel.org/patch/7162421/
> 
> was nice in a way because you could get away without passing the error
> structure down all the time, but like I said it doesn't deal with
> dynamic errors (even the offset/attr from nla_parse) and if it's not
> done *everywhere* it risks leaking those exterr numbers (-1024..-4095)
> to userspace through syscalls if it's used in a non-netlink path for
> some reason (e.g. a single driver call being called through both
> netlink and ioctl, and trying to return an extended error)

Alexander's patch is cute in that it annotates errors using the special
section blobs.

But what it lacks fundamentally is context.  Therefore it can't be
used to provide the offset or the bad attribute number.  So it can't
meet our requirements.

We've passed down new arguments into core method call chains for much
less useful facilitites than this.  So that doesn't bother me.  And
as that is a kernel internal matter, we can refine it later.

Wrt. nla_parse(), we can solve that problem as follow-on patches too.

So I consider this change ready as far as the implementation is
concerned.

Ok, Jiri, start reading.  I will try to make you happy here.

Let's just discuss the UAPI, since people complain we don't talk
about that enough :-)  For those playing at home it is three new
attributes returned in a netlink ACK when the application asks
for the extended response:

	NLMSGERR_ATTR_MSG	string	Extended error string
	NLMSGERR_ATTR_OFFS	u32	Byte offset to netlink element causing error
	NLMSGERR_ATTR_CODE	u32	Subsystem specific error code
	NLMSGERR_ATTR_ATTR	u16	Netlink attribute triggering error or missing

So please consider this interface carefully.
