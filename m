From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 09/10] macvtap: Re-enable UFO support
Date: Thu, 18 Dec 2014 10:15:42 -0500
Message-ID: <5492EF9E.2040607@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com> <1418840455-22598-10-git-send-email-vyasevic@redhat.com> <20141217224100.GC30969@redhat.com> <54923F67.3000205@redhat.com> <20141218075549.GB31702@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, ben@decadent.org.uk,
	stefanha@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaLRPPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 10:15:51 -0500
In-Reply-To: <20141218075549.GB31702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2014 02:55 AM, Michael S. Tsirkin wrote:
> On Wed, Dec 17, 2014 at 09:43:51PM -0500, Vlad Yasevich wrote:
>> On 12/17/2014 05:41 PM, Michael S. Tsirkin wrote:
>>> On Wed, Dec 17, 2014 at 01:20:54PM -0500, Vladislav Yasevich wrote:
>>>> Now that UFO is split into v4 and v6 parts, we can bring
>>>> back v4 support.  Continue to handle legacy applications
>>>> by selecting the ipv6 fagment id but do not change the
>>>> gso type.  This allows 2 legacy VMs to continue to communicate.
>>>>
>>>> Based on original work from Ben Hutchings.
>>>>
>>>> Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
>>>> CC: Ben Hutchings <ben@decadent.org.uk>
>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>> ---
>>>>  drivers/net/macvtap.c | 20 ++++++++++++++------
>>>>  1 file changed, 14 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>> index 880cc09..75febd4 100644
>>>> --- a/drivers/net/macvtap.c
>>>> +++ b/drivers/net/macvtap.c
>>>> @@ -66,7 +66,7 @@ static struct cdev macvtap_cdev;
>>>>  static const struct proto_ops macvtap_socket_ops;
>>>>  
>>>>  #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
>>>> -		      NETIF_F_TSO6)
>>>> +		      NETIF_F_TSO6 | NETIF_F_UFO)
>>>>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
>>>>  #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
>>>>  
>>>> @@ -570,11 +570,14 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
>>>>  			gso_type = SKB_GSO_TCPV6;
>>>>  			break;
>>>>  		case VIRTIO_NET_HDR_GSO_UDP:
>>>> -			pr_warn_once("macvtap: %s: using disabled UFO feature; please fix this program\n",
>>>> -				     current->comm);
>>>>  			gso_type = SKB_GSO_UDP;
>>>> -			if (skb->protocol == htons(ETH_P_IPV6))
>>>> +			if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
>>>> +				/* This is to support legacy appliacations.
>>>> +				 * Do not change the gso_type as legacy apps
>>>> +				 * may not know about the new type.
>>>> +				 */
>>>>  				ipv6_proxy_select_ident(skb);
>>>> +			}
>>>>  			break;
>>>>  		default:
>>>>  			return -EINVAL;
>>>> @@ -619,6 +622,8 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
>>>>  			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>>>>  		else if (sinfo->gso_type & SKB_GSO_TCPV6)
>>>>  			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
>>>> +		else if (sinfo->gso_type & SKB_GSO_UDP)
>>>> +			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
>>>>  		else
>>>>  			BUG();
>>>>  		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
>>>> @@ -955,6 +960,9 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>>>>  			if (arg & TUN_F_TSO6)
>>>>  				feature_mask |= NETIF_F_TSO6;
>>>>  		}
>>>> +
>>>> +		if (arg & TUN_F_UFO)
>>>> +			feature_mask |= NETIF_F_UFO;
>>>>  	}
>>>>  
>>>>  	/* tun/tap driver inverts the usage for TSO offloads, where
>>>> @@ -965,7 +973,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>>>>  	 * When user space turns off TSO, we turn off GSO/LRO so that
>>>>  	 * user-space will not receive TSO frames.
>>>>  	 */
>>>> -	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6))
>>>> +	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
>>>>  		features |= RX_OFFLOADS;
>>>>  	else
>>>>  		features &= ~RX_OFFLOADS;
>>>
>>> By the way this logic is completely broken, even without your patch,
>>> isn't it?
>>>
>>> It says: enable LRO+GRO if any of NETIF_F_TSO | NETIF_F_TSO6 |
>>> NETIF_F_UFO set.
>>>
>>> So what happens if I enable TSO only?
>>> LRO gets enabled so I can still get TSO6 packets.
>>>
>>>
>>> This really should be:
>>>
>>> 	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO) ==
>>> 			(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO)
>>>
>>>
>>> fixing this probably should be a separate patch before your
>>> series, and Cc stable.
>>
>> Actually, all this LRO/GRO feature manipulation on the macvtap device is
>> rather pointless as those features aren't really checked at any point
>> on the macvtap receive path.  GRO calls are done from napi context on
>> the lowest device, so by the time a packet hits macvtap, GRO/LRO has
>> already been done.
>>
>> So it doesn't really matter that we disable them incorrectly.  I
>> can send a separate patch to clean this up.
> 
> Hmm so if userspace says it can't handle TSO packets,
> it might get them anyway?

No.  It will get individual segments because in macvtap_handle_frame
we use user specified features to decide if segmentation needs
to be performed or not.

-vlad

> 
> 
>>>
>>>
>>>> @@ -1066,7 +1074,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>>>  	case TUNSETOFFLOAD:
>>>>  		/* let the user check for future flags */
>>>>  		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
>>>> -			    TUN_F_TSO_ECN))
>>>> +			    TUN_F_TSO_ECN | TUN_F_UFO))
>>>>  			return -EINVAL;
>>>>  
>>>>  		rtnl_lock();
>>>> -- 
>>>> 1.9.3
