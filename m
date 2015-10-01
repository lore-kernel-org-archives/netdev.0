From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Thu, 01 Oct 2015 13:58:42 +0100
Message-ID: <87y4fm4uf1.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	<560C9CFE.6090509@akamai.com>
	<87oagiho88.fsf@doppelsaurus.mobileactivedefense.com>
	<87bnciiybf.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz\@infradead.org" <peterz@infradead.org>,
	"davem\@davemloft.net" <davem@davemloft.net>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bnciiybf.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Thu, 01 Oct 2015 13:10:44 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
>> Jason Baron <jbaron@akamai.com> writes:
>>> On 09/30/2015 01:54 AM, Mathias Krause wrote:
>>>> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>>>>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>>>>> drop the reference on the original socket 'o'. Thus, we can now close socket
>>>>> 'o' without unregistering from epoll. Then, when we either close the ep
>>>>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>>>>> race per se, but can be triggered sequentially.

[...]


> Test program (assumes that it can execute itself as ./a.out):
>
> -------------
> #include <fcntl.h>
> #include <pthread.h>
> #include <string.h>
> #include <sys/socket.h>
> #include <sys/un.h>
> #include <sys/epoll.h>
> #include <signal.h>
> #include <unistd.h>
>
> static int sk;
>
> static void *epoller(void *unused)
> {
>     struct epoll_event epev;
>     int epfd;
>     
>     epfd = epoll_create(1);
>
>     epev.events = EPOLLOUT;
>     epoll_ctl(epfd, EPOLL_CTL_ADD, sk, &epev);
>     epoll_wait(epfd, &epev, 1, 5000);
>
>     execl("./a.out", "./a.out", (void *)0);
>
>     return NULL;
> }

[...]

Possibly interesting additional bit of information: The list corruption
warnings appear only if the 2nd connect is there and both the sk and
epfd file descriptors are left open accross the exec. Closing either of
both still triggers the _destructor warnings but nothing else (until the
process runs out of file descriptors).
