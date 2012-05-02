From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 01/14 v3] usb/net: rndis: inline the cpu_to_le32() macro
Date: Wed, 2 May 2012 12:22:37 +0200
Message-ID: <CACRpkdYhZcNLfZ-EiJ6gmqriMdSkgAbLpQs7nGoSzLq_nMEEeg@mail.gmail.com>
References: <1335896100-12469-1-git-send-email-linus.walleij@linaro.org>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6EFE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EFE-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 2, 2012 at 10:44 AM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>=
 wrote:
>> [mailto:netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Linus Walleij

>> The header file <linux/usb/rndis_host.h> used a number of #defines
>> that included the cpu_to_le32() macro to assure the result will be
>> in LE endianness. Inlining this into the code instead of using it
>> in the code definitions yields consolidation opportunities later
>> on as you will see in the following patches. The individual
>> drivers also used local defines - all are switched over to the
>> pattern of doing the conversion at the call sites instead.
>>
>> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>> diff --git a/drivers/net/usb/rndis_host.c
>> b/drivers/net/usb/rndis_host.c
>> index c8f1b5b..05cad0b 100644
>> --- a/drivers/net/usb/rndis_host.c
>> +++ b/drivers/net/usb/rndis_host.c
>> @@ -78,10 +78,10 @@ static void rndis_msg_indicate(struct
>> usbnet *dev, struct rndis_indicate *msg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->driver_info->indication(dev, msg, b=
uflen);
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (msg->status) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 case RNDIS_STATUS_MEDIA_CONNECT:
>> + =A0 =A0 =A0 =A0 =A0 =A0 case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNEC=
T):
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(udev, "rndis me=
dia connect\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> I don't actually see how this helps!

It helps to unify the #defines, so we can consolidate them
in patch 2/13.

I.e today we have:
include/linux/usb/rndis_host.h
#define        RNDIS_STATUS_MEDIA_CONNECT              cpu_to_le32(0x40=
01000b)
drivers/usb/gadget/rndis.h
#define RNDIS_STATUS_MEDIA_CONNECT     0x4001000BU
drivers/net/hyperv/hyperv_net.h
#define RNDIS_STATUS_MEDIA_CONNECT             (0x4001000BL)

Notice the odd bird on the top.

After this patch I can collapse these three defines into one.

As the overall goal is to start to unify the four different
RNDIS implementations in the kernel today.

> It seems to make the code more unreadable and more likely to
> be wrong (due to typos/coding slipups etc).
> I didn't see anything in the earlier versions of the patches
> where leaving the constants 'host endian' helped.

OK I guess this means I should simply wrap all the #defines
into cpu_to_le32() in the new <linux/rndis.h>?

I think the reason it looks as it does is that the rndis host is
the only thing that actually works on bigendian, such as when
Mac:s, SPARCs or PowerPC:s want to use RNDIS dongles.

I suspect using a BE system to produce a gadget driver
won't work, and that the hypervisor code is implicitly
LE and has never ever been designed with BE
in mind.

> I also actually suspect that the generated code for some of the
> switch statements would be better if the 'status' were byteswapped.
> In particular it might allow the compiler to use a jump table
> (when all the case labels are in one set of values).

Hm not sure if I'm following what you want me to do here...

I could cook a patch set with all defines wrapped in the cpu_to_le32()
macro to begin with.

Yours,
Linus Walleij
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
