From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v1.2.26] wan: new driver retina
Date: Fri, 30 May 2008 18:15:55 +0200
Message-ID: <m3lk1rhio4.fsf@maximus.localdomain>
References: <ca0148c30805280342l39ffe387rf4c670b17804f99d@mail.gmail.com>
	<m3prr6obkz.fsf@maximus.localdomain>
	<ca0148c30805300552u7eb5da43tfc75127a2e819d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Matti Linnanvuori" <mattilinn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58898 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093AbYE3QP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:15:58 -0400
In-Reply-To: <ca0148c30805300552u7eb5da43tfc75127a2e819d1@mail.gmail.com> (Matti Linnanvuori's message of "Fri\, 30 May 2008 15\:52\:59 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Matti Linnanvuori" <mattilinn@gmail.com> writes:

> I would not like to change a legacy driver much.

But this is a new driver, right? I guess the SIOCDEVPRIVATEs will go
at some point so the change can't be really avoided.

>>> +static int fepci_char_open(struct inode *inode, struct file *filp)
>>> +{
>>> +     unsigned int minor = MINOR(inode->i_rdev);
>>> +     if (unlikely(minor >= find_cnt || card_privates[minor].pci_dev == NULL))
>>> +             return -ENXIO;
>>> +     filp->f_op = &fepci_char_fops;
>>> +     if (unlikely(!try_module_get(THIS_MODULE)))
>>> +             return -EBUSY;
>>
>> That won't work race-free, use owner field.
>
> You mean the f_op assignment? I have removed that.

Actually I meant try_module_get() from within the driver, for example
your module may get unloaded while in this function, before this
try_module_get(), and that would be fatal. If you set the owner field
the reference count will be incremented by the caller first.

Though you may be right about the assignement as well.

>>> +static int fepci_stream_open_down(struct net_device *dev,
>>> +                               struct fepci_ch_private *fp)
>>> +{
>>> +     unsigned tx_pages, rx_pages, tx_order, rx_order;
>>> +     unsigned page_number;
>>> +     unsigned int i;
>>> +
>>> +     if (unlikely(fp->in_eth_mode)) {
>>> +             dev_warn(&dev->dev,
>>> +                      "Interface is in Ethernet mode, "
>>> +                      "cannot open stream interface\n");
>>> +             return -EBUSY;
>>> +     }

> Private net device ioctls are locked with rtnl_lock, so I see no
> race there.

Yes, I thought stream mode = character device but now I see it's
another flavour of network device(?), which is never up and exists
only for the ability to receive netdev ioctls (though it also uses
char dev ioctls).

Did I get this right?

Why not simply use a character device, with normal read, write etc?
-- 
Krzysztof Halasa
