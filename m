From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 2/2] tun: don't set a default qdisc
Date: Thu, 14 Apr 2016 12:09:57 +0200
Message-ID: <570F6C75.8010001@stressinduktion.org>
References: <cover.1460393493.git.pabeni@redhat.com>
 <1a216fb6cade7dcd7d2c1d4ce113a1ee6e3fdeb6.1460393493.git.pabeni@redhat.com>
 <20160413132411-mutt-send-email-mst@redhat.com> <570F3D78.3070203@redhat.com>
 <20160414090532.GA2185@redhat.com> <570F5DE6.9000305@redhat.com>
 <20160414120826-mutt-send-email-mst@redhat.com> <570F6124.6060107@redhat.com>
 <20160414125822-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:57909 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbcDNKKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 06:10:00 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 57EFC216D6
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 06:09:59 -0400 (EDT)
In-Reply-To: <20160414125822-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.04.2016 12:01, Michael S. Tsirkin wrote:
> On Thu, Apr 14, 2016 at 05:21:40PM +0800, Jason Wang wrote:
>>
>>
>> On 04/14/2016 05:10 PM, Michael S. Tsirkin wrote:
>>> On Thu, Apr 14, 2016 at 05:07:50PM +0800, Jason Wang wrote:
>>>>
>>>> On 04/14/2016 05:05 PM, Michael S. Tsirkin wrote:
>>>>> On Thu, Apr 14, 2016 at 02:49:28PM +0800, Jason Wang wrote:
>>>>>>>
>>>>>>> On 04/13/2016 06:26 PM, Michael S. Tsirkin wrote:
>>>>>>>>> On Wed, Apr 13, 2016 at 11:04:47AM +0200, Paolo Abeni wrote:
>>>>>>>>>>> This patch disables the default qdisc by explicitly setting the
>>>>>>>>>>> IFF_NO_QUEUE private flag so that now the tun xmit path do not
>>>>>>>>>>> require any lock by default.
>>>>>>>>>>>
>>>>>>>>>>> The default qdisc was first removed as a side effect of commit
>>>>>>>>>>> f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
>>>>>>>>>>> and recently restored with commit 016adb7260f4 ("tuntap: restore default qdisc")
>>>>>>>>>>>
>>>>>>>>>>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>>>>>>>> I wonder about this back and forth.
>>>>>>>>> Jason, do you see a workload where the default qdisc
>>>>>>>>> is preferable?
>>>>>>> I don't know, but we used to behave like this so we'd better keep it.
>>>>>>>
>>>>>>> An interesting thing is I vaguely remember that you have some concern
>>>>>>> when I propose IFF_NO_QUEUE for macvtap[1] :)
>>>>>>>
>>>>>>> [1] https://lkml.org/lkml/2015/8/24/147
>>>>> It's the same concern - that we aren't fully addressing
>>>>> the problem, so if user configures a qdisc, we are back to square 1.
>>>>> It's especially annoying that IIUC in this setup, if one
>>>>> does configured a non default qdisc, there's no way to go back.
>>>>> It doesn't necessarily mean we must not do it as an intermediate step,
>>>>> though.
>>>>>
>>>>>>> I think this could be done by management or more safe by introducing a
>>>>>>> new tun flag (TUN_NO_QUEUE).
>>>>> What exactly does this flag do/mean?
>>>> It means we don't need qdisc for this tuntap, so we can set IFF_NO_QUEUE
>>>> flag.
>>> But what does it mean for the user? When to set it and when not to set
>>> it?
>>
>> It was used for user that don't want qdisc (e.g for the user that only
>> cares about performance).
>
> However
> - for tun, how is a fifo qdisc functionally different?

pfifo wouldn't matter match, but the pfifo_qdisc classifies packets into 
different bands and does alter the way ip packets are transmitted 
outside. With the LLTX change I don't see how in any case a queue should 
build up, so I don't really see this as a problem.

The only reason why this change could do harm is scripting and API 
compatibility, e.g. tools expect after creation a qdisc to be present to 
modify its behavior.

> - it doesn't prevent configuring a qdisc, does it?

Correct, you can still add qdiscs later on and switch back to no_queue, 
also. We are just talking about changing the default.

Bye,
Hannes
