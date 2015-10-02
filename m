From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: fix use-after-free with unix_dgram_poll()
Date: Fri, 02 Oct 2015 20:49:21 +0100
Message-ID: <87io6pt5j2.fsf@doppelsaurus.mobileactivedefense.com>
References: <20151002191039.9124420ED@prod-mail-relay10.akamai.com>
	<871tdd3w5s.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	rweikusat@mobileactivedefense.com, viro@zeniv.linux.org.uk,
	davidel@xmailserver.org, dave@stgolabs.net, olivier@mauras.ch,
	pageexec@freemail.hu, torvalds@linux-foundation.org,
	peterz@infradead.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:57472 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbbJBTuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 15:50:09 -0400
In-Reply-To: <871tdd3w5s.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Fri, 02 Oct 2015 20:30:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Jason Baron <jbaron@akamai.com> writes:
>> From: Jason Baron <jbaron@akamai.com>
>>
>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>> queue associated with the socket s that we've called poll() on, but it also
>> calls sock_poll_wait() for a remote peer socket's wait queue, if it's connected.
>> Thus, if we call poll()/select()/epoll() for the socket s, there are then
>> a couple of code paths in which the remote peer socket s2 and its associated
>> peer_wait queue can be freed before poll()/select()/epoll() have a chance
>> to remove themselves from this remote peer socket s2's wait queue.
>
> [...]
>
>> This works because we will continue to get POLLOUT wakeups from
>> unix_write_space(), which is called via sock_wfree().
>
> As pointed out in my original comment, this doesn't work (as far as I
> can/ could tell) because it will only wake up sockets which had a chance
> to enqueue datagrams to the queue of the receiving socket as only
> skbuffs enqueued there will be consumed. A socket which is really
> waiting for space in the receiving queue won't ever be woken up in this
> way.

Program which shows that (on 3.2.54 + "local modification", with the 2nd
sock_poll_wait commented out):

---------------
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
------------

For me, this blocks forever while it should terminate as soon as the
datagram was read. Something else may have changed this behaviour in the
meantime, though.
