From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading
 client_list or device_list
Date: Wed, 13 May 2015 09:57:37 -0600
Message-ID: <20150513155737.GA16941@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
 <20150511181824.GA25405@obsidianresearch.com>
 <555198B7.40302@mellanox.com>
 <20150512182332.GD15891@obsidianresearch.com>
 <555306E7.9020000@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <555306E7.9020000-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 13, 2015 at 11:10:15AM +0300, Haggai Eran wrote:

> >> I guess a similar thing we can do is to rely on the context we associate
> >> with a pair of a client and a device. If such a context exist, we don't
> >> need to call client->add again. What do you think?
> > 
> > I didn't look closely, isn't this enough?
> > 
> > device_register:
> >  mutex_lock(client_mutex);
> >  down_write(devices_rwsem);
> >  list_add(device_list,dev,..);
> >  up_write(devices_rwsem);
> > 
> >  /* Caller must prevent device_register/unregister concurrancy on the
> >     same dev */
> > 
> >  foreach(client_list)
> >    .. client->add(dev,...) .. 
> > 
> >  mutex_unlock(client_mutex)
> > 
> > client_register:
> >  mutex_lock(client_mutex)
> >  list_add(client_list,new_client..)
> >  down_read(devices_rwsem);
> >  foreach(device_list)
> >    .. client->add(dev,new_client,..) ..
> >  up_read(devices_rwsem);
> >  mutex_unlock(client_mutex)
> > 
> > [Note, I didn't check this carefully, just intuitively seems like a
> >  sane starting point]
> 
> That could perhaps work for the RoCEv2 patch-set, as their deadlock
> relates to iterating the device list. This patch set however does an
> iteration on the client list (patch 3). Because a client remove could
> block on this iteration, you can still get a deadlock.

Really? Gross.

Still, I think you got it right in your analysis, but we don't need RCU:

device_register:
 mutex_lock(modify_mutex);
 down_write(lists_rwsem);
 list_add(device_list,dev,..);
 up_write(lists_rwsem);

 // implied by modify_mutex: down_read(lists_rwsem)
 foreach(client_list)
    .. client->add(dev,...) ..
 mutex_unlock(modify_mutex)

client_register:
 mutex_lock(modify_mutex);
 // implied by modify_mutex: down_read(lists_rwsem)
 foreach(device_list)
    .. client->add(dev,new_client...) ..

 down_write(lists_rwsem);
 list_add(client_list,new_client..);
 up_write(lists_rwsem);

 mutex_unlock(modify_mutex)

client_unregister:
 mutex_lock(modify_mutex);
 down_write(lists_rwsem);
 list_cut(client_list,..rm_client..);
 up_write(lists_rwsem);

 // implied by modify_mutex: down_read(lists_rwsem)
 foreach(device_list)
    .. client->remove(dev,rm_client...) ..

 mutex_unlock(modify_mutex)

etc. Notice the ordering.

> I think I prefer keeping the single device_mutex and the SRCU, but
> keeping the device_mutex locked as it is today, covering all of the
> registration and unregistration code. Only the new code that reads the
> client list or the device list without modification to the other list
> will use the SRCU read lock.

In this case, I don't see a justification to use RCU, we'd need a
high read load before optimizing the rwsem into RCU would make
sense.

I'm not sure you should ever use RCU until you've designed the locking
using traditional means.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
