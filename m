From: jasowang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Thu, 24 Nov 2011 21:00:52 +0800
Message-ID: <4ECE4004.8010107@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com>
	<OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com>
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

On 11/24/2011 07:14 PM, Krishna Kumar2 wrote:
> "Michael S. Tsirkin"<mst@redhat.com>  wrote on 11/24/2011 03:29:03 PM:
>
>> Subject Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
>>
>> On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
>>> It was reported that the macvtap device selects a
>>> different vhost (when used with multiqueue feature)
>>> for incoming packets of a single connection. Use
>>> packet hash first. Patch tested on MQ virtio_net.
>> So this is sure to address the problem, why exactly does this happen?
>> Does your device spread a single flow across multiple RX queues? Would
>> not that cause trouble in the TCP layer?
>> It would seem that using the recorded queue should be faster with
>> less cache misses. Before we give up on that, I'd
>> like to understand why it's wrong. Do you know?
> I am using ixgbe. From what I briefly saw, ixgbe_alloc_rx_buffers
> calls skb_record_rx_queue when a skb is allocated. When a packet
> is received (ixgbe_alloc_rx_buffers), it sets rxhash. The
> recorded value is different for most skbs when I ran a single
> stream TCP stream test (does skbs move between the rx_rings?).

Yes, it moves. It depends on last processor or tx queue who transmits 
the packets of this stream. Because ixgbe select tx queue based on the 
processor id, so if vhost thread transmits skbs on different processors, 
the skb of a single stream may comes from different rx ring.

> With this patch, macvtap selects the same device for each
> incoming packet. I can add some debugs in ixgbe to see what is
> happening also. I am not sure if Sasha was using a different
> device.
>
> Cc'ing Jeffrey in case he can add something.
>
> thanks,
>
> - KK
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
