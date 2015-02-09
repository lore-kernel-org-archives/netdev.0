From: Chen Gang S <gang.chen@sunrus.com.cn>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Mon, 09 Feb 2015 11:46:05 +0800
Message-ID: <54D82D7D.3000308@sunrus.com.cn>
References: <54D61229.9010904@sunrus.com.cn> <1423338774.2933.9.camel@perches.com> <54D6A729.1070905@sunrus.com.cn> <54D75698.7010808@sunrus.com.cn> <BD721CC9-DD4D-480D-98E6-89CA868BA285@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BD721CC9-DD4D-480D-98E6-89CA868BA285@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/9/15 04:17, Marcel Holtmann wrote:
> Hi Chen,
> 
>>>>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>>>>> be constant, or may cause build warning. The related warning (with
>>>>> allmodconfig under xtensa):
>>>>>
>>>>>  net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
>>>>>  net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
>>>>>          &hci_sec_filter.ocf_mask[ogf])) &&
>>>>>          ^
>>>>>  net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
>>>>>   static inline int hci_test_bit(int nr, void *addr)
>>>>>                     ^
>>>>>
>>>>> hci_test_bit() always treats 2nd parameter is u32, and all callers also
>>>>> know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
>>>>> instead of 'void *'.
>>>>>
>>>>> C language treats the array function parameter as a pointer, so the
>>>>> caller need not use '&' for the 2 demotion array, or it reports warning:
>>>>> 'const unsigned int (*)[4]' is different with 'const unsigned int *'.
>>>>
>>>> I still think you are possibly papering over potential bugs
>>>> on big-endian 64 bit systems.
>>>>
>>>> unsigned long vs u32.
>>>>
>>>> How are the bits actually set?
>>>>
>>>
>>>> From current usage of event_mask, "(u32 *) f->event_mask" is only for
>>> event_mask data storage, not for calculation (always as "u32 *" for
>>> calculation).
>>>
>>>  [root@localhost linux-next]# grep -rn "\<event_mask\>" include/net/bluetooth net/bluetooth
>>>  include/net/bluetooth/hci_sock.h:51:	unsigned long event_mask[2];
>>
>> e.g. use "unsigned char event_mask[2 * sizeof(unsigned long)]" instead
>> of "unsigned long event_mask[2]".
>>
>> There is still no any issue within "hci_sock.c" (although I am not sure
>> whether this modification may cause issues in another modules outside
>> kernel).
> 
> what about writing a test case for userspace that ensures that things are working correctly. As I said before, we left it this way since it is part of the API.
>

If it is really the API which can be used outside kernel, what you said
sounds reasonable to me. But I guess, except the related orgnizations/
company/members, most of kernel members can not give a suitable test:

 - It is an API, but we only know kernel part implementation, and we
   also know that the kernel part implementation intends to use
   "unsigned long event_mask[2]" and "u32 *" type cast.

 - We don't know the other part implementation (we event don't know
   whether it is open source). And also it is out of most of kernel
   members' current border (e.g. me).

 - If the other part implementation match what kernel part has done, it
   is OK, else it should cause issue.

So at present, in kernel part, we can only say the original authors
intended to do like this. And only within kernel part, it can not cause
issue. I guess, original authors originally knew what we talk about.

This patch is for fixing building warnings without any negative effect.
And most of us are not the suitable members to continue analyzing. So
at present, for me, we can accept this patch.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
