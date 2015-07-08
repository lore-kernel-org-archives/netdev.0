From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source
 addresses
Date: Wed, 08 Jul 2015 14:41:08 -0700 (PDT)
Message-ID: <20150708.144108.1074660115445698837.davem@davemloft.net>
References: <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
	<1436345014.3846.11.camel@stressinduktion.org>
	<CAAedzxqvEx+dMCmM5YLbnmd9REpcWFi=+nZ4s0EaBe8mxSKKgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbGHVlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:41:11 -0400
In-Reply-To: <CAAedzxqvEx+dMCmM5YLbnmd9REpcWFi=+nZ4s0EaBe8mxSKKgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Wed, 8 Jul 2015 21:41:58 +0900

>> I really would like to come up with a sane works-always behavior for
>> this, but besides doing a retry on the complete source address selection
>> algorithm I currently cannot come up with an idea.
>>
>> Maybe we can tweak saddr_eval a bit.
> 
> I think it all comes down to this: source address selection really
> doesn't know anything about routing that could help it make a better
> evaluation.
> 
> Reading the RFCs that seems to be by design, or at the very least
> there is a kind of "implied flat-ish routing table" at work, which the
> algorithm works around by having various "prefer same interface" type
> of rules. So, after the routing lookup to determine outgoing interface
> it's just looking at all the addresses on all the interfaces.  There
> is no checking of any of the multiple possible routing tables, in part
> because there just isn't all the right information available.
> 
> So, I figured the safe thing to do would be to not change existing
> default behaviour but just introduce a knob to at least make it
> possible to get the RFC recommended behaviour.
> 
> ---
> 
> Re: not having a source address or returning a link-local source for a
> global destination:  I think that's perfectly ok, if the knob is set.
> Frequently the source address will just be tossed into a salad bowl of
> (src, dst) pairs returned from DNS and 3484/6724 sorting will then
> help pick a more globally optimum (src, dst) to work with.

The fact is, if wireless APs are going to reject packets sent out in
the very circumstances this is claiming to help, our default behavior
is broken because communication is not possible.

So we should look at a way at making the new behavior the default, and
in fact that makes sense and we can even optimize this piece of saddr
selection code to not do an iteration over all devices in the system
for no reason at all.  It can just do a quick dev_get_by_index() and
work with that.
