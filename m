From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading client_list
 or device_list
Date: Wed, 13 May 2015 11:10:15 +0300
Message-ID: <555306E7.9020000@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
 <20150511181824.GA25405@obsidianresearch.com> <555198B7.40302@mellanox.com>
 <20150512182332.GD15891@obsidianresearch.com>
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
Received: from mail-db3on0076.outbound.protection.outlook.com ([157.55.234.76]:15791
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933039AbbEMIKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 04:10:30 -0400
In-Reply-To: <20150512182332.GD15891@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2015 21:23, Jason Gunthorpe wrote:
> On Tue, May 12, 2015 at 09:07:51AM +0300, Haggai Eran wrote:
>>> I'm not sure RCU is the right way to approach this. The driver core
>>> has the same basic task to perform, maybe review it's locking
>>> arrangment between the device list and driver list.
>>>
>>> [Actually we probably should be using the driver core here, with IB
>>>  clients as device drivers, but that is way beyond scope of this..]
>>
>> So, I'm not very familiar with that code, but it seems that the main
>> difference is that in the core a single driver can be attached to a
>> device. 
> 
> Roughly, a bus (IB would be a bus) has devices attached to it, and
> devices have drivers attached to them. Bus:Device is 1:N,
> Device:Drvier is 1:1. 
> 
> There a a couple of reasons to be interested in re-using the driver
> core, perhaps the best is that it has all the infrastructure to let us
> auto-load client modules...

So you want an ib_core bus and each client is a "device" or a driver on
that bus? But this doesn't get you the relation between clients and ib
devices.

> 
>> I guess a similar thing we can do is to rely on the context we associate
>> with a pair of a client and a device. If such a context exist, we don't
>> need to call client->add again. What do you think?
> 
> I didn't look closely, isn't this enough?
> 
> device_register:
>  mutex_lock(client_mutex);
>  down_write(devices_rwsem);
>  list_add(device_list,dev,..);
>  up_write(devices_rwsem);
> 
>  /* Caller must prevent device_register/unregister concurrancy on the
>     same dev */
> 
>  foreach(client_list)
>    .. client->add(dev,...) .. 
> 
>  mutex_unlock(client_mutex)
> 
> client_register:
>  mutex_lock(client_mutex)
>  list_add(client_list,new_client..)
>  down_read(devices_rwsem);
>  foreach(device_list)
>    .. client->add(dev,new_client,..) ..
>  up_read(devices_rwsem);
>  mutex_unlock(client_mutex)
> 
> [Note, I didn't check this carefully, just intuitively seems like a
>  sane starting point]

That could perhaps work for the RoCEv2 patch-set, as their deadlock
relates to iterating the device list. This patch set however does an
iteration on the client list (patch 3). Because a client remove could
block on this iteration, you can still get a deadlock.

I think I prefer keeping the single device_mutex and the SRCU, but
keeping the device_mutex locked as it is today, covering all of the
registration and unregistration code. Only the new code that reads the
client list or the device list without modification to the other list
will use the SRCU read lock.

Haggai
