From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v6 05/23] rocker: support prepare-commit
 transaction model
Date: Sat, 9 May 2015 23:14:00 -0700
Message-ID: <CAE4R7bByr2tMv56DHFyee0KRz0dGtoZgjcxfLtefh2rH_-H7bA@mail.gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
	<1431193225-807-6-git-send-email-sfeldma@gmail.com>
	<20150509181824.GA2290@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Joe Perches <joe@perches.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:33754 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbbEJGOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 02:14:02 -0400
Received: by qcvo8 with SMTP id o8so31663449qcv.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 23:14:00 -0700 (PDT)
In-Reply-To: <20150509181824.GA2290@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 9, 2015 at 11:18 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sat, May 09, 2015 at 07:40:07PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>For rocker, support prepare-commit transaction model for setting attributes
>>(and for adding objects).  This requires rocker to preallocate memory
>>needed for the commit up front in the prepare phase.  Since rtnl_lock is
>>held between prepare-commit, store the allocated memory on a queue hanging
>>off of the rocker_port.  Also, in prepare phase, do everything right up to
>>calling into HW.  The same code paths are tranversed in the driver for both
>>prepare and commit phases.  In some cases, any state modified in the
>>prepare phase must be reverted before returning so the commit phase makes
>>the same decisions.
>>
>>As a consequence of holding rtnl_lock in process context for all attr sets
>>(and obj adds), all memory is GFP_KERNEL allocated and we don't need to
>>busy spin waiting for the device to complete the command.  So the bulk of
>>this patch is simplifying the memory allocations to only use GFP_KERNEL and
>>to remove the nowait flag and busy spin loop.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> drivers/net/ethernet/rocker/rocker.c |  393 +++++++++++++++++++++++-----------
>> 1 file changed, 271 insertions(+), 122 deletions(-)
>>
>
> ...
>
>>+static void *__rocker_port_alloc(struct rocker_port *rocker_port,
>>+                               size_t size, gfp_t flags,
>>+                               void *(*alloc)(size_t size, gfp_t flags))
>>+{
>
> you can omit alloc param here, since __rocker_port_alloc is called
> always with kzalloc. Also, flags is always GFP_KERNEL, but I have no
> problem in having that.

fixed for v7

> also, __rocker_port_alloc sond to me like it allocates actual port.
> Maybe "__rocker_per_port_alloc" or something like that?
> (same goes to other functions of similar name)

It's now __rocker_port_mem_alloc.

>>+      struct list_head *elem = NULL;
>>+
>>+      /* If in transaction prepare phase, allocate the memory
>>+       * and enqueue it on a per-port list.  If in transaction
>>+       * commit phase, dequeue the memory from the per-port list
>>+       * rather than re-allocating the memory.  The idea is the
>>+       * driver code paths for prepare and commit are identical
>>+       * so the memory allocated in the prepare phase is the
>>+       * memory used in the commit phase.
>>+       */
>>+
>>+      switch (rocker_port->trans) {
>>+      case SWITCHDEV_TRANS_PREPARE:
>>+              elem = alloc(size + sizeof(*elem), flags);
>>+              if (!elem)
>>+                      return NULL;
>>+              list_add_tail(elem, &rocker_port->trans_mem);
>>+              break;
>>+      case SWITCHDEV_TRANS_COMMIT:
>>+              BUG_ON(list_empty(&rocker_port->trans_mem));
>>+              elem = rocker_port->trans_mem.next;
>>+              list_del_init(elem);
>>+              break;
>>+      case SWITCHDEV_TRANS_NONE:
>>+              elem = alloc(size + sizeof(*elem), flags);
>>+              if (elem)
>>+                      INIT_LIST_HEAD(elem);
>>+              break;
>
> I must say I don't like propagating SWITCHDEV_TRANS_* this deep into
> driver. Also I don't like storing it in rocker_port->trans. I believe
> that is should be seen only by rocker_port_attr_set. Then functions with
> proper params should be called inside driver.

Ok, switched to passing it as param for v7

>
>
> ...
>
>> static int rocker_cmd_exec(struct rocker *rocker,
>>                          struct rocker_port *rocker_port,
>>                          rocker_cmd_cb_t prepare, void *prepare_priv,
>>-                         rocker_cmd_cb_t process, void *process_priv,
>>-                         bool nowait)
>>+                         rocker_cmd_cb_t process, void *process_priv)
>> {
>>       struct rocker_desc_info *desc_info;
>>       struct rocker_wait *wait;
>>       unsigned long flags;
>>       int err;
>>
>>-      wait = rocker_wait_create(nowait ? GFP_ATOMIC : GFP_KERNEL);
>>+      wait = rocker_wait_create(rocker_port);
>>       if (!wait)
>>               return -ENOMEM;
>>-      wait->nowait = nowait;
>>
>>       spin_lock_irqsave(&rocker->cmd_ring_lock, flags);
>>+
>   ^^^
>>       desc_info = rocker_desc_head_get(&rocker->cmd_ring);
>>       if (!desc_info) {
>>               spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
>>               err = -EAGAIN;
>>               goto out;
>>       }
>>+
>   ^^^
>
>>       err = prepare(rocker, rocker_port, desc_info, prepare_priv);
>>       if (err) {
>>               spin_unlock_irqrestore(&rocker->cmd_ring_lock, flags);
>>               goto out;
>>       }
>>+
>   ^^^ not sure why you adding these lines.

Readability: put some white space between logical chunks.
