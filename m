From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 09:43:00 -0800
Message-ID: <CALx6S378mozgF0A1iq=Y_LB+_5c=_8_iwOYBgoSArUJW60A6Ag@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<20160130024556.6227.51798.stgit@localhost.localdomain>
	<1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160130161702.GA11601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38302 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbcA3RnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 12:43:01 -0500
Received: by mail-ig0-f179.google.com with SMTP id mw1so9179006igb.1
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 09:43:01 -0800 (PST)
In-Reply-To: <20160130161702.GA11601@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 8:17 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 19:23), Eric Dumazet wrote:
>> BTW, even a memcpy(&key_addrs->v4addrs, &iph->saddr, 8) could crash, as
>> the compiler can certainly assume src and dst are 4 bytes aligned, and
>> could use word accesses when inlining memcpy() even on Sparc.
>>
>> Apparently the compiler used by Sowmini is gentle.
>
> One more subtlety that I missed until now..
>
> eth_get_headlen passes in flow_keys_buf_dissector (NOT flow_keys_dissector!)
>
> So FLOW_DISSECTOR_KEY_IPV4_ADDRS is not set, and this helps to dodge
> the unaligned iph->saddr access.
>
> But as others have pointed out, much of this code is brittle
> because it's accessing the data before the driver has had a chance
> to align things. The page_offset initialization of NET_IP_ALIGN,
> with all its weaknesses, at least matches (in principle) the prescription
> used for the xmit path.
>
That is not the only case, If a GRE TEB packet is ever received and
flow dissector is called for any reason (like skb_get_hash) there's
going to be problems-- and this doesn't require GRE to even be
configured on the host.

I have a patch that changes the 32-bit accesses in flow_dissector to
use get_unaligned_be32. I don't have access to any machines that care
about alignment (only x86). Do you know if there is an alternate way
to test this other than running on architecture like Sparc?

Thanks,
Tom

> --Sowmini
>
