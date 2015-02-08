From: Chen Gang S <gang.chen@sunrus.com.cn>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Sun, 08 Feb 2015 20:29:12 +0800
Message-ID: <54D75698.7010808@sunrus.com.cn>
References: <54D61229.9010904@sunrus.com.cn> <1423338774.2933.9.camel@perches.com> <54D6A729.1070905@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Marcel Holtmann <marcel@holtmann.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D6A729.1070905@sunrus.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/15 08:00, Chen Gang S wrote:
> On 2/8/15 03:52, Joe Perches wrote:
>> On Sat, 2015-02-07 at 21:24 +0800, Chen Gang S wrote:
>>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>>> be constant, or may cause build warning. The related warning (with
>>> allmodconfig under xtensa):
>>>
>>>   net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
>>>   net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
>>>           &hci_sec_filter.ocf_mask[ogf])) &&
>>>           ^
>>>   net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
>>>    static inline int hci_test_bit(int nr, void *addr)
>>>                      ^
>>>
>>> hci_test_bit() always treats 2nd parameter is u32, and all callers also
>>> know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
>>> instead of 'void *'.
>>>
>>> C language treats the array function parameter as a pointer, so the
>>> caller need not use '&' for the 2 demotion array, or it reports warning:
>>> 'const unsigned int (*)[4]' is different with 'const unsigned int *'.
>>
>> I still think you are possibly papering over potential bugs
>> on big-endian 64 bit systems.
>>
>> unsigned long vs u32.
>>
>> How are the bits actually set?
>>
> 
>>From current usage of event_mask, "(u32 *) f->event_mask" is only for
> event_mask data storage, not for calculation (always as "u32 *" for
> calculation).
> 
>   [root@localhost linux-next]# grep -rn "\<event_mask\>" include/net/bluetooth net/bluetooth
>   include/net/bluetooth/hci_sock.h:51:	unsigned long event_mask[2];

e.g. use "unsigned char event_mask[2 * sizeof(unsigned long)]" instead
of "unsigned long event_mask[2]".

There is still no any issue within "hci_sock.c" (although I am not sure
whether this modification may cause issues in another modules outside
kernel).


Thanks.

>   include/net/bluetooth/hci_sock.h:57:	__u32  event_mask[2];
>   net/bluetooth/hci_sock.c:59:	__u32 event_mask[2];
>   net/bluetooth/hci_sock.c:110:	if (!hci_test_bit(flt_event, (u32 *)&flt->event_mask))
>   net/bluetooth/hci_sock.c:1041:			uf.event_mask[0] = *((u32 *) f->event_mask + 0);
>   net/bluetooth/hci_sock.c:1042:			uf.event_mask[1] = *((u32 *) f->event_mask + 1);
>   net/bluetooth/hci_sock.c:1053:			uf.event_mask[0] &= *((u32 *) hci_sec_filter.event_mask + 0);
>   net/bluetooth/hci_sock.c:1054:			uf.event_mask[1] &= *((u32 *) hci_sec_filter.event_mask + 1);
>   net/bluetooth/hci_sock.c:1062:			*((u32 *) f->event_mask + 0) = uf.event_mask[0];
>   net/bluetooth/hci_sock.c:1063:			*((u32 *) f->event_mask + 1) = uf.event_mask[1];
>   net/bluetooth/hci_sock.c:1124:			uf.event_mask[0] = *((u32 *) f->event_mask + 0);
>   net/bluetooth/hci_sock.c:1125:			uf.event_mask[1] = *((u32 *) f->event_mask + 1);
> 
> Calculation is machine endian dependency, but event_mask is always as
> "u32 *" for calculation, so there is no any type cast for calculation,
> it is OK.
> 
> Storage is independent from machine endian, but it depends on machine
> bits. In our case, 'unsigned long' array has enough space to accept u32
> array, so there is no any data overwritten, it is OK.
> 
> 
> By the way, I intended to remain event_mask as 'unsigned long' type,
> because I am not quite sure whether it is also used by another modules
> in kernel (or any other systems). May we change it to u32?
> 
> Thanks.
> 

-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
