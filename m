From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Sat, 11 Jan 2014 01:53:26 +0100
Message-ID: <87zjn3z6d5.fsf@nemi.mork.no>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Thomas Kear's message of "Sat, 11 Jan 2014 12:41:06 +1300")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org> writes:

> On Sat, Jan 11, 2014 at 11:09 AM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wro=
te:
>> But looking at the code I think I found and obvious miss in the SG l=
ist
>> initialisation.  I'll post a proposed fix for that.  Would be good i=
f
>> someone was able to test it.
>
> I've built 3.13.0-rc7-next-20140110 with your patch applied.
> Unfortunately since this bug has taken anywhere from minutes to days
> to manifest previously I'm not sure how quickly I'll be able to repor=
t
> on its efficacy.

Thanks for testing it.=20

If I'm correct, then your problem is caused by usbnet incrementing
urb->num_sgs above the value sg_init_table was called with. This happen=
s
if usbnet adds padding to a fragmented skb.  Unfortunately I have no
idea how you can create fragmented skbs with a certain length.  But I'm
sure others here know?

This bug in usbnet makes usb_hcd_map_urb_for_dma() call dma_map_sg()
with nents set past an entry with the SG chain termination bit set. Thi=
s
bit makes the call to sg_next return NULL, even if there is another non
NULL entry in the list.  So when dma_map_sg does

        for_each_sg(sg, s, nents, i)
                kmemcheck_mark_initialized(sg_virt(s), s->length);

it ends up dereferencing NULL.

> I currently have the adapter plugged in through a 4-port USB3 hub
> (2109:0811, which appears to be a VIA chip) but I will test it
> directly attached to the laptop too.

I don't think that should matter.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
