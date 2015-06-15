From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] Increase limit of macvtap queues
Date: Mon, 15 Jun 2015 16:07:03 +0800
Message-ID: <557E87A7.5010203@redhat.com>
References: <1434115828-9461-1-git-send-email-pagupta@redhat.com> <20150614103209-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, vyasevic@redhat.com,
	bhutchings@solarflare.com, therbert@google.com,
	viro@zeniv.linux.org.uk
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Pankaj Gupta <pagupta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753434AbbFOIHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 04:07:11 -0400
In-Reply-To: <20150614103209-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/14/2015 04:42 PM, Michael S. Tsirkin wrote:
> On Fri, Jun 12, 2015 at 07:00:28PM +0530, Pankaj Gupta wrote:
>> Macvtap should be compatible with tuntap for maximum number
>> of queues. '1059590254fa9dce9cafc4f07d1103dbec415e76' removes
>> the limitation and increases number of queues in tuntap.
>> Now, Its safe to increase number of queues in Macvtap as well.
>>
>> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> It's a good idea, but this might be a problem:
>
> static void macvtap_del_queues(struct net_device *dev)
> {
>         struct macvlan_dev *vlan = netdev_priv(dev);
>         struct macvtap_queue *q, *tmp, *qlist[MAX_MACVTAP_QUEUES];
>
> ...
> }
>
> by itself, this will use 2K on stack, which seems too much.
>
> You need to rework this function to use a linked list + list_move
> instead of an array + list_del_init.

Looks like even simpler, we can just do sock_put() inside
list_for_each_entry_safe() loop.

>> ---
>>  include/linux/if_macvlan.h |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
>> index 6f6929e..a4ccc31 100644
>> --- a/include/linux/if_macvlan.h
>> +++ b/include/linux/if_macvlan.h
>> @@ -29,7 +29,7 @@ struct macvtap_queue;
>>   * Maximum times a macvtap device can be opened. This can be used to
>>   * configure the number of receive queue, e.g. for multiqueue virtio.
>>   */
>> -#define MAX_MACVTAP_QUEUES     16
>> +#define MAX_MACVTAP_QUEUES     256
>>
>>  #define MACVLAN_MC_FILTER_BITS 8
>>  #define MACVLAN_MC_FILTER_SZ   (1 << MACVLAN_MC_FILTER_BITS)
>> --
>> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
