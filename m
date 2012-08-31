From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH v2 1/2] 6lowpan: Make a copy of
	skb's delivered to 6lowpan
Date: Fri, 31 Aug 2012 09:56:19 -0400
Message-ID: <5040C283.7040809@signal11.us>
References: <1346294341-26808-1-git-send-email-alan@signal11.us>
	<1346294341-26808-2-git-send-email-alan@signal11.us>
	<1346396485.2586.307.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1346396485.2586.307.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/31/2012 03:01 AM, Eric Dumazet wrote:
> On Wed, 2012-08-29 at 22:39 -0400, Alan Ott wrote:
>> Since lowpan_process_data() modifies the skb (by calling skb_pull()), we
>> need our own copy so that it doesn't affect the data received by other
>> protcols (in this case, af_ieee802154).
>>
>> Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
>> ---
>>  net/ieee802154/6lowpan.c |    9 ++++++++-
>>  1 files changed, 8 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index 6a09522..ce33b02 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -1133,6 +1133,8 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
>>  static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
>>  	struct packet_type *pt, struct net_device *orig_dev)
>>  {
>> +	struct sk_buff *local_skb;
>> +
>>  	if (!netif_running(dev))
>>  		goto drop;
>>  
>> @@ -1144,7 +1146,12 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
>>  	case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
>>  	case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
>>  	case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
>> -		lowpan_process_data(skb);
>> +		local_skb = skb_copy(skb, GFP_ATOMIC);
>> +		if (!local_skb)
>> +			goto drop;
>> +		lowpan_process_data(local_skb);
>> +
>> +		kfree_skb(skb);
>>  		break;
>>  	default:
>>  		break;
> Its not clear to me why skb_copy() is needed here.
>
> >From patch description, I would say skb_clone() would be enough (and
> faster) ?

You're probably right. I'll check it out. Thanks.

Alan.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
