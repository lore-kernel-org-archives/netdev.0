From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Rework rx_work_todo
Date: Wed, 15 Jan 2014 15:08:12 +0000
Message-ID: <52D6A45C.1060705@citrix.com>
References: <1389727719-21439-1-git-send-email-zoltan.kiss@citrix.com> <20140115103707.GI5698@zion.uk.xensource.com> <52D67536.4030106@citrix.com> <20140115144519.GO5698@zion.uk.xensource.com> <52D6A0B9.2030204@citrix.com> <20140115145951.GP5698@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140115145951.GP5698@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/01/14 14:59, Wei Liu wrote:
> On Wed, Jan 15, 2014 at 02:52:41PM +0000, Zoltan Kiss wrote:
>> On 15/01/14 14:45, Wei Liu wrote:
>>>>>> The recent patch to fix receive side flow control (11b57f) solved the spinning
>>>>>>>>> thread problem, however caused an another one. The receive side can stall, if:
>>>>>>>>> - xenvif_rx_action sets rx_queue_stopped to false
>>>>>>>>> - interrupt happens, and sets rx_event to true
>>>>>>>>> - then xenvif_kthread sets rx_event to false
>>>>>>>>>
>>>>>>>
>>>>>>> If you mean "rx_work_todo" returns false.
>>>>>>>
>>>>>>> In this case
>>>>>>>
>>>>>>> (!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) || vif->rx_event;
>>>>>>>
>>>>>>> can still be true, can't it?
>>>>> Sorry, I should wrote rx_queue_stopped to true
>>>>>
>>> In this case, if rx_queue_stopped is true, then we're expecting frontend
>>> to notify us, right?
>>>
>>> rx_queue_stopped is set to true if we cannot make any progress to queue
>>> packet into the ring. In that situation we can expect frontend will send
>>> notification to backend after it goes through the backlog in the ring.
>>> That means rx_event is set to true, and rx_work_todo is true again. So
>>> the ring is actually not stalled in this case as well. Did I miss
>>> something?
>>>
>>
>> Yes, we expect the guest to notify us, and it does, and we set
>> rx_event to true (see second point), but then the thread set it to
>> false (see third point). Talking with Paul, another solution could
>> be to set rx_event false before calling xenvif_rx_action. But using
>> rx_last_skb_slots makes it quicker for the thread to see if it
>> doesn't have to do anything.
>>
>
> OK, this is a better explaination. So actually there's no bug in the
> original implementation and your patch is sort of an improvement.
>
> Could you send a new version of this patch with relevant information in
> commit message? Talking to people offline is faster, but I would like to
> have public discussion and relevant information archived in a searchable
> form. Thanks.

No, there is a bug in the original implementation:
- [THREAD] xenvif_rx_action sets rx_queue_stopped to true
- [INTERRUPT] interrupt happens, and sets rx_event to true
- [THREAD] then xenvif_kthread sets rx_event to false
- [THREAD] rx_work_todo never returns true anymore

I will update the explanation and send in the patch again.

Zoli
