From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading
 client_list or device_list
Date: Mon, 11 May 2015 12:18:24 -0600
Message-ID: <20150511181824.GA25405@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:50301 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753668AbbEKSS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 14:18:27 -0400
Content-Disposition: inline
In-Reply-To: <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 01:26:32PM +0300, Haggai Eran wrote:
> Currently the RDMA subsystem's device list and client list are protected by
> a single mutex. This prevents adding user-facing APIs that iterate these
> lists, since using them may cause a deadlock. The patch attempts to solve
> this problem by adding an SRCU to protect the lists. Readers now don't need
> the mutex, and are safe just by using srcu_read_lock/unlock.
> 
> The ib_register_device, ib_register_client, and ib_unregister_client
> functions are modified to only lock the device_mutex during their
> respective list modification, and use the SRCU for iteration on the other
> list. In ib_unregister_device, the client list iteration remains in the
> mutex critical section as it is done in reverse order.
> 
> This patch attempts to solve a similar need [1] that was seen in the RoCE
> v2 patch series.
> 
> [1] http://www.spinics.net/lists/linux-rdma/msg24733.html

So at first blush this looked reasonable, but, no it is racy:

ib_register_client:
 mutex_lock(&device_mutex);
 list_add_tail_rcu(&client->list, &client_list);
 mutex_unlock(&device_mutex);

 id = srcu_read_lock(&device_srcu);
 list_for_each_entry_rcu(device, &device_list, core_list)
                        client->add(device);

ib_register_device:
  mutex_lock(&device_mutex);
  list_add_tail(&device->core_list, &device_list);
  mutex_unlock(&device_mutex);

  id = srcu_read_lock(&device_srcu);
  list_for_each_entry_rcu(client, &client_list, list)
       client->add(device);

So, if two threads call the two registers then the new client will
have it's add called twice on the same device.

There are similar problems with removal.

I'm not sure RCU is the right way to approach this. The driver core
has the same basic task to perform, maybe review it's locking
arrangment between the device list and driver list.

[Actually we probably should be using the driver core here, with IB
 clients as device drivers, but that is way beyond scope of this..]

I had a bunch of other comments, but they are not relevant,
considering the above.

Jason
