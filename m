From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: Staging: cpc-usb CAN driver TODO list
Date: Mon, 07 Sep 2009 12:27:36 +0200
Message-ID: <4AA4E018.8030903@grandegger.com>
References: <4AA262CB.7060607@hartkopp.net> <4AA4A0A2.2070907@ems-wuensche.com> <4AA4B0C6.5080608@grandegger.com> <4AA4BDE6.7000707@ems-wuensche.com> <4AA4CB3F.3060200@grandegger.com> <4AA4DC09.8070803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sebastian Haas <haas@ems-wuensche.com>, Greg KH <greg@kroah.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Felipe Balbi <me@felipebalbi.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:33964 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbZIGK1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 06:27:41 -0400
In-Reply-To: <4AA4DC09.8070803@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2009 12:10 PM, Oliver Hartkopp wrote:
> Wolfgang Grandegger wrote:
>> On 09/07/2009 10:01 AM, Sebastian Haas wrote:
>>> -----BEGIN PGP SIGNED MESSAGE-----
>>> Hash: SHA1
>>>
>>> Wolfgang,
>>>
>>> Wolfgang Grandegger schrieb:
>>>> Hi Sebastian,
>>>>
>>>> On 09/07/2009 07:56 AM, Sebastian Haas wrote:
>>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>>> Hash: SHA1
>>>>>
>>>>> Oliver,
>>>>>
>>>>> I'm not yet sure how to actually start the development. There is so
>>>>> much
>>>>> to do, and I've not much time to spend on this, unfortunately. Because
>>>>> of this I can't rewrite the whole driver on my own in order to get a
>>>>> Socket-CAN driver but I can provide support, review patches, rent
>>>>> devices and make tests here.
>>>>>
>>>>> Oliver, you are not familiar with USB and I'm not very familiar with
>>>>> CAN
>>>>> netdev internals, why not combining these twos. You are writing the CAN
>>>>> part and write the USB part.
>>>>>
>>>>> I'll also write a specification which contains any information you need
>>>>> to develop a CAN driver for the device (commands, sequences, error
>>>>> handling).
>>>>
>>>> Alternatively, EMS Wuensche could also hire an expert doing the job ;-).
>>>> Note that we do a lot of Socket-CAN work in our free time, which is a
>>>> limited resource. Progress depends on funding to a certain extend.
>>> Money is also a limited resource. ;-)
>>>
>>> Let's become serious again, I know and respect that many of Socket-CAN
>>> and the Staging developers spend their free time working on it. We will
>>> of course work on the driver, but since we've not much time it may take
>>> several months. If someone wants to help, we would be very glad and
>>> happy to support the person as far as we can with devices, answers and
>>> tests.
>>
>> OK, no problem. I really appreciate your support for Socket-CAN so far.
>
> Indeed. Me too.
>
> I tried to take a second look into cpc-usb_drv.c and i would suggest to remove
> all the procfs and the chardev stuff and then create a CAN netdev when you
> identified an USB node analogue to
>
>          /* Detect available channels */
>          for (i = 0; i<  EMS_PCMCIA_MAX_CHAN; i++) {
>                  dev = alloc_sja1000dev(0);
>                  if (dev == NULL) {
>                          err = -ENOMEM;
>                          goto failure_cleanup;
>                  }
>
>                  card->net_dev[i] = dev;
>                  priv = netdev_priv(dev);
>                  priv->priv = card;
>                  SET_NETDEV_DEV(dev,&pdev->dev);
>
> as you know from your ems_pcmcia.c driver
>
> and
>
> struct net_device *alloc_sja1000dev(int sizeof_priv)
> {
>          struct net_device *dev;
>          struct sja1000_priv *priv;
>
>          dev = alloc_candev(sizeof(struct sja1000_priv) + sizeof_priv);
>          if (!dev)
>                  return NULL;
>
>          priv = netdev_priv(dev);
>
>          priv->dev = dev;
>          priv->can.bittiming_const =&sja1000_bittiming_const;
>          priv->can.do_set_bittiming = sja1000_set_bittiming;
>          priv->can.do_set_mode = sja1000_set_mode;
>
>          if (sizeof_priv)
>                  priv->priv = (void *)priv + sizeof(struct sja1000_priv);
>
>          return dev;
> }
>
> as you know from the sja1000.c (which can probably be used for the
> LPC2119_PRODUCT_ID we should try to implement first).
>
> Then we need something like this stuff
>
> static const struct net_device_ops sja1000_netdev_ops = {
>          .ndo_open               = sja1000_open,
>          .ndo_stop               = sja1000_close,
>          .ndo_start_xmit         = sja1000_start_xmit,
> };
>
> int register_sja1000dev(struct net_device *dev)
> {
>          if (!sja1000_probe_chip(dev))
>                  return -ENODEV;
>
>          dev->netdev_ops =&sja1000_netdev_ops;
>
>          dev->flags |= IFF_ECHO; /* we support local echo */
>
>          set_reset_mode(dev);
>          chipset_init(dev);
>
>          return register_candev(dev);
> }
>
> from sja1000.c
>
> And then we have an USB CAN node that has a belonging CAN netdevice (maybe
> there is something else we can look at that's used in other USB ethernet
> adapters).
>
> I know from the PEAK USB driver at
>
> http://www.peak-system.com/fileadmin/media/linux/files/peak-linux-driver.6.11.tar.gz
>
> that i just needed to duplicate and modify the usb rx/tx stuff and redirect
> the CAN frames into the network stack. But this PEAK driver does not have a
> netlink configuration interface and can only be taken as a limited example ...
>
> I assume, when the driver (cpc_usb.c or ems_usb.c analogue to the ems_pcmcia.c
> ?) is prepared as described above, one can go and connect the rx/tx dataflow
> and the netlink configuration.
>
> Unfortunately i'm short of time the next two weeks but maybe you can start and
> create such a new C-file (probably based on ems_pcmcia.c) ?

Also, there are USB network driver in "drivers/net/usb/" which might 
serve as examples.

Wolfgang.
