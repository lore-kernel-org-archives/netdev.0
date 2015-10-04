From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH net] ppp: don't override =?UTF-8?Q?sk-=3Esk=5Fstate=20?=
 =?UTF-8?Q?in=20pppoe=5Fflush=5Fdev=28=29?=
Date: Sun, 04 Oct 2015 19:08:52 +0300
Message-ID: <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Oleksii Berezhniak <core@irc.lg.ua>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39733 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbJDQI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 12:08:56 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 8CF5948052F
	for <netdev@vger.kernel.org>; Sun,  4 Oct 2015 19:08:53 +0300 (EEST)
In-Reply-To: <20151002175426.GE2911@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-02 20:54, Guillaume Nault wrote:
> On Fri, Oct 02, 2015 at 11:01:45AM +0300, Denys Fedoryshchenko wrote:
>> Here is similar panic after patch applied (it might be different bug), 
>> got
>> over netconsole:
>> 
>>  [126348.617115] CPU: 0 PID: 5254 Comm: accel-pppd Not tainted
>> 4.2.2-build-0087 #2
>>  [126348.617632] Hardware name: Intel Corporation S2600GZ/S2600GZ, 
>> BIOS
>> SE5C600.86B.02.03.0003.041920141333 04/19/2014
>>  [126348.618193] task: ffff8817cfbe0000 ti: ffff8817c6350000 task.ti:
>> ffff8817c6350000
>>  [126348.618696] RIP: 0010:[<ffffffffa00ea129>]
>>  [<ffffffffa00ea129>] pppoe_release+0x56/0x142 [pppoe]
>>  [126348.619306] RSP: 0018:ffff8817c6353e28  EFLAGS: 00010202
>>  [126348.619601] RAX: 0000000000000000 RBX: ffff8817a92b0400 RCX:
>> 0000000000000000
>>  [126348.620152] RDX: 0000000000000001 RSI: 00000000fffffe01 RDI:
>> ffffffff8180c18a
>>  [126348.620715] RBP: ffff8817c6353e68 R08: 0000000000000000 R09:
>> 0000000000000000
>>  [126348.621254] R10: ffff88173c02b210 R11: 0000000000000293 R12:
>> ffff8817b3c18000
>>  [126348.621784] R13: ffff8817b3c18030 R14: ffff8817967f1140 R15:
>> ffff8817d226c920
>>  [126348.622330] FS:  00007f9444db9700(0000) GS:ffff8817dee00000(0000)
>> knlGS:0000000000000000
>>  [126348.622876] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>  [126348.623202] CR2: 0000000000000428 CR3: 00000017c70b2000 CR4:
>> 00000000001406f0
>>  [126348.623760] Stack:
>>  [126348.624056]  0000000100200018
>>  0000000000000000
>>  0000000100000000
>>  ffff8817b3c18000
>> 
>>  [126348.624925]  ffffffffa00ec280
>>  ffff8817b3c18030
>>  ffff8817967f1140
>>  ffff8817d226c920
>> 
>>  [126348.625736]  ffff8817c6353e88
>>  ffffffff8180820a
>>  ffff88173c02b200
>>  0000000000000008
>> 
>>  [126348.626533] Call Trace:
>>  [126348.626873]  [<ffffffff8180820a>] sock_release+0x1a/0x70
>>  [126348.627183]  [<ffffffff8180826d>] sock_close+0xd/0x11
>>  [126348.627512]  [<ffffffff81152c61>] __fput+0xdf/0x193
>>  [126348.627845]  [<ffffffff81152d43>] ____fput+0x9/0xb
>>  [126348.628169]  [<ffffffff810d098e>] task_work_run+0x78/0x8f
>>  [126348.628517]  [<ffffffff810038a9>] do_notify_resume+0x40/0x4e
>>  [126348.628837]  [<ffffffff818a5a0a>] int_signal+0x12/0x17
> 
> Ok, so there's another possibility for pppoe_release() to be called 
> while
> sk->sk_state is PPPOX_{CONNECTED,BOUND,ZOMBIE} but po->pppoe_dev is 
> NULL.
> 
> I'll check the code to see if I can find any race wrt. po->pppoe_dev
> and sk->sk_state settings.
> 
> In a previous message, you said you'd try reverting 287f3a943fef
> ("pppoe: Use workqueue to die properly when a PADT is received") and
> related patches. I guess "related patches" means 665a6cd809f4 ("pppoe:
> drop pppoe device in pppoe_unbind_sock_work"), right?.
> Did these reverts give any successful result?
> 
> BTW, please don't top-post.
I am doing just "dirty" patch like this, i cannot certainly remember if 
i was doing git reversal, because
it was a while when i spotted this bug. After that pppoe server is not 
rebooting.

diff -Naur linux-4.2.2-vanilla/drivers/net/ppp/pppoe.c 
linux-4.2.2-changed/drivers/net/ppp/pppoe.c
--- linux-4.2.2-vanilla/drivers/net/ppp/pppoe.c 2015-09-29 
20:38:27.000000000 +0300
+++ linux-4.2.2-changed/drivers/net/ppp/pppoe.c 2015-10-04 
19:05:55.697732991 +0300
@@ -519,7 +519,7 @@
                 }

                 bh_unlock_sock(sk);
-               if (!schedule_work(&po->proto.pppoe.padt_work))
+//             if (!schedule_work(&po->proto.pppoe.padt_work))
                         sock_put(sk);
         }

@@ -633,7 +633,7 @@

         lock_sock(sk);

-       INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
+//     INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);

         error = -EINVAL;
         if (sp->sa_protocol != PX_PROTO_OE)
