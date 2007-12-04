From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Mon, 3 Dec 2007 16:32:17 -0800
Message-ID: <20071203163217.27e4df3f@freepuppy.rosehill>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	<001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
	<20071128154725.29af2852@freepuppy.rosehill>
	<aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
	<474E0B33.2060108@linux-foundation.org>
	<001b01c83248$604f4120$20edc360$@edu>
	<20071203145207.40e4ac57@freepuppy.rosehill>
	<aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
	<002f01c83608$8a2fb600$9e8f2200$@edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Lachlan Andrew'" <lachlan.andrew@gmail.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	"'Herbert Xu'" <herbert@gondor.apana.org.au>,
	"'Douglas Leith'" <doug.leith@nuim.ie>,
	"'Robert Shorten'" <robert.shorten@nuim.ie>,
	<netdev@vger.kernel.org>
To: <shaoliu@Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58966 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbXLDAeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 19:34:25 -0500
In-Reply-To: <002f01c83608$8a2fb600$9e8f2200$@edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Dec 2007 15:59:23 -0800
"Shao Liu" <shaoliu@Princeton.EDU> wrote:

> Hi Stephen and Lachlan,
> 
> Thanks for the discussion. The gradual aging is surely an option. And
> another possibility is that, we compute the RTT just before congestion
> notification, which ideally, represent the full queueing delay + propagation
> delay. We can compute the average of the last M such values, and either use
> the average as maxRTT, or use it as a benchmark to judge whether a sample is
> outlier. How do you think of this idea?

The problem with an average like that would be storing enough values
to be useful and choosing how many to store. Perhaps some form of
weighted sliding average which favors recent values heavily would work
best. Remember that RTT's have a huge noise component and you are
fighting against the long tail distribution trying to see the queue
effects.

> 
> And also a question, why the samples when SACK is active are outliers?

Any sample with SACK is going to mean a loss or reordering has occurred.
So shouldn't the SACK values be useful, but RTT values from retransmits
are not useful.

> 
> For the accuracy of time stamping, I am not very familiar with the
> implementation details. But I can think of two ways, 1) do time stamp in as
> low layer as possible; 2) use as high priority thread to do it as possible.
> For 2), we can use separate threads to do time stamp and to process packets.

Right now the resolution is in microseconds using the hardware clock.
The clock usage costs a little bit, but makes the math more accurate.
It would be worth exploring sensitivity by taking out RTT_STAMP from
the flags field and varying HZ.
