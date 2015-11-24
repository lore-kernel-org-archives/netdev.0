From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: use-after-free in sock_wake_async
Date: Tue, 24 Nov 2015 21:40:36 +0000
Message-ID: <20151124214036.GP22011@ZenIV.linux.org.uk>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
 <5654D6D9.1050108@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5654D6D9.1050108@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 04:30:01PM -0500, Jason Baron wrote:

> So looking at this trace I think its the other->sk_socket that gets
> freed and then we call sk_wake_async() on it.
> 
> We could I think grab the socket reference there with unix_state_lock(),
> since that is held by unix_release_sock() before the final iput() is called.
> 
> So something like below might work (compile tested only):

Ewww...

> +struct socket *unix_peer_get_socket(struct sock *s)
> +{
> +	struct socket *peer;
> +
> +	unix_state_lock(s);
> +	peer = s->sk_socket;
> +	if (peer)
> +		__iget(SOCK_INODE(s->sk_socket));
> +	unix_state_unlock(s);
> +
> +	return peer;

>  out_err:
> +	if (other_socket)
> +		iput(SOCK_INODE(other_socket));
>  	scm_destroy(&scm);
>  	return sent ? : err;
>  }

Interplay between socket, file and inode lifetimes is already too convoluted,
and this just makes it nastier.  I don't have a ready solution at the moment,
but this one is too ugly to live.

Al, digging through RTFS(net/unix/af_unix.c) right now...
