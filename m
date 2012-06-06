From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Wed, 6 Jun 2012 15:41:11 -0700
Message-ID: <CAK6E8=eN6DZuxszBbPeR7qLq1S7HSR9oa0f69+XpJXxzKgPVtw@mail.gmail.com>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <CAFbMe2Mu46N8kRrYkGzYRLuntEd2J9aO_d0Jw_y0gsQA4q-qHw@mail.gmail.com>
 <CAPshTCiFDUb3CVm-joJW_DRVS+C+_BjFO-Mt3uAwrCzVw8MsVg@mail.gmail.com>
 <1338832247.5299.4.camel@nexus> <CAPshTChwnEaMTOsofFDP0ZY8U3VCP2ZrtXjdhKG03rRsx7kryA@mail.gmail.com>
 <CAPshTCg8W0QxubvO_dWBsSOqvCEdBSWLKv3cNOvn=VbyqHA1zg@mail.gmail.com>
 <1338921588.17263.6.camel@nexus> <CAPshTCjEkyLg+BdYvA3vW4C92rAyfuC_mVEDgrbRz4NDyGh9Ug@mail.gmail.com>
 <1339014958.4294.2.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50757 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2FFWld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 18:41:33 -0400
Received: by yenm10 with SMTP id m10so5493222yen.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 15:41:32 -0700 (PDT)
In-Reply-To: <1339014958.4294.2.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 6, 2012 at 1:35 PM, Damian Lukowski
<damian@tvk.rwth-aachen.de> wrote:
> Hi,
>
> backoffs are reverted when an RTO retransmission triggers an ICMP
> destination unreachable along the path towards the target.
> Consider A --- R --- B, where A and B are TCP endpoints, and R is some
> router in between. When the link between R and B breaks for a longer
> time, A will perform RTO retransmissions if there are outstanding ACKs.
> Those packets which arrive at R will hopefully trigger an ICMP response
> back towards A, as R has no more route towards B. The ICMP packet is an
> indication for A, that the retransmission has not been lost because of
> congestion but because of a link outage, and the backoff will be
> reverted for the corresponding TCP session. In the best case, every RTO
> retransmission triggers an ICMP response, so every backoff is reverted,
> and the time between retransmissions remains at the original value.
> If icsk_retransmits is decremented at this point within the original
> code's logic, the connection might never time out. And we cannot take
> tcp_retriesX literally here, as the above scenario would time out after
> tcp_retries2 x base_rto, where the base_rto might be as small as 0.2
> seconds.
so wouldn't upping the threshold counter a (much) simpler solution?

IMO, this is a valid concern and listed in the TODOs of the expired LCD draft.
But it creates a new rule that's not compatible with others in the stack: an RTO
backoff can be reverted but TCP should still timeout based on exp.
backoff rule. But
we can also do linear RTOs and use counter-based checks. End result:
unpredictable
and unclear timeout behavior.

I second Jerry's idea to revert back to simple counter checks.

>
> I am not sure, how an additional counter variable should help. You still
> cannot take tcp_retriesX literally. Besides, I think that changing the
> socket structure is too heavy machinery, isn't it?
