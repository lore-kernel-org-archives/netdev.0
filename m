From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: recent -git: BUG in free_thread_xstate
Date: Thu, 24 Jul 2008 01:20:32 +0200
Message-ID: <19f34abd0807231620q6d870bc0k74d176c9e5253ff3@mail.gmail.com>
References: <19f34abd0807231307y191c0ad7tfab4cda57ee88eb@mail.gmail.com>
	 <20080723203109.GH14380@linux-os.sc.intel.com>
	 <19f34abd0807231352j1ba1414am84ee9683df9b5657@mail.gmail.com>
	 <b647ffbd0807231422w546e59e9p8362ee798b169a25@mail.gmail.com>
	 <b647ffbd0807231435h73740808p76143d3d4457b597@mail.gmail.com>
	 <19f34abd0807231445h79fac5cbwecd0563b74bc18ad@mail.gmail.com>
	 <b647ffbd0807231501va30f6d4kee49d1daa30227fc@mail.gmail.com>
	 <19f34abd0807231505w1a25c2bak329a622f3a287e97@mail.gmail.com>
	 <19f34abd0807231545u5bc8b55fm768527a02268f111@mail.gmail.com>
	 <19f34abd0807231550h4ba88a9qa27b1c9e5afc80cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Suresh Siddha" <suresh.b.siddha@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	"Matt Mackall" <mpm@selenic.com>
To: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:32145 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbYGWXUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:20:34 -0400
Received: by py-out-1112.google.com with SMTP id p76so1908015pyb.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 16:20:33 -0700 (PDT)
In-Reply-To: <19f34abd0807231550h4ba88a9qa27b1c9e5afc80cb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 12:50 AM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> On Thu, Jul 24, 2008 at 12:45 AM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
>> Hey, with this patch applied:
>>
>> diff --git a/include/asm-x86/string_32.h b/include/asm-x86/string_32.h
>> index b49369a..7bef7ea 100644
>> --- a/include/asm-x86/string_32.h
>> +++ b/include/asm-x86/string_32.h
>> @@ -29,9 +29,14 @@ extern char *strchr(const char *s, int c);
>>  #define __HAVE_ARCH_STRLEN
>>  extern size_t strlen(const char *s);
>>
>> +extern void warn_on_slowpath(const char *file, int line);
>> +
>>  static __always_inline void * __memcpy(void * to, const void * from, size_t n)
>>  {
>>  int d0, d1, d2;
>> +       if (n == 0x6b)
>> +               warn_on_slowpath(__FILE__, __LINE__);
>> +
>>  __asm__ __volatile__(
>>        "rep ; movsl\n\t"
>>        "movl %4,%%ecx\n\t"
>>
>> I have found an important clue; it seems to be my network driver's fault:
>>
>> ------------[ cut here ]------------
>> WARNING: at include2/asm/string_32.h:38 skb_copy_and_csum_dev+0xee/0x100()
>> Pid: 3989, comm: bash Tainted: G        W 2.6.26-dirty #3
>>  [<c013496f>] warn_on_slowpath+0x4f/0x70
>>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>>  [<c04a8544>] ? __kfree_skb+0x34/0x80
>>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>>  [<c01983ef>] ? check_object+0xdf/0x1f0
>>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>>  [<c04a8544>] ? __kfree_skb+0x34/0x80
>>  [<c01983ef>] ? check_object+0xdf/0x1f0
>>  [<c04bbafc>] ? find_skb+0x3c/0x80
>>  [<c04a9f7e>] skb_copy_and_csum_dev+0xee/0x100
>>  [<c03539d7>] rtl8139_start_xmit+0x57/0x130
>>  [<c019a84b>] ? __kmalloc_track_caller+0x8b/0x120
>>  [<c04bba6e>] netpoll_send_skb+0x14e/0x1a0
>>  [<c04bbf54>] netpoll_send_udp+0x1e4/0x210
>>  [<c0374b0c>] write_msg+0x8c/0xc0
>>  [<c0135053>] __call_console_drivers+0x53/0x60
>>  [<c01350ab>] _call_console_drivers+0x4b/0x90
>>  [<c01351f5>] release_console_sem+0xc5/0x1f0
>>  [<c01357fe>] vprintk+0x2ce/0x420
>>  [<c0107e7d>] ? do_IRQ+0x4d/0xa0
>>  [<c0104de5>] ? restore_nocheck+0x12/0x15
>>  [<c0286ae1>] ? delay_tsc+0x61/0xb8
>>  [<c0286b06>] ? delay_tsc+0x86/0xb8
>>  [<c013596b>] printk+0x1b/0x20
>>  [<c0580d5d>] native_cpu_up+0x7cd/0x880
>>  [<c01df741>] ? internal_create_group+0xd1/0x180
>>  [<c0580470>] ? do_fork_idle+0x0/0x20
>>  [<c014d7c9>] ? __raw_notifier_call_chain+0x19/0x20
>>  [<c05826f3>] _cpu_up+0x83/0x100
>>  [<c05827b9>] cpu_up+0x49/0x70
>>  [<c05635d8>] store_online+0x58/0x80
>>  [<c0563580>] ? store_online+0x0/0x80
>>  [<c02fda2b>] sysdev_store+0x2b/0x40
>>  [<c01dd7b2>] sysfs_write_file+0xa2/0x100
>>  [<c019f156>] vfs_write+0x96/0x130
>>  [<c01dd710>] ? sysfs_write_file+0x0/0x100
>>  [<c019f81d>] sys_write+0x3d/0x70
>>  [<c0104cdb>] sysenter_past_esp+0x78/0xd1
>>  =======================
>> ---[ end trace a7919e7f17c0a725 ]---
>>
>> In particular, these are interesting:
>>
>>  [<c04a9f7e>] skb_copy_and_csum_dev+0xee/0x100
>>
>> This is net/core/skbuff.c:1731:
>>        skb_copy_from_linear_data(skb, to, csstart);
>>
>>  [<c03539d7>] rtl8139_start_xmit+0x57/0x130
>>
>> This is drivers/net/8139too.c:1711:
>>                dev_kfree_skb(skb);
>>
>
> Oops, this should of course be the line just above (because the
> address on the stack is the return address...), which is:
>
>                skb_copy_and_csum_dev(skb, tp->tx_buf[entry]);
>
> (Big surprise there ;-))
>
>> (The line numbers are still from v2.6.26, but this reproduces on
>> current -git as well.)
>>
>> Is this enough information to fix it? :-)
>
> I've also added Jeff Garzik to Cc since he seems to be the maintainer
> of this driver.

Hm. I'm not sure it's the driver's fault after all.

Look at the skb_copy_and_csum_dev() line again:

        skb_copy_from_linear_data(skb, to, csstart);

And csstart was probably loaded in this line:

                csstart = skb_headlen(skb);

Which makes sense if "skb" was freed (that's the case where "csstart"
would be 0x6b). Hm, looking at skb_headlen():

static inline unsigned int skb_headlen(const struct sk_buff *skb)
{
        return skb->len - skb->data_len;
}

It seems difficult for this to return 0x6b unless skb->data_len has
been set to 0 after it was freed.

In either case, rtl_8139_start_xmit() is only passing on the skb it
got from netpoll_send_skb(). The call is from net/core/netpoll.c:290:

        status = dev->hard_start_xmit(skb, dev);

Looks like the skb is passed into this as well... netpoll_send_skb(), line 370:

        netpoll_send_skb(np, skb);

So finally, this function is doing lots of stuff with skbs which I
have no idea what is. Seems like this one is getting an already freed
skbuff. Somehow. Or maybe it's freed while it's handling it.

Hm, seems to be no recent changes in this area. Maybe I'm on the
completely wrong track. I'll add a couple of Cc in either case.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
