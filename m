From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: xfrm transport mode policy and forward packets
Date: Thu, 22 Oct 2009 15:07:28 +0300
Message-ID: <4AE04B00.8090207@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:42966 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbZJVMOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 08:14:08 -0400
Received: by fxm18 with SMTP id 18so9103075fxm.37
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 05:14:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm using on my dmvpn environment security policies like:

src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 
	dir in priority 2147483648 ptype main 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport

src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 
	dir out priority 2147483648 ptype main 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport

To make sure the locally generated/received GRE traffic is IPsec protected.
Now when some other non-local gre traffic is being forwarded by this router,
that seems to match these SPs too. Basically no one behind this router box
can use GRE (or PPTP).

I originally had the 'fwd' policy too, but removing it did not help as-is.
I needed to add destination specific 'out' policies with higher priority.

Apparently, the forward path does two xfrm lookups: first one with from 'fwd'
policies to check if the received packet is not against policy, and a second
'out' lookup to see if it needs to get transformed.

My initial thought was if transport mode policies ought to be ignored, but
if the forwarded packet is NATted we might actually want to xfrm it in
transport mode.

There is 'ifindex' field in xfrm_selector, but that seems to be the output
interface. So it would not solve my problem: both local and forwarded gre
packets are output on the same interface.

I'm now slightly curious why 'in' was sort of split to 'in' and 'fwd', but
'out' was not split similarly, so we'd have more control over policies
depending if the traffic is local or forwarded?

My ideas so far have been:
a) rename 'fwd' to 'infwd' and split 'out' to 'out' and 'outfwd' ?
   (sounds kinda intrusive)
b) iptables target that would be able to disable xfrm

Any other ideas?
What would be the proper fix for this problem?

Thanks,
  Timo
