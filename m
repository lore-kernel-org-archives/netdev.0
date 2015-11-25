From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v8] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 25 Nov 2015 08:12:28 -0800
Message-ID: <CAKgT0UdRB5DaZHc3PQDvPzePMcjASLxH2ew1zqM4ORc+P6DKNA@mail.gmail.com>
References: <1447938180-19651-1-git-send-email-mans@mansr.com>
	<5655AB63.40204@free.fr>
	<yw1x37vuqmcy.fsf@unicorn.mansr.com>
	<5655B0DF.8060000@free.fr>
	<yw1xy4dmp6vo.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mason <slash.tmp@free.fr>, Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32847 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbbKYQM3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:12:29 -0500
Received: by igcmv3 with SMTP id mv3so75582802igc.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 08:12:28 -0800 (PST)
In-Reply-To: <yw1xy4dmp6vo.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 5:04 AM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr.co=
m> wrote:
> Mason <slash.tmp@free.fr> writes:
>
>> On 25/11/2015 13:45, M=C3=A5ns Rullg=C3=A5rd wrote:
>>
>>> Mason wrote:
>>>
>>>> On 19/11/2015 14:02, Mans Rullgard wrote:
>>>>
>>>>> +  if (dma_mapping_error(&dev->dev, dma_addr)) {
>>>>> +          skb_free_frag(data);
>>>>> +          return -ENOMEM;
>>>>> +  }
>>>>
>>>> I'm back-porting this driver to 4.1
>>>>
>>>> skb_free_frag() was introduced in 4.2 by 181edb2bfa22b IIUC.
>>>>
>>>> +static inline void skb_free_frag(void *addr)
>>>> +{
>>>> +       __free_page_frag(addr);
>>>> +}
>>>>
>>>> Should I just copy the definition of __free_page_frag() ?
>>>
>>> Looks like it ought to work.  Try and find out.  Not that you'll ev=
er
>>> hit that error condition unless you fake it.
>>
>> Turns out __free_pages_ok() is static and I'd rather not touch
>> mm/page_alloc.c in my back-port.
>>
>> Since you say the error condition is rare, I think I'll go with
>> the code that 181edb2bfa22b replaced (put_page, IIUC).
>>
>> #include <linux/version.h>
>> #if LINUX_VERSION_CODE < KERNEL_VERSION(4,2,0)
>> #define skb_free_frag(data) put_page(virt_to_head_page(data))
>> #else
>> #error DELETE ME NOW (see commit 181edb2bfa22b)
>> #endif
>
> You can simply put_page(page) instead since we already have the
> virt_to_head_page() a few lines up.

What you could do is use __free_pages instead of __free_pages_ok.
Generally you will want to use __free_pages instead of put_page just
to avoid a bunch of unnecessary tests and function pointer accesses.

The result would look something like:
static inline void skb_free_frag(void *addr)
{
       struct page *page =3D virt_to_head_page(addr);

        __free_pages(page, compound_order(page));
}

Hope that helps.

- Alex
