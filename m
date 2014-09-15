From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c: Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 23:47:33 +0200
Message-ID: <CAFo99gb9Rqnc7HrPbN7UVyQwPv_a=fxAbe+FTtm+9GgsjG7StA@mail.gmail.com>
References: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <063D6719AE5E284EB5DD2968C1650D6D17491F2B@AcuExch.aculab.com>
 <5416A65D.6010500@pengutronix.de> <063D6719AE5E284EB5DD2968C1650D6D17491F83@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17491F83@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-09-15 10:47 GMT+02:00 David Laight <David.Laight@aculab.com>:
> From: Marc Kleine-Budde [
>> On 09/15/2014 10:28 AM, David Laight wrote:
>> > From: Rickard Strandqvist
>> > ...
>> >> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
>> > ...
>> >> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> >> b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> >> index 644e6ab..d4fe8ac 100644
>> >> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> >> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> >> @@ -830,7 +830,7 @@ static void peak_usb_disconnect(struct usb_interface *intf)
>> >>            char name[IFNAMSIZ];
>> >>
>> >>            dev->state &= ~PCAN_USB_STATE_CONNECTED;
>> >> -          strncpy(name, netdev->name, IFNAMSIZ);
>> >> +          strlcpy(name, netdev->name, IFNAMSIZ);
>> >>
>> >>            unregister_netdev(netdev);
>> >>            free_candev(netdev);
>> >
>> > Or:
>> >     char name[sizeof netdev->name];
>> >     memcpy(name, netdev->name, sizeof netdev->name);
>>
>> I would be "sizeof(foo)" in kernel coding style,
> But not in mine :-)
> sizeof is an operator, not a function, it's argument can be (type).
>
>> but let's have a look at the original code:
>>
>>                 struct net_device *netdev = dev->netdev;
>>                 char name[IFNAMSIZ];
>>
>>                 dev->state &= ~PCAN_USB_STATE_CONNECTED;
>>                 strncpy(name, netdev->name, IFNAMSIZ);
>>
>>                 unregister_netdev(netdev);
>>                 free_candev(netdev);
>>
>>                 kfree(dev->cmd_buf);
>>                 dev->next_siblings = NULL;
>>                 if (dev->adapter->dev_free)
>>                         dev->adapter->dev_free(dev);
>>
>>                 dev_info(&intf->dev, "%s removed\n", name);
>>
>> I think it's save to use:
>>
>>     dev_info(&intf->dev, "%s removed\n", netdev_name(dev->netdev));
>>
>> instead of doing the str?cpy() in the first place. But why not use:
>>
>>     netdev_info(dev->netdev, "removed\n");
>>
>> Is the USB device information lost when using netdev_info()?
>
> My guess is it avoids a 'use after free' - but I'm not going to
> dig that far.
>
> Another issue with blindly replacing strncpy() with strlcpy()
> (which doesn't affect the above) is when copying status to userspace.
>
>         David


Hi all

I have been more and more careful so I did not introduce the type of
error that can arise by blindly replacing strncpy to strlcpy.
But this is one of the most apparent where there will not be a problem.

I liked the variant:
char name[sizeof(netdev->name)];

But dislike and do not understand what the point would be with memcpy variant.


Kind regards
Rickard Strandqvist
