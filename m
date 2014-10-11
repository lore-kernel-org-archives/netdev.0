From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [bisected] e341694e3eb5 netlink_lookup() rcu conversion causes
 latencies
Date: Sat, 11 Oct 2014 23:25:14 +0100
Message-ID: <20141011222514.GA14186@casper.infradead.org>
References: <20141011083627.GB5074@osiris>
 <1413055964.9362.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	paulmck@linux.vnet.ibm.com,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ursula Braun <braunu@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413055964.9362.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/14 at 12:32pm, Eric Dumazet wrote:
> On Sat, 2014-10-11 at 10:36 +0200, Heiko Carstens wrote:
> > Hi all,
> > 
> > it just came to my attention that commit e341694e3eb5
> > "netlink: Convert netlink_lookup() to use RCU protected hash table"
> > causes network latencies for me on s390.
> > 
> > The testcase is quite simple and 100% reproducible on s390:
> > 
> > Simply login via ssh to a remote system which has the above mentioned
> > patch applied. Any action like pressing return now has significant
> > latencies. Or in other words, working via such a connection becomes
> > a pain ;)
> > 
> > I haven't debugged it, however I assume the problem is that a) the
> > commit introduces a synchronize_net() call und b) s390 kernels
> > usually get compiled with CONFIG_HZ_100 while most other architectures
> > use CONFIG_HZ_1000.
> > If I change the kernel config to CONFIG_HZ_1000 the problem goes away,
> > however I don't consider this a fix...
> > 
> > Another reason why this hasn't been observed on x86 may or may not be
> > that we haven't implemented CONFIG_HAVE_CONTEXT_TRACKING on s390 (yet).
> > But that's just guessing...
> 
> CC Paul and Sasha

I think the issue here is obvious and a fix is on the way to move
the insertion and removal to a worker to no longer require the
synchronize_rcu().

What bothers me is that the synchronize_rcu() should only occur
on expand/shrink and not for every table update. The default table
size is 64.
