From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 08/10] tun: Re-uanble UFO support.
Date: Thu, 18 Dec 2014 10:12:30 -0500
Message-ID: <5492EEDE.5050000@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<1418840455-22598-9-git-send-email-vyasevic@redhat.com>
	<878417685.243182.1418881887975.JavaMail.zimbra@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, ben@decadent.org.uk,
	stefanha@redhat.com, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>, Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <878417685.243182.1418881887975.JavaMail.zimbra@redhat.com>
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

On 12/18/2014 12:51 AM, Jason Wang wrote:
> 
> 
> ----- Original Message -----
>> Now that UFO is split into v4 and v6 parts, we can bring
>> back v4 support without any trouble.
>>
>> Continue to handle legacy applications by selecting the
>> IPv6 fragment id but do not change the gso type.  Thist
>> makes sure that two legacy VMs may still communicate.
>>
>> Based on original work from Ben Hutchings.
>>
>> Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
>> CC: Ben Hutchings <ben@decadent.org.uk>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
>>  drivers/net/tun.c | 26 ++++++++++++++------------
>>  1 file changed, 14 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 9dd3746..8c32fca 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -175,7 +175,7 @@ struct tun_struct {
>>  	struct net_device	*dev;
>>  	netdev_features_t	set_features;
>>  #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
>> -			  NETIF_F_TSO6)
>> +			  NETIF_F_TSO6|NETIF_F_UFO)
>>  
>>  	int			vnet_hdr_sz;
>>  	int			sndbuf;
>> @@ -1152,20 +1152,15 @@ static ssize_t tun_get_user(struct tun_struct *tun,
>> struct tun_file *tfile,
>>  			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>>  			break;
>>  		case VIRTIO_NET_HDR_GSO_UDP:
>> -		{
>> -			static bool warned;
>> -
>> -			if (!warned) {
>> -				warned = true;
>> -				netdev_warn(tun->dev,
>> -					    "%s: using disabled UFO feature; please fix this program\n",
>> -					    current->comm);
>> -			}
>>  			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>> -			if (skb->protocol == htons(ETH_P_IPV6))
>> +			if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
> 
> This probably means UDPv6 with vlan does not work well, looks like another
> independent fixe and also for stable.

Ok.  I can split this out.

>> +				/* This allows legacy application to work.
>> +				 * Do not change the gso_type as it may
>> +				 * not be upderstood by legacy applications.
>> +				 */
> 
> Isn't this an issue that we use SKB_GSO_UDP for a UDPv6 packet? Especially
> consider we want to fix UFOv6 in the future? We probably can use
> SKB_GSO_UDP6 here and try to fix it in tun_put_user() if a legacy userspace
> is detected.

There is a slight problem with this.  This will force fragmentation of IPv6
traffic between VMs since UFO6 wouldn't be enabled on a destination device.
So, suddenly older VMs will see a performance regression for large UDPv6 traffic.

With this code, a legacy VM will continue to receive large UDPv6 traffic.
New VMs will have an updated virtio-net which will reset the gso type on input.

>>  				ipv6_proxy_select_ident(skb);
> 
> Question still for vlan, is network header correctly set here? Looks like
> ipv6_proxy_select_ident() depends on correct network header to work.
>> +	

Yes, you are right...  I wonder how that worked.  I'll re-test.

Thanks
-vlad
		}
>>  			break;
>> -		}
>>  		default:
>>  			tun->dev->stats.rx_frame_errors++;
>>  			kfree_skb(skb);
>> @@ -1273,6 +1268,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>>  			else if (sinfo->gso_type & SKB_GSO_TCPV6)
>>  				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
>> +			else if (sinfo->gso_type & SKB_GSO_UDP)
>> +				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>>  			else {
>>  				pr_err("unexpected GSO type: "
>>  				       "0x%x, gso_size %d, hdr_len %d\n",
>> @@ -1780,6 +1777,11 @@ static int set_offload(struct tun_struct *tun,
>> unsigned long arg)
>>  				features |= NETIF_F_TSO6;
>>  			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
>>  		}
>> +
>> +		if (arg & TUN_F_UFO) {
>> +			features |= NETIF_F_UFO;
>> +			arg &= ~TUN_F_UFO;
>> +		}
>>  	}
>>  
>>  	/* This gives the user a way to test for new features in future by
>> --
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
