From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 01/10] core: Split out UFO6 support
Date: Fri, 19 Dec 2014 14:55:33 -0500
Message-ID: <549482B5.5050501@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<1418840455-22598-2-git-send-email-vyasevic@redhat.com>
	<20141217224553.GE30969@redhat.com> <54921266.30300@redhat.com>
	<20141218075409.GA31702@redhat.com> <5492EC4F.5080303@redhat.com>
	<20141218173546.GB5425@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	ben@decadent.org.uk, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141218173546.GB5425@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 12/18/2014 12:35 PM, Michael S. Tsirkin wrote:
> On Thu, Dec 18, 2014 at 10:01:35AM -0500, Vlad Yasevich wrote:
>> On 12/18/2014 02:54 AM, Michael S. Tsirkin wrote:
>>> Cc Dave, pls remember to do this next time otherwise
>>> your patches won't get merged :)
>>>
>>> On Wed, Dec 17, 2014 at 06:31:50PM -0500, Vlad Yasevich wrote:
>>>> On 12/17/2014 05:45 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Dec 17, 2014 at 01:20:46PM -0500, Vladislav Yasevich wrote:
>>>>>> Split IPv6 support for UFO into its own feature similiar to TSO.
>>>>>> This will later allow us to re-enable UFO support for virtio-net
>>>>>> devices.
>>>>>>
>>>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>>>> ---
>>>>>>  include/linux/netdev_features.h |  7 +++++--
>>>>>>  include/linux/netdevice.h       |  1 +
>>>>>>  include/linux/skbuff.h          |  1 +
>>>>>>  net/core/dev.c                  | 35 +++++++++++++++++++----------------
>>>>>>  net/core/ethtool.c              |  2 +-
>>>>>>  5 files changed, 27 insertions(+), 19 deletions(-)
>>>>>>
>>>>>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>>>>>> index dcfdecb..a078945 100644
>>>>>> --- a/include/linux/netdev_features.h
>>>>>> +++ b/include/linux/netdev_features.h
>>>>>> @@ -48,8 +48,9 @@ enum {
>>>>>>  	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
>>>>>>  	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
>>>>>>  	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
>>>>>> +	NETIF_F_UFO6_BIT,		/* ... UDPv6 fragmentation */
>>>>>>  	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
>>>>>> -		NETIF_F_GSO_MPLS_BIT,
>>>>>> +		NETIF_F_UFO6_BIT,
>>>>>>  
>>>>>>  	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
>>>>>>  	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
>>>>>> @@ -109,6 +110,7 @@ enum {
>>>>>>  #define NETIF_F_TSO_ECN		__NETIF_F(TSO_ECN)
>>>>>>  #define NETIF_F_TSO		__NETIF_F(TSO)
>>>>>>  #define NETIF_F_UFO		__NETIF_F(UFO)
>>>>>> +#define NETIF_F_UFO6		__NETIF_F(UFO6)
>>>>>>  #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
>>>>>>  #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
>>>>>>  #define NETIF_F_RXALL		__NETIF_F(RXALL)
>>>>>> @@ -141,7 +143,7 @@ enum {
>>>>>>  
>>>>>>  /* List of features with software fallbacks. */
>>>>>>  #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
>>>>>> -				 NETIF_F_TSO6 | NETIF_F_UFO)
>>>>>> +				 NETIF_F_TSO6 | NETIF_F_UFO | NETIF_F_UFO6)
>>>>>>  
>>>>>>  #define NETIF_F_GEN_CSUM	NETIF_F_HW_CSUM
>>>>>>  #define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
>>>>>> @@ -149,6 +151,7 @@ enum {
>>>>>>  #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
>>>>>>  
>>>>>>  #define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
>>>>>> +#define NETIF_F_ALL_UFO		(NETIF_F_UFO | NETIF_F_UFO6)
>>>>>>  
>>>>>>  #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
>>>>>>  				 NETIF_F_FSO)
>>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>>> index 74fd5d3..86af10a 100644
>>>>>> --- a/include/linux/netdevice.h
>>>>>> +++ b/include/linux/netdevice.h
>>>>>> @@ -3559,6 +3559,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
>>>>>>  	/* check flags correspondence */
>>>>>>  	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
>>>>>>  	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
>>>>>> +	BUILD_BUG_ON(SKB_GSO_UDP6    != (NETIF_F_UFO6 >> NETIF_F_GSO_SHIFT));
>>>>>>  	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
>>>>>>  	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
>>>>>>  	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
>>>>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>>>>> index 6c8b6f6..8538b67 100644
>>>>>> --- a/include/linux/skbuff.h
>>>>>> +++ b/include/linux/skbuff.h
>>>>>> @@ -372,6 +372,7 @@ enum {
>>>>>>  
>>>>>>  	SKB_GSO_MPLS = 1 << 12,
>>>>>>  
>>>>>> +	SKB_GSO_UDP6 = 1 << 13
>>>>>>  };
>>>>>>  
>>>>>>  #if BITS_PER_LONG > 32
>>>>>
>>>>> So this implies anything getting GSO packets e.g.
>>>>> from userspace now needs to check IP version to
>>>>> set GSO type correctly.
>>>>>
>>>>> I think you missed some places that do this, e.g. af_packet
>>>>> sockets.
>>>>>
>>>>
>>>> I looked at af_packet sockets and they set this only in the event
>>>> vnet header has been used with a GSO type.  In this case, the user
>>>> already knows the the type.
>>>
>>> Imagine you are receiving a packet:
>>>
>>>                 if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
>>>                         switch (vnet_hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
>>>                         case VIRTIO_NET_HDR_GSO_TCPV4:
>>>                                 gso_type = SKB_GSO_TCPV4;
>>>                                 break;
>>>                         case VIRTIO_NET_HDR_GSO_TCPV6:
>>>                                 gso_type = SKB_GSO_TCPV6;
>>>                                 break;
>>>                         case VIRTIO_NET_HDR_GSO_UDP:
>>>                                 gso_type = SKB_GSO_UDP;
>>>                                 break;
>>>                         default:
>>>                                 goto out_unlock;
>>>                         }
>>>
>>>                         if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
>>>                                 gso_type |= SKB_GSO_TCP_ECN;
>>>
>>>                         if (vnet_hdr.gso_size == 0)
>>>                                 goto out_unlock;
>>>
>>>                 }
>>>
>>> we used to report UFO6 as SKB_GSO_UDP, we probably
>>> should keep doing this, with your patch we select the
>>> goto out_unlock path.
>>>
>>>
>>
>> No.  The vnet_hdr.gso_type is still going to be VIRTIO_NET_HDR_GSO_UDP
>> since the UDP6 version isn't defined yet.  So, it will be marked as
>> GSO_UDP.
> 
> I pasted the wrong snippet.
> I meant this:
> 
>                         /* This is a hint as to how much should be * linear. */
>                         vnet_hdr.hdr_len = __cpu_to_virtio16(false, skb_headlen(skb));
>                         vnet_hdr.gso_size = __cpu_to_virtio16(false, sinfo->gso_size);
>                         if (sinfo->gso_type & SKB_GSO_TCPV4)
>                                 vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>                         else if (sinfo->gso_type & SKB_GSO_TCPV6)
>                                 vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
>                         else if (sinfo->gso_type & SKB_GSO_UDP)
>                                 vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>                         else if (sinfo->gso_type & SKB_GSO_FCOE)
>                                 goto out_free;
>                         else
>                                 BUG();
> 
> so if we get SKB_GSO_UDP we'll get BUG().
> 
> 
> 
>> This code most likely needs the same workaround as exists in tap and macvtap,
>> i.e select the proxy fragment id and decide what to do with gso_type.
> 
> And fixup type to GSO_UDP6 while we are at it.
> 
>>>
>>>> It is true that with this series af_packets now can't do IPv6 UFO
>>>> since there is no VIRTIO_NET_HDR_GSO_UDPV6 yet.
>>>
>>> What do you mean by "do".
>>
>> What I mean is that AF_PACKET sockets currently do not do IPv6 UFO
>> correctly, even after Ben's fixes to tap/macvtap.  There is no
>> proxy fragment id selection in af_packet case and we have the
>> same problem Ben was trying address for tap/macvtap.
>>> Are we talking about sending or receiving packets?
>>
>> I am talking about sending, see above.
>>
>>> You seem to conflate the two.
>>>
>>> We always discarded ID on RX.
>>>
>>> For tun, this is xmit, so just by saying "this device can
>>> not do UFO" you will never get short packets.
>>>
>>
>> You must mean long packets.
> 
> Yes.
> 
>> This is actually an issue I've been thinking
>> about. With with your suggestion of switching the GSO type for legacy
>> applications we end up with fragments for IPv6 traffic.   As a result,
>> legacy VMs will see a regression for large IPv6 datagrams.
> 
> I'm not sure what's meant by my suggestion here :)

What I am referring to here is to change the gso_type to UDPV6 in tap/macvtap
when passing packet to the host.

> It seems clear that legacy applications don't want to get IPv6
> fragment IDs in virtio header. Either we pass them plain ethernet
> packets or assume they are ok with discarding the IDs even
> if we set GSO_UDP.

So, I am not try to pass fragment IDs yet.  I am trying to make sure that
older gueest that assume that UFO == UFO4 + UFO6 continue to work and do not
regress.  At the same time, I want to enable UFO(4) for new guests.

If we set gso_type to SKB_GSO_UDPV6 before passing the data to the forwarding
path of the host, then this will cause IPv6 fragmentation.  If we leave gso_type
as SKB_GSO_UDP, then older VMs will continue to communicate using large UDP
data packets.

Later when VMs support UFO6, when UFO6 is enabled, the fragment id can be communicated.
But that's later.

> 
>>>
>>>>
>>>> I suppose we could do something similar there as we do in tun code/macvtap code.
>>>> If that's the case, it currently broken as well.
>>>>
>>>> -vlad
>>>
>>>
>>> Broken is a big word.
>>>
>>> Let's stop conflating two directions.
>>
>> I am not and was talking only about af_packet as that is what you asked about.
>> There is no tun/macvtap in play here.  They are handled separately in their
>> respective drivers.
>>
>>>
>>> Here's the way I look at it:
>>>
>>> 1. Userspace doesn't have a way to get fragment IDs
>>> from tun/macvtap/packet sockets.
>>> Presumably, not all users need these IDs.
>>> E.g. old guests clearly don't.
>>>
>>> We should either give them packets stripping the ID,
>>> like we always did, or make sure they never get these packets.
>>> Second option seems achievable for tun if we
>>> never tell linux it can do UFO, but I don't see
>>> how to do it for macvtap and packet socket.
>>>
>>
>> macvtap is slightly problematic, but doable with some tricks.
>> packet socket is an interesting problem.  The only way
>> an af_packet socket can receive an skb marked SKB_GSO_UDPV6
>> is if someone else on the host sent it (like another guest).
> 
> Or if a NIC set it.

OK, virtio seems to be the only nic doing this... You are right, I
need to cover that scenario.

-vlad

> 
>> Since there is are no feature or vnet header length negotiations,
>> it is impossible to tell if an application using this af_packet
>> socket is capable of processing VIRTIO_NET_HDR_GSO_UDPV6
>> type (yet to be defined).
>>
>> So, we can either use existing VIRTIO_NET_HDR_GSO_UDP on receive
>> path, add some kind of negotiation logic to packet socket (like
>> storing the application expected vnet header size), or perform
>> IPv6 fragmentation somehow.
>>
>> Options 1 or 2 are doable.
> 
> 1 is using VIRTIO_NET_HDR_GSO_UDP and discarding ID,
> 2 is "some kind of negotiation logic"?
> 2 can't be enough, you will need 1 as well.
> 
> So let's start with 1 as a first step.
> 
> 
> 
> 
>>>
>>> 2. Userspace doesn't have a way to set fragment IDs
>>> for tun/macvtap/packet sockets.
>>> Presumably, not all users have these IDs.  E.g. old
>>> guests clearly don't.
>>>
>>> We should either generate our own ID,
>>> like we always did, or make sure we don't accept
>>> these packets.
>>> Second option is almost sure to break userspace,
>>> so it seems we must do the first one.
>>>
>>
>> Right.  This was missing from packet sockets.  I can fix it.
>>
>> -vlad
> 
> Also, this can't be a patch on top, since we don't
> want bisect to give us configurations which
> can BUG().
> 
> 
>>>
>>> 3.
>>> Exactly the same two things if you replace userspace
>>> with hypervisor and tun/macvtap/packet socket with
>>> virtio device.
>>>
>>>
>>> 4. 
>>> As a next step, we should add a way for userspace
>>> to tell us that it has ids and can handle them.
>>>
>>>
>>>
>>>
>>>
>>>>>
>>>>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>>>>> index 945bbd0..fa4d2ee 100644
>>>>>> --- a/net/core/dev.c
>>>>>> +++ b/net/core/dev.c
>>>>>> @@ -5929,6 +5929,12 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
>>>>>>  		features &= ~NETIF_F_ALL_TSO;
>>>>>>  	}
>>>>>>  
>>>>>> +	/* UFO requires that SG is present as well */
>>>>>> +	if ((features & NETIF_F_ALL_UFO) && !(features & NETIF_F_SG)) {
>>>>>> +		netdev_dbg(dev, "Dropping UFO features since no SG feature.\n");
>>>>>> +		features &= ~NETIF_F_ALL_UFO;
>>>>>> +	}
>>>>>> +
>>>>>>  	if ((features & NETIF_F_TSO) && !(features & NETIF_F_HW_CSUM) &&
>>>>>>  					!(features & NETIF_F_IP_CSUM)) {
>>>>>>  		netdev_dbg(dev, "Dropping TSO features since no CSUM feature.\n");
>>>>>> @@ -5952,24 +5958,21 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
>>>>>>  		features &= ~NETIF_F_GSO;
>>>>>>  	}
>>>>>>  
>>>>>> -	/* UFO needs SG and checksumming */
>>>>>> -	if (features & NETIF_F_UFO) {
>>>>>> -		/* maybe split UFO into V4 and V6? */
>>>>>> -		if (!((features & NETIF_F_GEN_CSUM) ||
>>>>>> -		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
>>>>>> -			    == (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
>>>>>> -			netdev_dbg(dev,
>>>>>> -				"Dropping NETIF_F_UFO since no checksum offload features.\n");
>>>>>> -			features &= ~NETIF_F_UFO;
>>>>>> -		}
>>>>>> -
>>>>>> -		if (!(features & NETIF_F_SG)) {
>>>>>> -			netdev_dbg(dev,
>>>>>> -				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
>>>>>> -			features &= ~NETIF_F_UFO;
>>>>>> -		}
>>>>>> +	/* UFO also needs checksumming */
>>>>>> +	if ((features & NETIF_F_UFO) && !(features & NETIF_F_GEN_CSUM) &&
>>>>>> +					!(features & NETIF_F_IP_CSUM)) {
>>>>>> +		netdev_dbg(dev,
>>>>>> +			   "Dropping NETIF_F_UFO since no checksum offload features.\n");
>>>>>> +		features &= ~NETIF_F_UFO;
>>>>>> +	}
>>>>>> +	if ((features & NETIF_F_UFO6) && !(features & NETIF_F_GEN_CSUM) &&
>>>>>> +					 !(features & NETIF_F_IPV6_CSUM)) {
>>>>>> +		netdev_dbg(dev,
>>>>>> +			   "Dropping NETIF_F_UFO6 since no checksum offload features.\n");
>>>>>> +		features &= ~NETIF_F_UFO6;
>>>>>>  	}
>>>>>>  
>>>>>> +
>>>>>>  #ifdef CONFIG_NET_RX_BUSY_POLL
>>>>>>  	if (dev->netdev_ops->ndo_busy_poll)
>>>>>>  		features |= NETIF_F_BUSY_POLL;
>>>>>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>>>>>> index 06dfb29..93eff41 100644
>>>>>> --- a/net/core/ethtool.c
>>>>>> +++ b/net/core/ethtool.c
>>>>>> @@ -223,7 +223,7 @@ static netdev_features_t ethtool_get_feature_mask(u32 eth_cmd)
>>>>>>  		return NETIF_F_ALL_TSO;
>>>>>>  	case ETHTOOL_GUFO:
>>>>>>  	case ETHTOOL_SUFO:
>>>>>> -		return NETIF_F_UFO;
>>>>>> +		return NETIF_F_ALL_UFO;
>>>>>>  	case ETHTOOL_GGSO:
>>>>>>  	case ETHTOOL_SGSO:
>>>>>>  		return NETIF_F_GSO;
>>>>>> -- 
>>>>>> 1.9.3
