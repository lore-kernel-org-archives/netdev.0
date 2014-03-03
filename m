From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: macvtap performance regression (bisected) between 3.13 and 3.14-rc1
Date: Mon, 03 Mar 2014 10:13:22 +0100
Message-ID: <531447B2.7040008@de.ibm.com>
References: <530FA586.3010400@de.ibm.com> <53110A62.7070109@redhat.com> <5311C142.6040509@de.ibm.com> <53123495.7030902@gmail.com> <531287AE.5080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	KVM list <kvm@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>, vyasevic@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531287AE.5080606@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/14 02:21, Vlad Yasevich wrote:
> On 03/01/2014 02:27 PM, Vlad Yasevich wrote:
>> On 03/01/2014 06:15 AM, Christian Borntraeger wrote:
>>> On 28/02/14 23:14, Vlad Yasevich wrote:
>>>> On 02/27/2014 03:52 PM, Christian Borntraeger wrote:
>>>>> Vlad,
>>>>>
>>>>> commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
>>>>>     macvtap: Add support of packet capture on macvtap device.
>>>>>
>>>>> causes a performance regression for iperf traffic between two KVM guests
>>>>> on my s390 system. Both guests are connected via two macvtaps on the same OSA
>>>>> network card.
>>>>> Before that patch I get ~20 Gbit/sec between two guests, afterwards I get
>>>>> ~4Gbit/sec
>>>>>
>>>>> Latency seems to be unchanges (uperf 1byte ping pong).
>>>>>
>>>>> According to ifconfig in the guest, I have ~ 1500 bytes per packet with this
>>>>> patch and ~  40000 bytes without. So for some reason this patch causes the
>>>>> network stack to do segmentation. (the guest kernel stays the same, only host 
>>>>> kernel is changed).
>>>>>
>>>>> Any ideas?
>>>>
>>>> I am looking.  It shouldn't cause addition segmentations and when I ran
>>>> netperf on the code I didn't see any difference in the throughput.
>>>
>>> Dont know if the different bytes/packets ratio is really the reason or
>>> just a side effect. As a hint: the underlying network device does not support
>>> segmentation, but this should not matter for traffic between to guests.
>>
>> Could you post 'ethtool -k' output for both lower-level device and the
>> macvtap device?
>>
>> Thanks
>> -vlad
>>
> 
> Ok.  I think I see what's happening.  Since you turn off offloads on
> lower device, that's propagated to macvlan device.  As a result, when
> when we call dev_queue_xmit on the vlan->dev, we end up segmenting since
> lower level says it does support segmentation.
> 
> One way to fix this is to never disable offloads on macvlan.  macvlan
> will always try to use __dev_queue_xmit() with it's lower device, so any
> segmentation can happen there.

If you have anything that I should test, let me know.

Christian
