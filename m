From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Fri, 25 Nov 2011 11:09:21 +0800
Message-ID: <4ECF06E1.8000206@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com>
	<20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com>
	<20111124161430.GC26770@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, arnd@arndb.de, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111124161430.GC26770@redhat.com>
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

On 11/25/2011 12:14 AM, Michael S. Tsirkin wrote:
> On Thu, Nov 24, 2011 at 08:56:45PM +0800, jasowang wrote:
>> >  On 11/24/2011 06:34 PM, Michael S. Tsirkin wrote:
>>> >  >On Thu, Nov 24, 2011 at 06:13:41PM +0800, jasowang wrote:
>>>> >  >>On 11/24/2011 05:59 PM, Michael S. Tsirkin wrote:
>>>>> >  >>>On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
>>>>>> >  >>>>It was reported that the macvtap device selects a
>>>>>> >  >>>>different vhost (when used with multiqueue feature)
>>>>>> >  >>>>for incoming packets of a single connection. Use
>>>>>> >  >>>>packet hash first. Patch tested on MQ virtio_net.
>>>>> >  >>>So this is sure to address the problem, why exactly does this happen?
>>>> >  >>Ixgbe has flow director and bind queue to host cpu, so it can make
>>>> >  >>sure the packet of a flow to be handled by the same queue/cpu. So
>>>> >  >>when vhost thread moves from one host cpu to another, ixgbe would
>>>> >  >>therefore send the packet to the new cpu/queue.
>>> >  >Confused. How does ixgbe know about vhost thread moving?
>> >  
>> >  As far as I can see, ixgbe binds queues to physical cpu, so let consider:
>> >  
>> >  vhost thread transmits packets of flow A on processor M
>> >  during packet transmission, ixgbe driver programs the card to
>> >  deliver the packet of flow A to queue/cpu M through flow director
>> >  (see ixgbe_atr())
>> >  vhost thread then receives packet of flow A with from M
>> >  ...
>> >  vhost thread transmits packets of flow A on processor N
>> >  ixgbe driver programs the flow director to change the delivery of
>> >  flow A to queue N ( cpu N )
>> >  vhost thread then receives packet of flow A with from N
>> >  ...
>> >  
>> >  So, for a single flow A, we may get different queue mappings. Using
>> >  rxhash instead may solve this issue.
> Or better, transmit a single flow from a single vhost thread.

It has already worked this way, as the tx queue were choose based on tx 
hash in guest(),  but vhost thread can move among processors.

>
> If packets of a single flow get spread over different CPUs,
> they will get reordered and things are not going to work well.
>

The problem is that vhost does not handle TCP itself but ixgbe driver 
would think it does, so the nic would deliver packets of a single flow 
to different CPUs when the vhost thread who does the transmission moves.

So, in conclusion, if we do not consider features of  under layer nic, 
using rxhash instead of queue mappings to identify a flow is better.
