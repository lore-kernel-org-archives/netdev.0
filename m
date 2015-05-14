From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading client_list
 or device_list
Date: Thu, 14 May 2015 13:35:36 +0300
Message-ID: <55547A78.5080404@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
 <20150511181824.GA25405@obsidianresearch.com> <555198B7.40302@mellanox.com>
 <20150512182332.GD15891@obsidianresearch.com> <555306E7.9020000@mellanox.com>
 <20150513155737.GA16941@obsidianresearch.com>
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
Received: from mail-am1on0067.outbound.protection.outlook.com ([157.56.112.67]:12137
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932299AbbENKgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 06:36:13 -0400
In-Reply-To: <20150513155737.GA16941@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/05/2015 18:57, Jason Gunthorpe wrote:
> On Wed, May 13, 2015 at 11:10:15AM +0300, Haggai Eran wrote:
> 
>>>> I guess a similar thing we can do is to rely on the context we associate
>>>> with a pair of a client and a device. If such a context exist, we don't
>>>> need to call client->add again. What do you think?
>>>
>>> I didn't look closely, isn't this enough?
>>>
>>> device_register:
>>>  mutex_lock(client_mutex);
>>>  down_write(devices_rwsem);
>>>  list_add(device_list,dev,..);
>>>  up_write(devices_rwsem);
>>>
>>>  /* Caller must prevent device_register/unregister concurrancy on the
>>>     same dev */
>>>
>>>  foreach(client_list)
>>>    .. client->add(dev,...) .. 
>>>
>>>  mutex_unlock(client_mutex)
>>>
>>> client_register:
>>>  mutex_lock(client_mutex)
>>>  list_add(client_list,new_client..)
>>>  down_read(devices_rwsem);
>>>  foreach(device_list)
>>>    .. client->add(dev,new_client,..) ..
>>>  up_read(devices_rwsem);
>>>  mutex_unlock(client_mutex)
>>>
>>> [Note, I didn't check this carefully, just intuitively seems like a
>>>  sane starting point]
>>
>> That could perhaps work for the RoCEv2 patch-set, as their deadlock
>> relates to iterating the device list. This patch set however does an
>> iteration on the client list (patch 3). Because a client remove could
>> block on this iteration, you can still get a deadlock.
> 
> Really? Gross.
> 
> Still, I think you got it right in your analysis, but we don't need RCU:
> 
> device_register:
>  mutex_lock(modify_mutex);
>  down_write(lists_rwsem);
>  list_add(device_list,dev,..);
>  up_write(lists_rwsem);
> 
>  // implied by modify_mutex: down_read(lists_rwsem)
>  foreach(client_list)
>     .. client->add(dev,...) ..
>  mutex_unlock(modify_mutex)
> 
> client_register:
>  mutex_lock(modify_mutex);
>  // implied by modify_mutex: down_read(lists_rwsem)
>  foreach(device_list)
>     .. client->add(dev,new_client...) ..
> 
>  down_write(lists_rwsem);
>  list_add(client_list,new_client..);
>  up_write(lists_rwsem);
> 
>  mutex_unlock(modify_mutex)
> 
> client_unregister:
>  mutex_lock(modify_mutex);
>  down_write(lists_rwsem);
>  list_cut(client_list,..rm_client..);
>  up_write(lists_rwsem);
> 
>  // implied by modify_mutex: down_read(lists_rwsem)
>  foreach(device_list)
>     .. client->remove(dev,rm_client...) ..
> 
>  mutex_unlock(modify_mutex)
> 
> etc. Notice the ordering.
> 

Looks good. I'll use it in the next version of the patch.
