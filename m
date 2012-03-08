From: Nick Jones <nick.jones@network-box.com>
Subject: Re: [PATCH net-next] ipv6: perform inetpeer binding at dst creation,
 with readonly option
Date: Fri, 09 Mar 2012 00:10:29 +0800
Message-ID: <4F58D9F5.1080902@network-box.com>
References: <4F56320B.60400@network-box.com> <20120306.160528.1272258218296495399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from network-box.com ([175.45.17.220]:42463 "EHLO network-box.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757859Ab2CHQKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2012 11:10:35 -0500
In-Reply-To: <20120306.160528.1272258218296495399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2012 5:05 AM, David Miller wrote:
> From: Nick Jones <nick.jones@network-box.com>
> Date: Tue, 06 Mar 2012 23:49:31 +0800
> 
>> A neighbour advertises itself as obsolete and at a later time, the host
>> sends solicitations to the neighbours direct address.  The NS icmp6
>> packets have hoplimit explicitly set to 255.
>>
>> The neighbour re-advertises itself.  All subsequent packets sent to the
>> neighbour address will now have hoplimit stuck at 255 because the setup
>> of the NS packet wrote 255 to the cached metrics of the inetpeer that
>> the neighbour address' ip6_dst was bound to.  If the neighbour was a
>> router, a RA that attempts to update the hoplimit for the route will
>> have no effect because of the way ip6_dst_hoplimit works.
>>
>> This patch adds an rt6_init_metrics method that is called shortly after
>> a call to ip6_dst_alloc, it performs the inetpeer binding at that time.
>>
>> It allows the caller to indicate whether they want the new ip6_dst
>> metrics, and thus the inetpeer metrics, to be writable.  icmp6_dst_alloc
>> will now no longer permanently alter the peer metrics.
>>
>> Signed-off-by: Nick Jones <nick.jones@network-box.com>
> 
> So we essentially have two views of the same inetpeer.
> 
> I would say that the real fix for this is to just use kmalloc'd
> metrics for these special icmp6 dsts and leave the rest of the
> code alone.

Sure, I'm testing a patch that follows this suggestion and will submit it
soon.

However, seeing a kmalloc done for such a transient, sparse structure didn't
sit so well in the stomach.  If we can be sure that the metrics of a dst for
an icmp6 packet won't be written to, we could use the static const
ip6_template_metrics array defined in route.c:~205, it has RTAX_HOPLIMIT
fixed at 255, and using it avoids a kmalloc.

I'll produce another patch for this strategy if you think this is a better idea.
