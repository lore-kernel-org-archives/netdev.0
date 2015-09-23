From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 12:42:30 -0500
Message-ID: <8761313ud5.fsf@x220.int.ebiederm.org>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48022 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756184AbbIWRuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:50:10 -0400
In-Reply-To: <20150923162927.6d437a1f@griffin> (Jiri Benc's message of "Wed,
	23 Sep 2015 16:29:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc <jbenc@redhat.com> writes:

> On Wed, 23 Sep 2015 07:17:53 -0500, Eric W. Biederman wrote:
>> Assuming the transport is UDP then it would be a UDP socket.  That
>> socket will have all of the information needed to construct the outer
>> header as the receive path of that socket removes the outer header.
>> 
>> I admit you can't use the cached dst.  It is the wrong on that socket.
>> 
>> My point is that if we have the UDP socket and we have the sk we have
                                                              ^skb
>> all of the information we need to compute the reverse dst.
>
> That (single) UDP socket may represent many tunnels with different
> parameters. Knowing the socket is still not enough to construct the
> data. The only place where the needed data is stored is routing table
> which won't help us much for ARP, and the metadata dst attached to the
> incoming skb.

Having read through the code a bit more.  I understand more clearly what
is happening with metadata dsts.

Without your ARP changes in this patchset I don't understand what the
purpose of metadata dsts are, so I am probably still missing something
important.

If ARP and ndisc are the only uses of metadata dsts, allocating a
metadata dst for every packet seems undesirable.

In which case I suspect what is desriable is a ndo operation that
looks at the packet and computes the dst.

So perhaps instead of:
+	if (arp->ar_op == htons(ARPOP_REQUEST) && skb_metadata_dst(skb))
+		reply_dst = (struct dst_entry *)
+			    iptunnel_metadata_reply(skb_metadata_dst(skb),
+						    GFP_ATOMIC);
+
The code would be:
	if (arp->ar_op == htons(AROP_REQUEST) && dev->ndo_reply_dst)
		reply_dst = dev->ndo_reply_dst(skb, GFP_ATOMIC);


For any network that does interesting things with network level
identifiers below IP this seems like a general problem.  Further it
seems more desirable to only perform an allocation when necessary,
rather than for every packet, and two for the packets that actually
need replies.

Eric
