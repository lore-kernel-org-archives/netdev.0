From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [net-next 13/15] ixgbe: implement SFF diagnostic monitoring via ethtool
Date: Sun, 17 Feb 2013 14:41:23 +0100
Message-ID: <CAHXqBFJEh5apNBgo59g7D8M1PAOOqo04y_uQEMJHTKwAGL3arw@mail.gmail.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAHXqBFKS9hPg23qAeiLjhk1uYk8BR=T+1+pZ1Pb5RcMr44Zs6Q@mail.gmail.com> <87618083B2453E4A8714035B62D67992337B5051@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	=?ISO-8859-1?Q?Aur=E9lien_Guillaume?= <footplus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:54643 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123Ab3BQNlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 08:41:44 -0500
Received: by mail-ie0-f176.google.com with SMTP id k13so6314229iea.35
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 05:41:43 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D67992337B5051@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/17 Tantilov, Emil S <emil.s.tantilov@intel.com>:
>>> @@ -2839,6 +2840,117 @@ static int ixgbe_set_channels(struct net_de=
vice
>>*dev,
>>>         return ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
>>>  }
>>>
>>> +static int ixgbe_get_module_info(struct net_device *dev,
>>> +                                      struct ethtool_modinfo *modi=
nfo)
>>> +{
>>> +       struct ixgbe_adapter *adapter =3D netdev_priv(dev);
>>> +       struct ixgbe_hw *hw =3D &adapter->hw;
>>> +       u32 status;
>>> +       u8 sff8472_rev, addr_mode;
>>> +       int ret_val =3D 0;
>>> +       bool page_swap =3D false;
>>> +
>>> +       /* avoid concurent i2c reads */
>>> +       while (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
>>> +               msleep(100);
>>> +
>>> +       /* used by the service task */
>>> +       set_bit(__IXGBE_READ_I2C, &adapter->state);
>>
>>This is racy. Why do you need another bit?
>
> The I2C bit helps to reduce the delay in the service task relative to=
 the initialization of the SFP modules.
>
>>
>> while (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
>>       msleep(100);
>>...
>>  clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state)
>
> This is what I had initially, but the i2c reads can take a long time =
on some parts and __IXGBE_IN_SFP_INIT protects portions of the code tha=
t have nothing to do with I2C reads. Setting __IXGBE_IN_SFP_INIT in eth=
tool while dumping the SFF data can introduce needlessly long delays in=
 the SFP initialization path.

Maybe it would be enough to protect the body of read_i2c_eeprom()
usign a mutex? It seems you want __IXGBE_READ_I2C to work like a
mutex, but you test it in non-atomic way.

Best Regards,
Micha=B3 Miros=B3aw
