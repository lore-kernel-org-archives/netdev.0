From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next 2/4] switchdev: add fwd_mark generator helper
Date: Mon, 15 Jun 2015 17:09:13 +0300
Message-ID: <557EDC89.1040705@cogentembedded.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com> <1434218670-43821-3-git-send-email-sfeldma@gmail.com> <20150614065601.GB2105@nanopsycho.orion> <CAE4R7bA_N0YtoNEWrX7kO=PA3nWNc-nGL0Bcyt_1SmeX9PZs_g@mail.gmail.com> <20150615054638.GB2179@nanopsycho.orion> <CAE4R7bCABXELpMjqL1x1qyRy11JGmtMGZ6-Yo_5hXbWuFFF8_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	davidch <davidch@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:33323 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbbFOOJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:09:18 -0400
Received: by laka10 with SMTP id a10so11050174lak.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:09:16 -0700 (PDT)
In-Reply-To: <CAE4R7bCABXELpMjqL1x1qyRy11JGmtMGZ6-Yo_5hXbWuFFF8_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/15/2015 4:52 PM, Scott Feldman wrote:

>>>>> From: Scott Feldman <sfeldma@gmail.com>

>>>>> skb->fwd_mark and dev->fwd_mark are 32-bit and should be unique for device
>>>>> and maybe even unique for a sub-set of ports within device, so add
>>>>> switchdev helper function to generate unique marks based on driver-supplied
>>>>> key.  Typically, the driver would use device switch ID for key, and maybe
>>>>> additional fields in key for grouped ports such as bridge ifindex.  The key
>>>>> can be of arbitrary length.

>>>>> The generator uses a global hash table to store fwd_marks hashed by key.

>>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

>>> <snip>

>>>>> +u32 switchdev_mark_get(void *key, size_t key_len)
>>>>> +{
>>>>> +      struct switchdev_mark_ht_entry {
>>>>> +              struct hlist_node entry;
>>>>> +              void *key;
>>>>> +              size_t key_len;
>>>>> +              u32 key_crc32;
>>>>> +              u32 mark;
>>>>> +      } *entry;
>>>>> +      u32 key_crc32 = crc32(~0, key, key_len);
>>>>> +      u32 mark = 0;
>>>>> +      unsigned long flags;
>>>>> +
>>>>> +      spin_lock_irqsave(&switchdev_mark_lock, flags);

>>>> I fail to see why _irqsave variant is needed here.

>>> I don't know what context caller is in, so using most conservative
>>> spinlock.  Is there a better way?

>> I don't see why would someone call this from irq.

> Ok, good point, I'll adjust to spin_lock.

     I guess spi_lock_irq() is what you meant. Disabling IRQs when called from 
the hardirq context made no sense since hardirq handlrs are executed with IRQs 
disabled anyway.

WBR, Sergei
