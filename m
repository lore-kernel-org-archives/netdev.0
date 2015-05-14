From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting skb->dev
 in receive path
Date: Wed, 13 May 2015 23:14:39 -0700
Message-ID: <55543D4F.8050306@gmail.com>
References: <20150514020316.1635.50870.stgit@ahduyck-vm-fedora22> <20150514032833.GF3853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	tgraf@suug.ch, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33936 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbbENGOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 02:14:41 -0400
Received: by pacyx8 with SMTP id yx8so74199882pac.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 23:14:40 -0700 (PDT)
In-Reply-To: <20150514032833.GF3853@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 08:28 PM, Herbert Xu wrote:
> On Wed, May 13, 2015 at 07:04:28PM -0700, Alexander Duyck wrote:
>> This change makes it so that we clear the skb->mark field when we pass
>> through the receive path of the IPv4 or IPv6 virtual tunnel interface.  The
>> reason for clearing these fields is to resolve an apparent regression for
>> the behavior before skb_scrub_packet was modified.  Without this patch I
>> have to set disable_policy for the vti tunnel endpoint in order to be able
>> to receive traffic.
>>
>> Fixes: 213dd74aee76 ("skbuff: Do not scrub skb mark within the same name space")
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> This patch makes no sense.  Please explain your problem more
> clearly and tell us why the mark changes the way your packet
> is dealt with and why this isn't a policy decision that should
> be made in user-space.
>
> Cheers,

The problem is if I set up a ipsec tunnel with vti endpoints on the 
current net-next I am unable to ping the other side.  What it looks like 
is the packet makes it past the endpoint (I can see the ICMP request in 
tcpdump), but the stack appears to be dropping the frame due to a policy 
check.  With my patch applied this issue is resolved, same thing for if 
I revert the "Fixes" patch, or if I set disable_policy for the vti endpoint.

The fact is I am not all that familiar with the vti code and just 
started crawling through it a few days ago, but it seems like it is 
overwriting the skb->mark value with the i_key to determine which policy 
to use.  The code prior to commit df3893c176e9 ("vti: Update the ipv4 
side to use it's own receive hook.") was saving the old skb->mark, 
overwriting it, and then restoring it after a call to 
xfrm4_policy_check.  After that commit it was letting skb_scrub_packet 
in vti_rcv_cb clear the mark and it was just dropped.

I suppose if we are wanting to get back to the behavior before the 
receive hook change we could look at maybe storing the previous mark in 
the skb->cb assuming there is any room there for it, and then we could 
restore it in vti_rcv_cb.

- Alex
