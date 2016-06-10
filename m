From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Fri, 10 Jun 2016 08:31:08 -0700
Message-ID: <1465572668.7945.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
	 <1465507031.7945.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4D4981@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4D4981@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-06-10 at 14:29 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 09 June 2016 22:17
> > On Thu, 2016-06-09 at 23:50 +0300, Saeed Mahameed wrote:
> > > From: Matthew Finlay <matt@mellanox.com>
> > 
> > 
> > > diff --git a/net/socket.c b/net/socket.c
> > > index a1bd161..67de200 100644
> > > --- a/net/socket.c
> > > +++ b/net/socket.c
> > > @@ -382,6 +382,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
> > >  	}
> > >
> > >  	sock->file = file;
> > > +	file->f_owner.sock_pid  = find_get_pid(task_pid_nr(current));
> > >  	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
> > >  	file->private_data = sock;
> > >  	return file;
> > 
> > Wow, that is a serious memory leak weapon (of struct pid)
> > 
> > Why don't you store the pid value, instead of a pointer ?
> 
> Since the numeric 'pid' values can be reused (with no grace time) you'd
> need to hold a reference to the pid structure (added in about 2.6.27) instead.
> Which is just a smaller memory leak!

Smaller than what ?


I fail to see how keeping a reference on the pid structure of the
process who created a socket can be useful, other than some optional
LSM.

A socket can be given via af_unix to another process.

Original process might have died.

Keeping a ref on the pid wont prevent this.

So the 'pid' here looks as a pure hint/info. Better store it directly
and avoid all the ref counting and indirection games that are going to
slow down nfnetlink quite a lot with all these extra cache line misses
and locks.



