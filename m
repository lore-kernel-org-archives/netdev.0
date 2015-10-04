From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Sun, 04 Oct 2015 18:41:56 +0100
Message-ID: <87bncejztn.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<CA+rthh9FMUHfaMcMXxJrsu+47xtQhG4ajmL_6rbJsAM1SRxGYw@mail.gmail.com>
	<87twq7ans7.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Krause <minipli@googlemail.com>,
	Jason Baron <jbaron@akamai.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Peter Zijlstra <peterz@infradead.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twq7ans7.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sat, 03 Oct 2015 18:02:16 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:

> Mathias Krause <minipli@googlemail.com> writes:
>> On 2 October 2015 at 22:43, Jason Baron <jbaron@akamai.com> wrote:
>>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>>> queue associated with the socket s that we are poll'ing against, but also calls
>
> [useless full-quote removed]
>
>> My reproducer runs on this patch for more than 3 days now without
>> triggering anything anymore.
>
> Since the behaviour of your program is random, using it to "test"
> anything doesn't really provide any insight: It could have been
> executing the same codepath which doesn't happen to trigger any problems
> for all of these three days. Nobody can tell.

Since this "strangely" seems to have been lost in the thread: Here's the
test program showing that the reconnect while in epoll actually causes a
problem (at least I think so):

--------
#include <fcntl.h>
#include <pthread.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/epoll.h>
#include <signal.h>
#include <unistd.h>

static int sk, tg0, tg1;

static void *epoller(void *unused)
{
    struct epoll_event epev;
    int epfd;
    
    epfd = epoll_create(1);
    if (epfd == -1) exit(0);

    epev.events = EPOLLOUT;
    epoll_ctl(epfd, EPOLL_CTL_ADD, sk, &epev);
    epoll_wait(epfd, &epev, 1, 5000);

    close(sk);

    execl("./a.out", "./a.out", (void *)0);

    return NULL;
}

int main(void)
{
    struct sockaddr_un sun;
    pthread_t tid;
    int rc;

    sun.sun_family = AF_UNIX;
    
    tg0 = socket(AF_UNIX, SOCK_DGRAM, 0);
    strncpy(sun.sun_path, "/tmp/tg0", sizeof(sun.sun_path));
    unlink(sun.sun_path);
    bind(tg0, (struct sockaddr *)&sun, sizeof(sun));
    
    tg1 = socket(AF_UNIX, SOCK_DGRAM, 0);
    strncpy(sun.sun_path, "/tmp/tg1", sizeof(sun.sun_path));
    unlink(sun.sun_path);
    bind(tg1, (struct sockaddr *)&sun, sizeof(sun));

    sk = socket(AF_UNIX, SOCK_DGRAM, 0);
    connect(sk, (struct sockaddr *)&sun, sizeof(sun));

    fcntl(sk, F_SETFL, fcntl(sk, F_GETFL) | O_NONBLOCK);
    
    while ((rc = write(sk, "bla", 3)) != -1);

    pthread_create(&tid, NULL, epoller, NULL);

    usleep(5);

    strncpy(sun.sun_path, "/tmp/tg0", sizeof(sun.sun_path));
    connect(sk, (struct sockaddr *)&sun, sizeof(sun));
    close(tg1);
    
    pause();

    return 0;
}
----------

And here the other demonstrating the poller not being woken up despite
it could write something:

----------
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/poll.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void)
{
    struct sockaddr_un sun;
    struct pollfd pfd;
    int tg, sk0, sk1, rc;
    char buf[16];

    sun.sun_family = AF_UNIX;
    
    tg = socket(AF_UNIX, SOCK_DGRAM, 0);
    strncpy(sun.sun_path, "/tmp/tg", sizeof(sun.sun_path));
    unlink(sun.sun_path);
    bind(tg, (struct sockaddr *)&sun, sizeof(sun));
    
    sk0 = socket(AF_UNIX, SOCK_DGRAM, 0);
    connect(sk0, (struct sockaddr *)&sun, sizeof(sun));
    
    sk1 = socket(AF_UNIX, SOCK_DGRAM, 0);
    connect(sk1, (struct sockaddr *)&sun, sizeof(sun));

    fcntl(sk0, F_SETFL, fcntl(sk0, F_GETFL) | O_NONBLOCK);
    fcntl(sk1, F_SETFL, fcntl(sk1, F_GETFL) | O_NONBLOCK);
    
    while (write(sk0, "bla", 3) != -1);

    if (fork() == 0) {
	pfd.fd = sk1;
	pfd.events = POLLOUT;
	rc = poll(&pfd, 1, -1);

	_exit(0);
    }
    
    sleep(3);
    read(tg, buf, sizeof(buf));
    wait(&rc);

    return 0;
}
-----------
