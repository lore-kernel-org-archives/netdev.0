From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 01/12] IB/core: pass client data to remove() callbacks
Date: Tue, 14 Jul 2015 17:54:40 +0300
Message-ID: <55A522B0.6050207@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-2-git-send-email-haggaie@mellanox.com>
 <20150708202910.GA16812@obsidianresearch.com>
 <20150708213410.GA19624@obsidianresearch.com>
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
In-Reply-To: <20150708213410.GA19624-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/07/2015 00:34, Jason Gunthorpe wrote:
> On Wed, Jul 08, 2015 at 02:29:10PM -0600, Jason Gunthorpe wrote:
>> On Mon, Jun 22, 2015 at 03:42:30PM +0300, Haggai Eran wrote:
>>> An ib_client callback that is called with the lists_rwsem locked only for
>>> read is protected from changes to the IB client lists, but not from
>>> ib_unregister_device() freeing its client data. This is because
>>> ib_unregister_device() will remove the device from the device list with
>>> lists_rwsem locked for write, but perform the rest of the cleanup,
>>> including the call to remove() without that lock.
>>
>> I was going to look at this, but, uh.. it seems mangled, doesn't
>> apply, doesn't seem fixable from here.
> 
> Okay, I see, it sits on top of the patch from Matan's last
> posting.. My bad.
No problem.

> Hum... I have to say I don't really like this, changing the ordering
> of client_data = NULL with respect to client->remove doesn't seem like
> a great idea - and the rds changes look scary to me, at least I
> couldn't confidently say they were OK..
> 
> And that isn't really the issue - this has nothing to do with
> client_data, it is all about not having a callback running when doing
> remove.
> 
> It looks like the way out of this is to have ib_get_net_dev_by_params
> iterate over the client_data_list and use a dedicated flag in that
> struct to indicate that client&device combination is
> remove-in-progress.
> 
> This would be a bit more efficient as well, and I would suggest
> passing the context in as an arg to the callback.
>
> client_data_list would change a bit to become write locked first by
> write(lists_rwsem), and then second by the spin lock, so holding
> read(lists_rwsem) while iterating is enough locking, and you'd hold
> lists_rwsem while kfreeing.

So, I don't want to keep lists_rwsem for write while calling add() and
remove(). This would cause the deadlock that required the lists_rwsem
patch in the first place. I guess I can drop lists_rwsem before the
add/remove call and take it afterwards.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
