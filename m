From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 09:08:11 -0700
Message-ID: <1363882091.4431.20.camel@edumazet-glaptop>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	 <20130321.114616.279859400813363663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	pshelar@nicira.com, hkchu@google.com, maze@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:32962 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934038Ab3CUQIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 12:08:16 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so2352069pbb.34
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 09:08:15 -0700 (PDT)
In-Reply-To: <20130321.114616.279859400813363663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-21 at 11:46 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Mar 2013 21:52:33 -0700
> 
> > GRE TSO support doesn't increment the ID in the inner IP header.
> 
> Is this a fundamental limitation of doing TSO over GRO or
> were the Broadcom folks just being lazy with their firmware
> implementation?
> 

Well, I suspect this hardware is not capable of doing the proper ID
manipulation twice. (inner and outer header)

Still TSO support permits a single GRE flow going from 3Gbps to 9Gbps on
our hosts. So even if the inner IP id is 'broken', we are going to use
TSO.

Note we are limited by the receiver, as the receiver has to perform the
tcp checksum in software (bnx2x doesnt support CHECKSUM_COMPLETE yet)

Hopefully next firmware or NIC will do the right thing.

> I really don't want to apply this patch, because ipv4 frames
> even with DF set should have an incrementing ID field, in
> order to accomodate various header compression schemes.
> 
> We go out of our way to do this for normal unencapsulated TCP stream
> packets, rather than set the ID field to zero (which we did for some
> time until the compression issue was pointed out to us).

I understand your concern, but this check in GRO brings nothing at all.

Once we receive frames with 'bad IPv4 ID', should we accept them or drop
them ?

TCP stack doesn't care at receive (obviously as this ID is not a concern
for the transport layer), so GRO should do the same, as GRO is a best
effort to reduce cpu load.

I fully understand the 'tos' check because of proper ECN support, but
the ttl check or id check are totally useless and time consuming.

GRO aggregation should roughly work the same than TCP coalescing, and we
don't care of IP ID or ttl in TCP stack.
