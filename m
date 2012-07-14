From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: Crash in CIPSO_V4_TAG_LOCAL handling
Date: Sun, 15 Jul 2012 01:22:30 +0800
Message-ID: <1342286550.23395.12.camel@monkey32>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PV9j2t5FKoyDdscoygiI"
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:53849 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab2GNRXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 13:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PV9j2t5FKoyDdscoygiI
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On Sat, Jul 14, 2012 at 1:08 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> DaveM asked that this goes direct to the list so ...
>
> Looking at some static code analyser output and the results seem valid on
> this one:
>
> ip_options_compile called with skb = NULL and an IPOPT_CIPSO option calls
> into cipso_v4_validate, which if the option is CIPSO_V4_TAG_LOCAL then
> dereferences skb->dev and explodes.

Hi Alan,

I can trigger this oops with the attached simple program(cipso_test.c).

# netlabelctl cipsov4 add local doi:3
# ./cipso_test

It's caused by below code added in commit 15c45f7b.

                case CIPSO_V4_TAG_LOCAL:
                        /* This is a non-standard tag that we only allow for
                         * local connections, so if the incoming interface is
                         * not the loopback device drop the packet. */
                        if (!(skb->dev->flags & IFF_LOOPBACK)) {
                                err_offset = opt_iter;
                                goto validate_return_locked;
                        }

But I don't know how to check if it is loopback device
just after socket() syscall.

sockfd = socket(AF_INET, SOCK_DGRAM, 0);
setsockopt(sockfd, SOL_IP, IP_OPTIONS, &cipso, sizeof(struct cipso));

Obviously, at this time net_device is not assigned yet.
Any idea?

[  346.396250] BUG: unable to handle kernel NULL pointer dereference at 00000014
[  346.400024] IP: [<c171041b>] cipso_v4_validate+0x323/0x363
[  346.400024] *pdpt = 000000001efe4001 *pde = 0000000000000000 
[  346.400024] Oops: 0000 [#1] SMP 
[  346.400024] Modules linked in:
[  346.400024] 
[  346.400024] Pid: 2471, comm: cipso_test Not tainted 3.5.0-rc5-01438-gd322ef7 #28 Bochs Bochs
[  346.400024] EIP: 0060:[<c171041b>] EFLAGS: 00010246 CPU: 0
[  346.400024] EIP is at cipso_v4_validate+0x323/0x363
[  346.400024] EAX: 00000006 EBX: de77d4de ECX: 00000006 EDX: de77d380
[  346.400024] ESI: 00000000 EDI: 00000006 EBP: df61dcb8 ESP: df61dc5c
[  346.400024]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  346.400024] CR0: 8005003b CR2: 00000014 CR3: 1efac000 CR4: 000006b0
[  346.400024] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  346.400024] DR6: ffff0ff0 DR7: 00000400
[  346.400024] Process cipso_test (pid: 2471, ti=df61c000 task=df7f0530 task.ti=df61c000)
[  346.400024] Stack:
[  346.400024]  000000d0 00000040 df404600 de7debe0 0001cd2c df61dc8c 0000000c 0000001c
[  346.400024]  00000000 00000001 c1b2606c df61dc98 c12dfa20 df61dcf4 0c7f0530 de77d4d8
[  346.400024]  c106c380 06f73800 00000006 de77d398 de77d4c8 00000000 0000000c df61dd04
[  346.400024] Call Trace:
[  346.400024]  [<c12dfa20>] ? security_capable+0x1c/0x20
[  346.400024]  [<c106c380>] ? sys_sysctl+0x110/0x140
[  346.400024]  [<c16d2370>] ip_options_compile+0x3c4/0x423
[  346.400024]  [<c10f0999>] ? unlock_page+0x46/0x49
[  346.400024]  [<c110b5ef>] ? __do_fault+0x460/0x474
[  346.400024]  [<c16d1d57>] ? ip_options_get_alloc+0x1b/0x1d
[  346.400024]  [<c16d2401>] ip_options_get_finish+0x32/0x53
[  346.400024]  [<c16d24cf>] ip_options_get_from_user+0x5d/0x65
[  346.400024]  [<c16d5453>] do_ip_setsockopt+0xe3/0xa97
[  346.400024]  [<c105de56>] ? kmap_atomic_prot+0x110/0x112
[  346.400024]  [<c10f2f12>] ? zone_watermark_ok+0x30/0x37
[  346.400024]  [<c10f58e9>] ? get_page_from_freelist+0x38b/0x42c
[  346.400024]  [<c10ef736>] ? find_get_page+0x22/0x6d
[  346.400024]  [<c10f0d2f>] ? filemap_fault+0x7a/0x31a
[  346.400024]  [<c10f0999>] ? unlock_page+0x46/0x49
[  346.400024]  [<c110b5c7>] ? __do_fault+0x438/0x474
[  346.400024]  [<c1664565>] ? sk_prot_alloc+0x25/0xb8
[  346.400024]  [<c16645f8>] ? sk_prot_alloc+0xb8/0xb8
[  346.400024]  [<c16645c7>] ? sk_prot_alloc+0x87/0xb8
[  346.400024]  [<c12dfca1>] ? security_file_alloc+0x14/0x16
[  346.400024]  [<c11333c0>] ? get_empty_filp+0xfb/0x1cd
[  346.400024]  [<c16d5e31>] ip_setsockopt+0x2a/0x8c
[  346.400024]  [<c16ef873>] udp_setsockopt+0x42/0x49
[  346.400024]  [<c1662b91>] sock_common_setsockopt+0x23/0x29
[  346.400024]  [<c16613fa>] sys_setsockopt+0x6e/0x8a
[  346.400024]  [<c16627c4>] sys_socketcall+0x1fa/0x2bc
[  346.400024]  [<c1311ea0>] ? trace_hardirqs_on_thunk+0xc/0x10
[  346.400024]  [<c180f878>] sysenter_do_call+0x12/0x2d
[  346.400024] Code: 3b 4d ec 77 09 66 8b 74 0b 02 66 c1 c6 08 0f b7 ff 3b 7d e4 77 0d 0f b7 f6 89 75 e4 3b 4d ec 72 d1 eb 1d 83 c0 04 eb 2e 8b 75 c4 <8b> 4e 14 f6 81 e4 00 00 00 08 74 1f 80 7d eb 06 74 03 40 eb 16 
[  346.400024] EIP: [<c171041b>] cipso_v4_validate+0x323/0x363 SS:ESP 0068:df61dc5c


>
> All the other cases appear to correctly avoid or check it versus NULL
>
> Alan




--=-PV9j2t5FKoyDdscoygiI
Content-Disposition: attachment; filename="cipso_test.c"
Content-Type: text/x-csrc; name="cipso_test.c"; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

#include <sys/types.h>
#include <sys/socket.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <string.h>

struct local_tag {
	char type;
	char length;
	char info[4];
};

struct cipso {
	char type;
	char length;
	char doi[4];
	struct local_tag local;	
};

int main(int argc, char **argv)
{
	int sockfd;

	struct cipso cipso = {
		.type = IPOPT_CIPSO,
		.length = sizeof(struct cipso),
		.local = {
			.type = 128,
			.length = sizeof(struct local_tag),
		},
	};

	memset(cipso.doi, 0, 4);
	cipso.doi[3] = 3;

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);

	#define SOL_IP 0
	setsockopt(sockfd, SOL_IP, IP_OPTIONS, &cipso, sizeof(struct cipso));

	return 0;
}

--=-PV9j2t5FKoyDdscoygiI--
