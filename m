From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close
 connection
Date: Thu, 26 Aug 2010 02:24:46 +0100
Message-ID: <1282785886.22839.199.camel@localhost>
References: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
	 <20100825.153424.246521475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100825.153424.246521475.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-08-25 at 15:34 -0700, David Miller wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 25 Aug 2010 11:05:48 +0900 (JST)
> 
> > This issue come from ruby language community. Below test program
> > hang up when only run on Linux.
> > 
> > 	% uname -mrsv
> > 	Linux 2.6.26-2-486 #1 Sat Dec 26 08:37:39 UTC 2009 i686
> > 	% ruby -rsocket -ve '
> > 	BasicSocket.do_not_reverse_lookup = true
> > 	serv = TCPServer.open("127.0.0.1", 0)
> > 	s1 = TCPSocket.open("127.0.0.1", serv.addr[1])
> > 	s2 = serv.accept
> > 	s2.close
> > 	s1.write("a") rescue p $!
> > 	s1.write("a") rescue p $!
> > 	Thread.new {
> > 	  s1.write("a")
> > 	}.join'
> > 	ruby 1.9.3dev (2010-07-06 trunk 28554) [i686-linux]
> > 	#<Errno::EPIPE: Broken pipe>
> > 	[Hang Here]
[...]
> And in this case here, I call into question the behavior of Ruby and
> the application from two perspectives:
> 
> 1) Unlike all of the other conditions signalled by poll() this is
>    one the application explicitly created and therefore knows about.
>
>    If the application calls close() or shutdown() with the send flag
>    set, IT KNOWS what is going to happen on a write() attempt.
[...]

This example seems to have both server (serv, s2) and client (s1) in the
same process for simplicity.  The server socket (s2) is closed and the
client cannot be expected to know that.  Of course the client ought to
drop the connection after the first EPIPE, but it's reasonable to expect
that this is a sticky condition just as it would be for a pipe.

Here's a similar test case in C:

#include <assert.h>
#include <signal.h>
#include <stdio.h>

#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

int main(void)
{
    struct sockaddr sa;
    struct timeval tv;
    int serv, s1, s2;
    socklen_t len;
    fd_set fds;

    signal(SIGPIPE, SIG_IGN);

    serv = socket(AF_INET, SOCK_STREAM, 0);
    assert(serv >= 0);
    assert(!listen(serv, 1));
    len = sizeof(sa);
    assert(!getsockname(serv, &sa, &len));

    s1 = socket(AF_INET, SOCK_STREAM, 0);
    assert(s1 >= 0);
    assert(!connect(s1, &sa, len));
    len = sizeof(sa);

    s2 = accept(serv, &sa, &len);
    assert(s2 >= 0);
    close(s2);

    for (;;) {
	printf("write: %d\n", write(s1, "a", 1));
	FD_ZERO(&fds);
	FD_SET(s1, &fds);
	tv.tv_sec = 1;
	tv.tv_usec = 0;
	printf("select: %d\n", select(s1 + 1, NULL, &fds, NULL, &tv));
    }
    return 0;
}

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
