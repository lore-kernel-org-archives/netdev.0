From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: SACK scoreboard (Was: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]:
 Avoid breaking GSOed skbs when SACKed one-by-one)
Date: Sat, 15 Dec 2007 11:51:38 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
 <20071207.173201.95379610.davem@davemloft.net>
 <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
 <20071211.043239.224938181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lachlan.andrew@gmail.com, Netdev <netdev@vger.kernel.org>,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58418 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbXLOJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 04:51:41 -0500
In-Reply-To: <20071211.043239.224938181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007, David Miller wrote:

> Interesting approach, but I think there is limited value to this
> (arguably) complex form.
>
> The core issue is that the data and the SACK state are maintained in
> the same datastructure.  The complexity in all the state management
> and fixups in your patch is purely because of this.

Yeah, had just too much time while waiting for person who never
arrived... :-) It would have covered the typical case quite well
tough, for sure it was very intrusive.

> If we maintain SACK scoreboard information seperately, outside of
> the SKB, then there are only two changes to make:
> 
> 1) Every access to TCP_SKB_CB() SACK scoreboard is adjusted to
>    new data structure.

Not sure if it is going to all that straightforward because you seem to 
ignore in this simple description all details of performing the linking 
between the structures, which becomes tricky when we add those
retransmission adjustments.

> 2) Retransmit is adjusted so that it can retransmit an SKB
>    constructed as a portion of an existing SKB.  Since TSO
>    implies SG, this can be handled with simple offset and
>    length arguments and suitable creation of a clone referencing
>    the pages in the SG vector that contain the desired data.

...I.e., how to count retrans_out origins in such case because the 
presented sack_ref knows nothing about them nor do we have anything but 
one bit in ->sacked per skb. We need the origins when retransmission get 
sacked/acked to reduce retrans_out correctly. To solve this, I think the 
sack_ref must have ->sacked as well and the structure should store the 
R-bits there as well, and may L-bits too though their defination is 
more obvious because it's mostly a complement of sacked (except for small 
part near fackets_out and timedout marking that probably makes bookkeeping 
of L still necessary).

The pcount boundaries are no longer that well defined after we break skb 
boundaries during retransmitting, so doing this makes fackets_out 
calculation even more trickier to track, unless whole pcount is replaced 
by byte based fackets_out :-/, which is very trivial to determine from 
seqnos only (TCP_NODELAYers might get unhappy though if we do that in a 
straightforward way...). 

This would clearly be a good step from one perspective. Nowadays GSO'ed 
skbs may get fragmented when mss_now changes, for two or more consecutive 
non-SACKed skbs that means one or more extra (small) packets when 
retransmitting.

> I would envision this SACK state thing to reference into the
> retransmit queue SKB's somehow.  Each SACK block could perhaps
> look something like:
> 
> 	struct sack_ref {
> 		struct sk_buff *start_skb;
> 		struct sk_buff *end_skb;
> 		unsigned int start_off;
> 		unsigned int len;
> 	};

...I assume that these are fast searchable? And skbs as well (because the 
linking of start/end_skb at minimum is a costly operation otherwise)?


-- 
 i.
