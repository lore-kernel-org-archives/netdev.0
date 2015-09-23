From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 16:09:14 -0500
Message-ID: <878u7w6dxh.fsf@x220.int.ebiederm.org>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
	<8761313ud5.fsf@x220.int.ebiederm.org>
	<20150923225456.74c5cd1d@griffin>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40145 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbIWVQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:16:49 -0400
In-Reply-To: <20150923225456.74c5cd1d@griffin> (Jiri Benc's message of "Wed,
	23 Sep 2015 22:54:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc <jbenc@redhat.com> writes:

> On Wed, 23 Sep 2015 12:42:30 -0500, Eric W. Biederman wrote:
[snip]
>> So perhaps instead of:
>> +	if (arp->ar_op == htons(ARPOP_REQUEST) && skb_metadata_dst(skb))
>> +		reply_dst = (struct dst_entry *)
>> +			    iptunnel_metadata_reply(skb_metadata_dst(skb),
>> +						    GFP_ATOMIC);
>> +
>> The code would be:
>> 	if (arp->ar_op == htons(AROP_REQUEST) && dev->ndo_reply_dst)
>> 		reply_dst = dev->ndo_reply_dst(skb, GFP_ATOMIC);
>
> This is something I intended to do originally. I also considered adding
> the callback into metadata_dst itself. However, it doesn't make much
> sense for the time being.

If you convert this into the equivalent for neighbour discovery where
the ingress metadata dst has already been lost it makes a lot of sense.

Which is the question you were asking that I have been replying to as
I think this all through.

[snip]

> If there's another user of metadata_dst in the future, this needs to be
> changed anyway. We can add such ndo callback (or some other kind of
> callback) then, if it turns out to be needed. For now, we don't need it
> and the changes to make metadata_dst usable for other things than IP
> tunnels are not suitable for net.git.

I think you were misunderstanding what I was suggesting.

I was suggesting an ndo callback that does not need an metadata dst on
the skb but has enough information between the network device and the
skb itself to properly construct a dst that can be used for arp and
ndisc type replies where you want to exactly reverse the path.

*Blink* You were targeting net.git with a feature enhancement????
I will just ignore that.

>> For any network that does interesting things with network level
>> identifiers below IP this seems like a general problem.  Further it
>> seems more desirable to only perform an allocation when necessary,
>> rather than for every packet, and two for the packets that actually
>> need replies.
>
> The metadata_dst are only allocated when requested. Look at e.g.
> vxlan_collect_metadata function. If they're requested, it means they are
> needed. And they certainly need to be allocated for ARP replies to such
> packets. I don't see what could be further optimized here. Seems to me
> that you assume that the sole purpose of why metadata_dst exist is ARP
> which is not the case.

What I was observing is that in general the only tunneled packets that
need an ingress metadata dst for a tunneled medium ethernet like medium
are arp and ndisc packets.  In other cases if you aren't doing something
exceptional like openvswitch the normal routing should be sufficient.

Which means a ndo_reply_dst method could remove the need in many cases
for an ingress metadata dst to need to be allocated.

Regardless a netdevice operation that digs into the packet and figures
out what is necessary for a reply seems like the clean way to make this
work for both arp and neighbour discovery.

Eric
