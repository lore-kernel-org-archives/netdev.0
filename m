From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v8] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 25 Nov 2015 16:24:21 +0000
Message-ID: <yw1xd1uyoxmy.fsf@unicorn.mansr.com>
References: <1447938180-19651-1-git-send-email-mans@mansr.com>
	<5655AB63.40204@free.fr> <yw1x37vuqmcy.fsf@unicorn.mansr.com>
	<5655B0DF.8060000@free.fr> <yw1xy4dmp6vo.fsf@unicorn.mansr.com>
	<CAKgT0UdRB5DaZHc3PQDvPzePMcjASLxH2ew1zqM4ORc+P6DKNA@mail.gmail.com>
	<yw1xh9kaoy0h.fsf@unicorn.mansr.com> <5655DFFC.2050107@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:42011 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbbKYQYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:24:22 -0500
In-Reply-To: <5655DFFC.2050107@free.fr> (Mason's message of "Wed, 25 Nov 2015
	17:21:16 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 25/11/2015 17:16, M=E5ns Rullg=E5rd wrote:
>
>> Alexander Duyck writes:
>>=20
>>> On Wed, Nov 25, 2015 at 5:04 AM, M=E5ns Rullg=E5rd wrote:
>>>
>>>> Mason writes:
>>>>
>>>>> On 25/11/2015 13:45, M=E5ns Rullg=E5rd wrote:
>>>>>
>>>>>> Mason wrote:
>>>>>>
>>>>>>> On 19/11/2015 14:02, Mans Rullgard wrote:
>>>>>>>
>>>>>>>> +  if (dma_mapping_error(&dev->dev, dma_addr)) {
>>>>>>>> +          skb_free_frag(data);
>>>>>>>> +          return -ENOMEM;
>>>>>>>> +  }
>>>>>>>
>>>>>>> I'm back-porting this driver to 4.1
>>>>>>>
>>>>>>> skb_free_frag() was introduced in 4.2 by 181edb2bfa22b IIUC.
>>>>>>>
>>>>>>> +static inline void skb_free_frag(void *addr)
>>>>>>> +{
>>>>>>> +       __free_page_frag(addr);
>>>>>>> +}
>>>>>>>
>>>>>>> Should I just copy the definition of __free_page_frag() ?
>>>>>>
>>>>>> Looks like it ought to work.  Try and find out.  Not that you'll=
 ever
>>>>>> hit that error condition unless you fake it.
>>>>>
>>>>> Turns out __free_pages_ok() is static and I'd rather not touch
>>>>> mm/page_alloc.c in my back-port.
>>>>>
>>>>> Since you say the error condition is rare, I think I'll go with
>>>>> the code that 181edb2bfa22b replaced (put_page, IIUC).
>>>>>
>>>>> #include <linux/version.h>
>>>>> #if LINUX_VERSION_CODE < KERNEL_VERSION(4,2,0)
>>>>> #define skb_free_frag(data) put_page(virt_to_head_page(data))
>>>>> #else
>>>>> #error DELETE ME NOW (see commit 181edb2bfa22b)
>>>>> #endif
>>>>
>>>> You can simply put_page(page) instead since we already have the
>>>> virt_to_head_page() a few lines up.
>>>
>>> What you could do is use __free_pages instead of __free_pages_ok.
>>> Generally you will want to use __free_pages instead of put_page jus=
t
>>> to avoid a bunch of unnecessary tests and function pointer accesses=
=2E
>>=20
>> Note that this is on a should-never-happen error path, so there's no
>> need to be counting cycles.
>
> Per Mans' advice, I have locally committed this patch:
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ether=
net/aurora/nb8800.c
> index ecc4a334c507..9f929be96b74 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -39,6 +39,13 @@
>
>  #include "nb8800.h"
>
> +#include <linux/version.h>
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(4,2,0)
> +#define skb_free_frag(data) put_page(page)
> +#else
> +#error DELETE ME NOW (see commit 181edb2bfa22)
> +#endif
> +
>  static void nb8800_tx_done(struct net_device *dev);
>  static int nb8800_dma_stop(struct net_device *dev);

That works only by accident due to how local variables are named.  If
you want a macro to emulate the new function, your first suggestion is
better.  I thought you were going to change the actual function.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
