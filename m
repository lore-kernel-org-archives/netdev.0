From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading client_list
 or device_list
Date: Tue, 12 May 2015 09:07:51 +0300
Message-ID: <555198B7.40302@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
 <20150511181824.GA25405@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0069.outbound.protection.outlook.com ([157.55.234.69]:59347
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752326AbbELGIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 02:08:39 -0400
In-Reply-To: <20150511181824.GA25405@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 21:18, Jason Gunthorpe wrote:
> So at first blush this looked reasonable, but, no it is racy:
> 
> ib_register_client:
>  mutex_lock(&device_mutex);
>  list_add_tail_rcu(&client->list, &client_list);
>  mutex_unlock(&device_mutex);
> 
>  id = srcu_read_lock(&device_srcu);
>  list_for_each_entry_rcu(device, &device_list, core_list)
>                         client->add(device);
> 
> ib_register_device:
>   mutex_lock(&device_mutex);
>   list_add_tail(&device->core_list, &device_list);
>   mutex_unlock(&device_mutex);
> 
>   id = srcu_read_lock(&device_srcu);
>   list_for_each_entry_rcu(client, &client_list, list)
>        client->add(device);
> 
> So, if two threads call the two registers then the new client will
> have it's add called twice on the same device.
> 
> There are similar problems with removal.

Right. Sorry I missed that. Our first draft just kept the addition and
removal of elements to the device or client list under the mutex,
thinking that only the new code in this patchset that does traversal of
the lists would use the SRCU read lock. We then changed it thinking that
it would be better to make some use of this SRCU in this patch as well.

> 
> I'm not sure RCU is the right way to approach this. The driver core
> has the same basic task to perform, maybe review it's locking
> arrangment between the device list and driver list.
> 
> [Actually we probably should be using the driver core here, with IB
>  clients as device drivers, but that is way beyond scope of this..]

So, I'm not very familiar with that code, but it seems that the main
difference is that in the core a single driver can be attached to a
device. The device_add function calls bus_add_device to add it to the
bus's list, and and later calls bus_probe_device to find a driver,
without any lock between these calls. And bus_add_driver adds a new
driver to the bus's driver list and then calls driver_attach without any
lock between them. The only thing I see that makes sure a driver won't
be attached twice to a device is the dev->driver field which is updated
under the device lock during the probing process.

I guess a similar thing we can do is to rely on the context we associate
with a pair of a client and a device. If such a context exist, we don't
need to call client->add again. What do you think?

Haggai
