From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 01/10] core: Split out UFO6 support
Date: Wed, 17 Dec 2014 15:43:50 -0500
Message-ID: <5491EB06.2060803@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>	
	<1418840455-22598-2-git-send-email-vyasevic@redhat.com>
	<1418847039.30883.29.camel@decadent.org.uk>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, stefanha@redhat.com,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>,
	Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1418847039.30883.29.camel@decadent.org.uk>
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

On 12/17/2014 03:10 PM, Ben Hutchings wrote:
> On Wed, 2014-12-17 at 13:20 -0500, Vladislav Yasevich wrote:
>> Split IPv6 support for UFO into its own feature similiar to TSO.
>> This will later allow us to re-enable UFO support for virtio-net
>> devices.
> [...]
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 6c8b6f6..8538b67 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -372,6 +372,7 @@ enum {
>>  
>>  	SKB_GSO_MPLS = 1 << 12,
>>  
>> +	SKB_GSO_UDP6 = 1 << 13
> 
> It seems like it would be cleaner to use the names SKB_GSO_UDPV{4,6},
> similarly to SKB_GSO_TCPV{4,6}.

I wanted to try to avoid touched ipv4 paths if I could.  I could use
GSO_UDPV6 though.

> 
>>  };
>>  
>>  #if BITS_PER_LONG > 32
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 945bbd0..fa4d2ee 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
> [...]
>> @@ -5952,24 +5958,21 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
> [...]
>> +	/* UFO also needs checksumming */
>> +	if ((features & NETIF_F_UFO) && !(features & NETIF_F_GEN_CSUM) &&
>> +					!(features & NETIF_F_IP_CSUM)) {
> 
> You can use !(features & NETIF_F_V4_CSUM) instead of the last two terms.
> 
>> +		netdev_dbg(dev,
>> +			   "Dropping NETIF_F_UFO since no checksum offload features.\n");
>> +		features &= ~NETIF_F_UFO;
>> +	}
>> +	if ((features & NETIF_F_UFO6) && !(features & NETIF_F_GEN_CSUM) &&
>> +					 !(features & NETIF_F_IPV6_CSUM)) {
> [...]
> 
> Similarly you can use !(features & NETIF_F_V6_CSUM) instead of the last
> two terms.

I made those to look the same as the TSO checks for consistency, but I can change
these to be shorter like above.

-vlad

> 
> Aside from those minor points, this looks fine.
> 
> Ben.
> 
