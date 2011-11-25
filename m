From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Fri, 25 Nov 2011 11:18:37 +0800
Message-ID: <4ECF090D.1020503@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com>
	<OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com>
	<4ECE4004.8010107@redhat.com>
	<OF2886C7FB.135CFC23-ON65257953.000F9C8A-65257953.00101CBF@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF2886C7FB.135CFC23-ON65257953.000F9C8A-65257953.00101CBF@in.ibm.com>
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

On 11/25/2011 10:58 AM, Krishna Kumar2 wrote:
> jasowang<jasowang@redhat.com>  wrote on 11/24/2011 06:30:52 PM:
>
>>>> On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
>>>>> It was reported that the macvtap device selects a
>>>>> different vhost (when used with multiqueue feature)
>>>>> for incoming packets of a single connection. Use
>>>>> packet hash first. Patch tested on MQ virtio_net.
>>>> So this is sure to address the problem, why exactly does this happen?
>>>> Does your device spread a single flow across multiple RX queues? Would
>>>> not that cause trouble in the TCP layer?
>>>> It would seem that using the recorded queue should be faster with
>>>> less cache misses. Before we give up on that, I'd
>>>> like to understand why it's wrong. Do you know?
>>> I am using ixgbe. From what I briefly saw, ixgbe_alloc_rx_buffers
>>> calls skb_record_rx_queue when a skb is allocated. When a packet
>>> is received (ixgbe_alloc_rx_buffers), it sets rxhash. The
>>> recorded value is different for most skbs when I ran a single
>>> stream TCP stream test (does skbs move between the rx_rings?).
>> Yes, it moves. It depends on last processor or tx queue who transmits
>> the packets of this stream. Because ixgbe select tx queue based on the
>> processor id, so if vhost thread transmits skbs on different processors,
>> the skb of a single stream may comes from different rx ring.
> But I don't see transmit going on different queues,
> only incoming.
>
> - KK
>

Maybe I'm not clear enough, I mean the processor of host and tx queue of 
ixgbe.  So you would see, for a single vhost thread, as it moves among 
host cpus, it would use different tx queues of ixgbe. I think if you pin 
the vhost thread on host cpu, you may get consistent rx queue no.
