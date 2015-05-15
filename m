From: David Miller <davem@redhat.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Fri, 15 May 2015 12:37:26 -0400 (EDT)
Message-ID: <20150515.123726.1298734930500737780.davem@redhat.com>
References: <20150514032833.GF3853@gondor.apana.org.au>
	<55543D4F.8050306@gmail.com>
	<20150514062614.GA6320@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbbEOQhj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 12:37:39 -0400
In-Reply-To: <20150514062614.GA6320@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 May 2015 14:26:14 +0800

> On Wed, May 13, 2015 at 11:14:39PM -0700, Alexander Duyck wrote:
>> 
>> The fact is I am not all that familiar with the vti code and just
>> started crawling through it a few days ago, but it seems like it is
>> overwriting the skb->mark value with the i_key to determine which
>> policy to use.  The code prior to commit df3893c176e9 ("vti: Update
>> the ipv4 side to use it's own receive hook.") was saving the old
>> skb->mark, overwriting it, and then restoring it after a call to
>> xfrm4_policy_check.  After that commit it was letting
>> skb_scrub_packet in vti_rcv_cb clear the mark and it was just
>> dropped.
> 
> Steffen, why is vti touching skb->mark at all? This is supposed
> to be a field used by user-space to control a packet as it moves
> inside the kernel.  Seconding it for other purposes looks very
> wrong.

If anything, the skb_scrub_packet() call right above the skb->mark
clears should be taking care of this.

The only case where mark should be cleared is if we are changing
namespaces, and that's exactly the policy implemented by
skb_scrub_packet() currently.

Yeah, this mark handling via tunnel->parms.o_key looks not so good.
