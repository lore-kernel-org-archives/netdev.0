From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: https://patchwork.ozlabs.org/patch/579654?
Date: Tue, 16 Feb 2016 20:09:20 +0000
Message-ID: <87bn7gv2mn.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://patchwork.ozlabs.org/patch/579654

lists this as 'superseded', among with the older versions of the patch
which changed the error handling. But at least, I couldn't find anything
superseding it. This was supposed to address the different-but-related
problem demonstrated by the following (slightly modified) test program:

---------
#define _GNU_SOURCE
    
#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

int main(void)
{
    enum { server, client, size };
    int socket_fd[size];
    int const opt = 1;

    assert(socketpair(AF_LOCAL, SOCK_STREAM, 0, socket_fd) == 0);
    assert(setsockopt(socket_fd[server], SOL_SOCKET, SO_PASSCRED, &opt, sizeof(opt)) != -1);

    char const msg[] = "A random message";

    if (fork() == 0) {
	sleep(1);
	send(socket_fd[client], msg, sizeof msg, 0);

	_exit(0);
    }

    union {
        struct cmsghdr cmh;
        char control[CMSG_SPACE(sizeof(struct ucred))];
    } control_un;

    control_un.cmh.cmsg_len = CMSG_LEN(sizeof(struct ucred));
    control_un.cmh.cmsg_level = SOL_SOCKET;
    control_un.cmh.cmsg_type = SCM_CREDENTIALS;

    struct msghdr msgh;
    msgh.msg_name = NULL;
    msgh.msg_namelen = 0;
    msgh.msg_iov = NULL;
    msgh.msg_iovlen = 0;
    msgh.msg_control = control_un.control;
    msgh.msg_controllen = sizeof(control_un.control);

    recvmsg(socket_fd[server], &msgh, MSG_PEEK);
	
    printf("Success?\n");

    struct ucred *ucred;
    ucred = (void *)CMSG_DATA(&control_un.cmh);
    printf("...  pid %ld, uid %d, gid %d\n",
	   (long)ucred->pid, ucred->uid, ucred->gid);
    
    return 0;
}
--------

Because the receiver has to wait for the message, it will hit the
continue in unix_stream_read_generic. This causes the size-check of the
do-while loop to be executed which terminates the loop as the size is
zero without copying the credential information.

Just wondering if this might have been lost in the noise ...
