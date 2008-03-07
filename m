From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Fri, 07 Mar 2008 15:32:09 +0900
Message-ID: <47D0E169.5050006@miyazawa.org>
References: <20080305213727.35f46f2f.kazunori@miyazawa.org> <20080305.134020.05696990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:49603 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751319AbYCGGcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 01:32:20 -0500
In-Reply-To: <20080305.134020.05696990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for reviewing the patch,

David Miller wrote:
> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Wed, 5 Mar 2008 21:37:27 +0900
> 
>> Hello David,
> 
> Hello,
> 
>> This patch fix inter address family ipsec tunneling
>> when we install IPsec SA via PF_KEY interface
>> because there are no interface to set the selector.
>>
>> This patch is for net-2.6
>>
>> Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> It seems quite excessive to grab and release the module reference
> count during every packet input/output which happens through IPSEC
> tunnels.
> 
> The whole reason we store the mode information in the state is so that
> we only have to grab the reference during IPSEC rule addition, instead
> of during packet processing.
> 
> Having to export xfrm_mode_{get,put} from xfrm_state.c is a sure
> sign of trouble :-)
> 

At the beginning I tried to implement inter address tunnel mode module.
However it was complicated and I gave up it because I could not send
the patches before next release.

Should we give up configure a tunnel mode xfrm_state which has no
selector? If so, we may need to extend PF_KEYv2 interface to set
the selector.

> Is there some way we can simply propagate the correct setting to
> x->inner_mode?
> 

Now I have no idea :-<

> I also wonder if the PF_KEY limitation really exists.  For example we
> will set x->sel.family etc. from the SADB_EXT_ADDRESS_PROXY attribute
> if present.
> 

Yes, we have SADB_EXT_ADDRESS_PROXY. But it is not enough, I think.
xfrm_selector has both src and dst so that we need some way to
specify the address is src or dst.

from RFC2367

    The SRC and DST addresses for a security association MUST be in the
    same protocol family and MUST always be present or absent together in
    a message.  The PROXY address MAY be in a different protocol family,
    and for most security protocols, represents an actual originator of a
    packet.  (For example, the inner-packets's source address in a
    tunnel.)

    The SRC address MUST be a unicast or unspecified (e.g., INADDR_ANY)
    address.  The DST address can be any valid destination address
    (unicast, multicast, or even broadcast). The PROXY address SHOULD be
    a unicast address (there are experimental security protocols where
    PROXY semantics may be different than described above).


> Finally, if the determination can be made in the data path, it
> by definition could be made during rule insertion which is much
> more efficient and appropriate.

I agree with you.

Anyway I'm considering another way.

Thank you,

--
Kazunori Miyazawa

