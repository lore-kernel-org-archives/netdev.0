From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 07:55:33 -0700
Message-ID: <CA+mtBx8tHJ1QkJWMSUVfFp_a4ymjsf7fA=wL+VQTJMKXmj0uuQ@mail.gmail.com>
References: <4FFDC985.6050805@hp.com>
	<1342050592.3265.8195.camel@edumazet-glaptop>
	<1342078459.3265.8244.camel@edumazet-glaptop>
	<20120712.003700.49235222504944712.davem@davemloft.net>
	<1342079487.3265.8245.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	ycheng@google.com, dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, mattmathis@google.com,
	nanditad@google.com, ncardwell@google.com, andrewmcgr@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47759 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932571Ab2GLOzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:55:35 -0400
Received: by yhmm54 with SMTP id m54so2784387yhm.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 07:55:34 -0700 (PDT)
In-Reply-To: <1342079487.3265.8245.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 12:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-12 at 00:37 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 12 Jul 2012 09:34:19 +0200
>>
>> > On Thu, 2012-07-12 at 01:49 +0200, Eric Dumazet wrote:
>> >
>> >> The 10Gb receiver is a net-next kernel, but the 1Gb receiver is a 2.6.38
>> >> ubuntu kernel. They probably have very different TCP behavior.
>> >
>> >
>> > I tested TSQ on bnx2x and 10Gb links.
>> >
>> > I get full rate even using 65536 bytes for
>> > the /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
>>
>> Great work Eric.
>
> Thanks !
>
This is indeed great work!  A couple of comments...

Do you know if there are are any qdiscs that function less efficiently
when we are restricting the number of packets?  For instance, will HTB
work as expected in various configurations?

One extension to this work be to make the limit dynamic and mostly
eliminate the tunable.  I'm thinking we might be able to correlate the
limit to the BQL limit of the egress queue for the flow it there is
one.

Assuming all work conserving qdiscs the minimal amount of outstanding
host data for a queue could be associated with the BQL limit of the
egress NIC queue.  We want to minimize the outstanding data so that:

sum(data_of_tcp_flows_share_same_queue) > bql_limit_for _queue

So this could imply a per flow limit of:

tcp_limit = max(bql_limit - bql_inflight, one_packet)

For a single active connection on a queue, the tcp_limit is equal to
the BQL limit.  Once the BQL limit is hit in the NIC, we only need one
packet outstanding per flow to maintain flow control.  For fairness,
we might need "one_packet" to actually be max GSO data.  Also, this
disregards any latency of scheduling and running the tasklet, that
might need to be taken into account also.

Tom
