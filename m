From: Chen Gang S <gang.chen-/B7AUNIrSHOPt1CcHtbs0g@public.gmane.org>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Sun, 08 Feb 2015 08:00:41 +0800
Message-ID: <54D6A729.1070905@sunrus.com.cn>
References: <54D61229.9010904@sunrus.com.cn> <1423338774.2933.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423338774.2933.9.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/8/15 03:52, Joe Perches wrote:
> On Sat, 2015-02-07 at 21:24 +0800, Chen Gang S wrote:
>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>> be constant, or may cause build warning. The related warning (with
>> allmodconfig under xtensa):
>>
>>   net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
>>   net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
>>           &hci_sec_filter.ocf_mask[ogf])) &&
>>           ^
>>   net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
>>    static inline int hci_test_bit(int nr, void *addr)
>>                      ^
>>
>> hci_test_bit() always treats 2nd parameter is u32, and all callers also
>> know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
>> instead of 'void *'.
>>
>> C language treats the array function parameter as a pointer, so the
>> caller need not use '&' for the 2 demotion array, or it reports warning:
>> 'const unsigned int (*)[4]' is different with 'const unsigned int *'.
> 
> I still think you are possibly papering over potential bugs
> on big-endian 64 bit systems.
> 
> unsigned long vs u32.
> 
> How are the bits actually set?
> 

>From current usage of event_mask, "(u32 *) f->event_mask" is only for
event_mask data storage, not for calculation (always as "u32 *" for
calculation).

  [root@localhost linux-next]# grep -rn "\<event_mask\>" include/net/bluetooth net/bluetooth
  include/net/bluetooth/hci_sock.h:51:	unsigned long event_mask[2];
  include/net/bluetooth/hci_sock.h:57:	__u32  event_mask[2];
  net/bluetooth/hci_sock.c:59:	__u32 event_mask[2];
  net/bluetooth/hci_sock.c:110:	if (!hci_test_bit(flt_event, (u32 *)&flt->event_mask))
  net/bluetooth/hci_sock.c:1041:			uf.event_mask[0] = *((u32 *) f->event_mask + 0);
  net/bluetooth/hci_sock.c:1042:			uf.event_mask[1] = *((u32 *) f->event_mask + 1);
  net/bluetooth/hci_sock.c:1053:			uf.event_mask[0] &= *((u32 *) hci_sec_filter.event_mask + 0);
  net/bluetooth/hci_sock.c:1054:			uf.event_mask[1] &= *((u32 *) hci_sec_filter.event_mask + 1);
  net/bluetooth/hci_sock.c:1062:			*((u32 *) f->event_mask + 0) = uf.event_mask[0];
  net/bluetooth/hci_sock.c:1063:			*((u32 *) f->event_mask + 1) = uf.event_mask[1];
  net/bluetooth/hci_sock.c:1124:			uf.event_mask[0] = *((u32 *) f->event_mask + 0);
  net/bluetooth/hci_sock.c:1125:			uf.event_mask[1] = *((u32 *) f->event_mask + 1);

Calculation is machine endian dependency, but event_mask is always as
"u32 *" for calculation, so there is no any type cast for calculation,
it is OK.

Storage is independent from machine endian, but it depends on machine
bits. In our case, 'unsigned long' array has enough space to accept u32
array, so there is no any data overwritten, it is OK.


By the way, I intended to remain event_mask as 'unsigned long' type,
because I am not quite sure whether it is also used by another modules
in kernel (or any other systems). May we change it to u32?

Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
