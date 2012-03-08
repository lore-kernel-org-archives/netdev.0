From: <Parav.Pandit@Emulex.Com>
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 10:11:17 -0800
Message-ID: <88B766C272F2C64B944B21AD078333151C956BD34F@EXMAIL.ad.emulex.com>
References: <1331142427-23721-1-git-send-email-parav.pandit@emulex.com>
 <1331142427-23721-2-git-send-email-parav.pandit@emulex.com>
 <470f5ea2-9344-42d5-b130-130d90a42250@exht1.ad.emulex.com>
 <20120308114859.GA23807@electric-eye.fr.zoreil.com>
 <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>,<20120308162716.GA31576@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:41875 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753573Ab2CHSLi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 13:11:38 -0500
In-Reply-To: <20120308162716.GA31576@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline.
Parav
________________________________________
From: Francois Romieu [romieu@fr.zoreil.com]
Sent: Thursday, March 08, 2012 9:57 PM
To: Pandit, Parav
Cc: netdev@vger.kernel.org
Subject: Re: [RFC 2/2] be2net: Added functionality to support RoCE driver

Parav.Pandit@Emulex.Com <Parav.Pandit@Emulex.Com> :
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
[...]
> > +   void *ocrdma_dev;
>
> Is there a reason why it could not be 'struct ocrdma_dev *o' ?
> [Parav] Yes. Reason is NIC driver publishes interface to RoCE driver. NIC driver is not aware of ocrdma_dev structure.
> So its void pointer.

Thanks for the explanation.

See below.

[...]
> > +   struct pci_dev *pdev = adapter->pdev;
> > +
> > +   if (!ocrdma_drv || !ocrdma_drv->add || adapter->ocrdma_dev)
> > +           return;
>
> The registration logic seems a bit convoluted.
>
> Are there real use-cases where the device and the ocrdma_drv could be loaded in different relative ordering ?
>
> [Parav] Above checks whether its already registered or not, whether it has registered proper callback function or not.
> I'll add comment for same.

I'm dense but it does not answer my concern.

- I'll admit that there is a good reason for a loose coupling between
  the ocrdma_driver and the device driver. Life would be imho simpler
  if the availability of ocrdma_driver was a prerequisite for a proper
  use of the methods exported by be_roce.c, especially as "prerequisite"
  does not forbid to request said code on the fly.

- I'm curious to know why ocrdma_drv could have a NULL .add() method.
  Imho it's the duty of register_ocrdma_drv() to enforce
  ocrdma_drv->add != NULL as soon as ocrdma_drv != NULL.
[Parav] agree.
- the adapter->ocrdma_dev test is useless. It would need _be_roce_dev_add()
  to be called both from be_roce_dev_add() and be_roce_register_driver().
  As be_roce_dev_add() depends on be_roce_register_driver() for ocrdma_drv
  to be set and be_roce_register_driver() depends on be_roce_dev_add()
  for including the device in be_adapter_list and everything is performed
  with be_adapter_list_lock held, it can't happen (TM).
[Parav] agree.

[...]
> > +void be_roce_dev_close(struct be_adapter *adapter) {
> > +   if (be_roce_supported(adapter)) {
> > +           mutex_lock(&be_adapter_list_lock);
> > +           _be_roce_dev_close(adapter);
> > +           mutex_unlock(&be_adapter_list_lock);
> > +   }
> > +}
>
> There should be no need to check for be_roce_supported() once the probe is done.
> [Parav] I think there is a need to check for same. Because NIC driver can be loaded for few device which supported NIC and few which are NIC+ROCE.
> If we don't check it will incur the cost of taking and releasing mutex lock,
> which can be easily avoid with this check.

You can init the adequate operations set at dev_add / registration time so
that the remaining be_roce_dev_xyz methods turn into noop for NIC without
ROCE.
[Parav] What do we gain by executing NO_OP function, where there is no need to do that?
What is the problem in performing this check and not executing those function? I find it more simpler and clean.

Also, add(), remove() etc operations are at driver level and not at device level. So with proposed implementation there is no need to store those 3 fn_pointers to device structure.

be_adapter_list_lock is not performance critical, is it ?
[Parav] be_adapter_list_lock is not performance critical. Driver load event is one time event in one boot cycle of server.

[...]
> > +/* ocrdma driver register's the callback functions with nic driver.
> > +*/ struct ocrdma_driver {
> > +   unsigned char name[32];
> > +   void *(*add) (struct be_dev_info *dev_info);
> > +   void (*remove) (void *device_handle);
> > +   void (*state_change_handler) (void *roce_handle, u32 new_state);
>
> Please don't abuse void * like that. :o(
> [Parav] This interface provided by NIC doesn't have to know about the
> structure of RoCE driver as its provide the service to upper layer driver.
> So void* pointer helps to achieve that.

Please see David Laight's suggestion and consider it seriously.

> I may be lacking the disadvantage of how void* could badly affect it.

It comes with a big flashing "maintenance nightmare" sign.

[...]
> Any other simpler solution/suggestion?

As long as the code of the driver does not need to access the innards
of the memory area behind a struct ocrdma_driver *, it can go along with
a 'struct ocrdma_driver;' forward declaration.

struct ocrdma_driver would be fully described in drivers/net/.../be_roce.c.
[Parav] I guess you meant ocrdma_dev structure, which will be opaque to be2net driver. ocrdma_driver is anyway exposed by be_roce.c so it is fully visible.

I won't worry if the driver can see the innards of struct ocrdma_driver
but the type checks should not be damaged.

--
Ueimor
