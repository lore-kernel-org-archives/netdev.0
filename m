From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Wed, 13 May 2015 13:20:22 +0300
Message-ID: <55532566.9040105@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com> <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com>
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
In-Reply-To: <20150512185447.GA3503-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/05/2015 21:54, Jason Gunthorpe wrote:
> On Tue, May 12, 2015 at 09:50:51AM +0300, Haggai Eran wrote:
>> Looking at the code though, I now notice that the other call site to
>> cm_destroy_id, from within the error path of cm_process_work could now
>> theoretically destroy an ID with existing references. Is that what you
>> meant?
> 
> No, but that is certainly a problem.
>  
>> Since only listening CM IDs are now shared in RDMA CM, this should not
>> happen in this patch-set, but perhaps the code can be changed to
>> make
> 
> I think you need to enforce those semantics..
> 
> Firstly, it looks to me like we, again, have two krefs, the one you
> added and the 'ref_count'  in the priv structure which is 99% of a
> kref. So, again, don't do that.
> 
> If you want to share listening CM IDs, then do exactly and only
> that. Use the existing ref count scheme for keeping track of the
> kfree/etc, 
The existing reference count scheme is for synchronization in
cm_destroy_id. The function waits for active handlers to complete before
destroying the id. Decrementing ref_count to zero doesn't cause the id
to be freed.

> and add some kind of sharable listen ref count.
That's basically what the patch does. I can change it from a kref to a
direct reference count if you prefer.

> Early exit
> from cm_destroy_id when the there are still people listening.
> 
> That sounds like it keeps the basic rule of cm_destroy_id being
> properly paired with the alloc, and allows listen sharing without the
> confusion of what does multiple destroy mean.

Won't you find it confusing if a call to ib_destroy_cm_id is successful
but the id actually continues to live? I prefer the API to explicitly
show that you are only decreasing the reference count and that the id
might not be destroyed immediately.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
