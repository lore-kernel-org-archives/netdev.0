From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Thu, 14 May 2015 09:48:03 +0300
Message-ID: <55544523.3090003@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com> <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com> <55532566.9040105@mellanox.com>
 <20150513165823.GA20343@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150513165823.GA20343-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/05/2015 19:58, Jason Gunthorpe wrote:
> On Wed, May 13, 2015 at 01:20:22PM +0300, Haggai Eran wrote:
...
>>> Early exit
>>> from cm_destroy_id when the there are still people listening.
>>>
>>> That sounds like it keeps the basic rule of cm_destroy_id being
>>> properly paired with the alloc, and allows listen sharing without the
>>> confusion of what does multiple destroy mean.
>>
>> Won't you find it confusing if a call to ib_destroy_cm_id is successful
>> but the id actually continues to live?
> 
> No.. As the caller, I don't care what the cm layer is doing behind the scenes.
> 
> The lifetime if each cm_id is clearly defined:
> 
> cm_create_cm_id()
> cm_ref_id() / cm_deref_id()
> cm_destroy_id()
> 
> The fact the CM might share a listen (and only a listen) ID behind the
> scenes is not the caller's problem. That is an implementation choice,
> each caller stands alone and uses the API properly, assuming it is the
> only user of the returned cm_id.
I guess that's okay. Previously, the caller relied on context
information from the CM ID to hold its own context. Now it is no longer
allowed to do that, because the listener is now shared. So With this
change in place you could argue that the caller doesn't care if the CM
ID is actually shared or not.

> 
> The caller relies on cm_destroy_id being synchronous.
> 
>> I prefer the API to explicitly show that you are only decreasing the
>> reference count and that the id might not be destroyed immediately.
> 
> No, that is fuzzy thinking, and lead to this patch that tried to have
> both a ib_cm_id_put and cm_destroy_id being used at once. That is broken.
> 
> As discussed, we can't easily convert all call sites of cm_destroy_id
> to ib_cm_id_put because 1) We loose the error code and 2) The put_X
> idiom is async while cm_destory_id users expect sync.
> 
> So the best choice is to retain the cm_create_cm_id()/cm_destroy_id()
> pairing, and have cm_destroy_id 'do the right thing' when presented
> with a shared listen to destroy -> decrease the share count and free
> the underlying listen when no more shares are left.

Okay.

> That said: Are you sure this is going to work? Are all the listen
> specific cases of cm_destroy_id OK with not doing the
> wait_for_completion and cm_dqueue_work *for stuff related to that
> client* ?

As far as I can see, a listening ib_cm_id state's can be either IDLE or
LISTEN. In these states cm_destroy_id doesn't send anything to the wire.
As for the dequeue work, I expect the queue to remain intact if the CM
ID is still used. If there are work items in the queue that would have
belonged to the particular RDMA CM ID being destroyed, then the RDMA CM
ID module will have to reject them by itself.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
