From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: Looking for a lost patch
Date: Tue, 19 May 2015 11:32:15 -0700
Message-ID: <555B81AF.5050401@redhat.com>
References: <55538E1F.2020505@gmail.com> <20150518073809.GD8928@secunet.com> <555A0D0E.5040102@redhat.com> <20150519075724.GI8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbbESScX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 14:32:23 -0400
In-Reply-To: <20150519075724.GI8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 12:57 AM, Steffen Klassert wrote:
> On Mon, May 18, 2015 at 09:02:22AM -0700, Alexander Duyck wrote:
>> On 05/18/2015 12:38 AM, Steffen Klassert wrote:
>>> On Wed, May 13, 2015 at 10:47:11AM -0700, Alexander Duyck wrote:
>>>> So I am in the process of trying to do some work on VTI6 and in the
>>>> process of doing so I am trying to setup an IPv4 VTI tunnel and I
>>>> have come across what appears to be a lost patch.
>>>>
>>>> So in commit a32452366b72 ("vti4: Don't count header length twice.")
>>>> the following change was made:
>>>>
>>>> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
>>>> index 687ddef..cd62596 100644
>>>> --- a/net/ipv4/ip_vti.c
>>>> +++ b/net/ipv4/ip_vti.c
>>>> @@ -349,7 +349,6 @@ static int vti_tunnel_init(struct net_device *dev)
>>>>   	memcpy(dev->broadcast, &iph->daddr, 4);
>>>>
>>>>   	dev->type		= ARPHRD_TUNNEL;
>>>> -	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
>>>>   	dev->mtu		= ETH_DATA_LEN;
>>>>   	dev->flags		= IFF_NOARP;
>>>>   	dev->iflink		= 0;
>>>>
>>>> However in commit f895f0cfbb77 ("Merge branch 'master' of
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec") the
>>>> change appears to have been undone as a result of a merge commit.
>>>>
>>>> I'm just wondering which is correct.  Should the hard_header_len be
>>>> set or unset in vti_tunnel_init?  I ask because I have two kernels
>>>> and one has the patch and one does not and I am seeing an MTU of
>>>> 1332 for a VTI tunnel without, and 1480 for a VTI tunnel with.
>>> A MTU of 1332 is definitively wrong. Actually I think a vti
>>> tunnel can have a MTU of 1500 because xfrm cares to calculate
>>> a PMTU based on the used states. The MTU of 1480 is because
>>> the generic ip_tunnel_bind_dev() assumes that an ip tunnel
>>> has always the overhead of an additional ip header. On IPsec
>>> this header is included in the PMTU calculation.
>> So if I understand correctly then is 1480 the correct MTU or should
>> I be looking for some other value?
> The MTU should be 1500. All the IPsec overhead is handled by PMTU
> discovery, just like in the case we use IPsec without vti tunnels.
> The IPv6 side of vti does it like that.

The problem is the PMTU isn't communicated to things that make use of 
the tunnel.  For example if I do a "ping -s 2000 x.x.x.x" across an IPv6 
VTI interface it will fail currently as it assumes the MTU is 1500 and 
so it is fragmenting the ping packet at sizes that won't be communicated 
across the underlying interface.

>> My initial though was to try and find the maximum overhead that can
>> be generated for an IPv4/IPSec tunnel.  However it seems like there
>> isn't any solid documentation anywhere on what the upper limit is.
> There is no fixed upper limit on the overhead. The overhead also depends
> on the used crypto algorithm (IV size, chiper block size, ICV size etc.).
> That's why we handle this whith PMTU discovery. With this, each path
> can have it's own MTU based on the configured xfrm_state.

My concern with all of this is that I plan to resubmit your original 
patch as the 1332 is a far smaller MTU than the tunnel actually needs, 
however I suspect we will then start receiving bugzilla's about the 
fragmentation being screwed up for things like UDP over the tunnel since 
the packets will be fragmented before they are handed off to the VTI, 
not after.  That is why I was thinking it might be safer to determine 
what the maximum overhead could be for an IPSec tunnel and then I would 
use that to determine the MTU.  I realize the value would be 
conservative, however I suspect it would still be a larger MTU than the 
interface is working with now.

As an example most of the Cisco descriptions for this end up suggesting 
an MTU of 1400 for the tunnels since that provides more than enough 
overhead for most tunnel combinations.  What I would like to try and 
find is a similar value that would be a good fit for almost all 
configuration to avoid any fragmentation issues on the tunnel.

- Alex
