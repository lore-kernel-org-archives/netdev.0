From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting skb->dev
 in receive path
Date: Fri, 15 May 2015 12:14:43 -0700
Message-ID: <555645A3.6010509@gmail.com>
References: <20150514032833.GF3853@gondor.apana.org.au>	<55543D4F.8050306@gmail.com>	<20150514062614.GA6320@gondor.apana.org.au> <20150515.123726.1298734930500737780.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, tgraf@suug.ch
To: David Miller <davem@redhat.com>, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34241 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbbEOTOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 15:14:45 -0400
Received: by obfe9 with SMTP id e9so85079267obf.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 12:14:45 -0700 (PDT)
In-Reply-To: <20150515.123726.1298734930500737780.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 09:37 AM, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 14 May 2015 14:26:14 +0800
>
>> On Wed, May 13, 2015 at 11:14:39PM -0700, Alexander Duyck wrote:
>>> The fact is I am not all that familiar with the vti code and just
>>> started crawling through it a few days ago, but it seems like it is
>>> overwriting the skb->mark value with the i_key to determine which
>>> policy to use.  The code prior to commit df3893c176e9 ("vti: Update
>>> the ipv4 side to use it's own receive hook.") was saving the old
>>> skb->mark, overwriting it, and then restoring it after a call to
>>> xfrm4_policy_check.  After that commit it was letting
>>> skb_scrub_packet in vti_rcv_cb clear the mark and it was just
>>> dropped.
>> Steffen, why is vti touching skb->mark at all? This is supposed
>> to be a field used by user-space to control a packet as it moves
>> inside the kernel.  Seconding it for other purposes looks very
>> wrong.
> If anything, the skb_scrub_packet() call right above the skb->mark
> clears should be taking care of this.

That only applies if you are crossing namespaces which we are not in 
this case.

> The only case where mark should be cleared is if we are changing
> namespaces, and that's exactly the policy implemented by
> skb_scrub_packet() currently.

Right.  The problem is it looks like vti and vti6 are using the mark to 
signal to the policy that is meant to be used for either end of the 
tunnel.  From what I can tell at some point there was a pre-routing hook 
that was used but later it was replaced with the i_key for input, and 
o_key for output.

> Yeah, this mark handling via tunnel->parms.o_key looks not so good.

So is there any recommendations for an alternative to make it so that 
the ipsec endpoint is identified as needing to be encrypted or 
decrypted?  If needed I could probably take a day or two to try and 
address it as I still have a few other minor things I want to try and 
fix such as the MTU configuration for vti/vti6.

- Alex
