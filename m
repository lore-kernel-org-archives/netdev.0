From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH net] macvlan: Add support for 'always_on' offload features
Date: Mon, 03 Mar 2014 21:10:24 +0100
Message-ID: <5314E1B0.3030408@de.ibm.com>
References: <1393875252-17154-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:38095 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255AbaCCUKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:10:30 -0500
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
	Mon, 3 Mar 2014 20:10:28 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 93B352190046
	for <netdev@vger.kernel.org>; Mon,  3 Mar 2014 20:10:22 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s23KAEL165077318
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 20:10:14 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s23KAPZa021497
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 13:10:25 -0700
In-Reply-To: <1393875252-17154-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/14 20:34, Vlad Yasevich wrote:
> Macvlan currently inherits all of its features from the lower
> device.  When lower device disables offload support, this causes
> macvlan to disable offload support as well.  This causes
> performance regression when using macvlan/macvtap in bridge
> mode.
> 
> It can be easily demonstrated by creating 2 namespaces using
> macvlan in bridge mode and running netperf between them:
> 
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    20.00    1204.61
> 
> To restore the performance, we add software offload features
> to the list of "always_on" features for macvlan.  This way
> when a namespace or a guest using macvtap initially sends a
> packet, this packet will not be segmented at macvlan level.
> It will only be segmented when macvlan sends the packet
> to the lower device.
> 
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    20.00    5507.35
> 
> Fixes: 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 (macvtap: Add support of packet capture on macvtap device.)
> Fixes: 797f87f83b60685ff8a13fa0572d2f10393c50d3 (macvlan: fix netdev feature propagation from lower device)
> CC: Florian Westphal <fw@strlen.de>
> CC: Christian Borntraeger <borntraeger@de.ibm.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvlan.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index a5d2189..2625d2a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -506,6 +506,9 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
>  static struct lock_class_key macvlan_netdev_xmit_lock_key;
>  static struct lock_class_key macvlan_netdev_addr_lock_key;
> 
> +#define ALWAYS_ON_FEATURS \
             there is a  ^^ typo.

I fixed up the patch and the performance seems back to normal

Thanks

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>



> +	(NETIF_F_SG | NETIF_F_GEN_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX)
> +
>  #define MACVLAN_FEATURES \
>  	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
>  	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
> @@ -539,7 +542,7 @@ static int macvlan_init(struct net_device *dev)
>  	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
>  				  (lowerdev->state & MACVLAN_STATE_MASK);
>  	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
> -	dev->features		|= NETIF_F_LLTX;
> +	dev->features		|= ALWAYS_ON_FEATURES;
>  	dev->gso_max_size	= lowerdev->gso_max_size;
>  	dev->iflink		= lowerdev->ifindex;
>  	dev->hard_header_len	= lowerdev->hard_header_len;
> @@ -699,7 +702,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
>  	features = netdev_increment_features(vlan->lowerdev->features,
>  					     features,
>  					     mask);
> -	features |= NETIF_F_LLTX;
> +	features |= ALWAYS_ON_FEATURES;
> 
>  	return features;
>  }
> 
