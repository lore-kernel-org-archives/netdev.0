From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Fri, 18 Mar 2016 18:58:23 +0100
Message-ID: <56EC41BF.3010501@gmail.com>
References: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
 <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:34071 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987AbcCRR6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:58:30 -0400
Received: by mail-lb0-f196.google.com with SMTP id vk4so7371275lbb.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 10:58:29 -0700 (PDT)
In-Reply-To: <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/16 22:15, Eric Dumazet wrote:
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Note that RDB probably should get some SNMP counters,
> so that we get an idea of how many times a loss could be repaired.

Good idea. Simply count how many times an RDB packet successfully
repaired loss? Note that this can be one or more lost packets. When
bundling N packets, the RDB packet can repair up to N losses in the
previous N packets that were sent.

Which list should this be added to? snmp4_tcp_list?

Any other counters that would be useful? Total number of RDB packets
transmitted?

> Ideally, if the path happens to be lossless, all these pro active
> bundles are overhead. Might be useful to make RDB conditional to
> tp->total_retrans or something.

Yes, that is a good point. We have discussed this (for years really),
but have not had the opportunity to investigate it in-depth. Having
such a condition hard coded is not ideal, as it very much depends on
the use case if bundling from the beginning is desirable. In most
cases, this is probably a fair compromise, but preferably we would
have some logic/settings to control how the bundling rate can be
dynamically adjusted in response to certain events, defined by a set
of given metrics.

A conservative (default) setting would not do bundling until loss has
been registered, and could also check against some smoothed loss
indicator such that a certain amount of loss must have occurred within
a specific time frame to allow bundling. This could be useful in cases
where the network congestion varies greatly depending on such as the
time of day/night.

In a scenario where minimal application layer latency is very
important, but only sporadic (single) packet loss is expected to
regularly occur, always bundling one previous packet may be both
sufficient and desirable.

In the end, the best settings for an application/service depends on
the degree to which application layer latency (both minimal and
variations) affects the QoE.

There are many possibilities to consider in this regard, and I expect
we will not have this question fully explored any time soon. Most
importantly, we should ensure that such logic can easily be added
later on without breaking backwards compatibility.

Suggestions and comments on this are very welcome.


Bendik
