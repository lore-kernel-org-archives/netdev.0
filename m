From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Fri, 05 Feb 2016 22:04:02 +0000
Message-ID: <877fiiddbh.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87r3grapyx.fsf@doppelsaurus.mobileactivedefense.com>
	<56B500B5.9090700@canonical.com>
	<87egcqsvoz.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	hannes@stressinduktion.org,
	"davem\@davemloft.net" <davem@davemloft.net>, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87egcqsvoz.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Fri, 05 Feb 2016 21:18:04 +0000")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Joseph Salisbury <joseph.salisbury@canonical.com> writes:
>> On 02/05/2016 02:59 PM, Rainer Weikusat wrote:
>
> [recvmsg w/o iovecs returning ENOTSUP for CMSG requests]

[...]

> There are more problems wrt handling control-message only reads in this
> code.

[...]

> it will return without an error but also without credentials if the

[...]

> because the following
>
> mutex_lock(&u->readlock);
> continue;
>
> will cause the
>
> do {
> } while (size)
>
> loop condition to be evaluated and since size is 0 (AIUI), the loop will
> terminate immediately.

As I suspected, the test program included below doesn't really receive
the credentials (tested with a 4.5.0-rc2-net w/ the previous patch
applied). As that's a minor, additional problem, I'll fix that, too.

---
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
	send(socket_fd[client], msg, sizeof msg, MSG_DONTWAIT | MSG_NOSIGNAL);

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

    if (recvmsg(socket_fd[server], &msgh, MSG_PEEK) == -1)
    {
        printf("Error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    else
    {
	struct ucred *ucred;
	
        printf("Success?\n");

	ucred = (void *)CMSG_DATA(&control_un.cmh);
	printf("...  pid %ld, uid %d, gid %d\n",
	       (long)ucred->pid, ucred->uid, ucred->gid);
    }

    return 0;
}
