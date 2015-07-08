From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v1 01/12] IB/core: pass client data to remove() callbacks
Date: Wed, 8 Jul 2015 15:34:10 -0600
Message-ID: <20150708213410.GA19624@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-2-git-send-email-haggaie@mellanox.com>
 <20150708202910.GA16812@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42578 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758892AbbGHVeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 17:34:14 -0400
Content-Disposition: inline
In-Reply-To: <20150708202910.GA16812@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 02:29:10PM -0600, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:30PM +0300, Haggai Eran wrote:
> > An ib_client callback that is called with the lists_rwsem locked only for
> > read is protected from changes to the IB client lists, but not from
> > ib_unregister_device() freeing its client data. This is because
> > ib_unregister_device() will remove the device from the device list with
> > lists_rwsem locked for write, but perform the rest of the cleanup,
> > including the call to remove() without that lock.
> 
> I was going to look at this, but, uh.. it seems mangled, doesn't
> apply, doesn't seem fixable from here.

Okay, I see, it sits on top of the patch from Matan's last
posting.. My bad.

Hum... I have to say I don't really like this, changing the ordering
of client_data = NULL with respect to client->remove doesn't seem like
a great idea - and the rds changes look scary to me, at least I
couldn't confidently say they were OK..

And that isn't really the issue - this has nothing to do with
client_data, it is all about not having a callback running when doing
remove.

It looks like the way out of this is to have ib_get_net_dev_by_params
iterate over the client_data_list and use a dedicated flag in that
struct to indicate that client&device combination is
remove-in-progress.

This would be a bit more efficient as well, and I would suggest
passing the context in as an arg to the callback.

client_data_list would change a bit to become write locked first by
write(lists_rwsem), and then second by the spin lock, so holding
read(lists_rwsem) while iterating is enough locking, and you'd hold
lists_rwsem while kfreeing.

Jason
