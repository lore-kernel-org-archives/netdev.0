From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 09:13:20 -0800
Message-ID: <1358874800.3464.4002.camel@edumazet-glaptop>
References: <20130122161038.GG4608@sociomantic.com>
	 <1358873142.3464.3964.camel@edumazet-glaptop>
	 <20130122165929.GH4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122165929.GH4608@sociomantic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-22 at 17:59 +0100, Leandro Lucarella wrote:

> What I'm seeing are clients taking either useconds to connect, or 3
> seconds, which suggest SYNs are getting lost, but the network doesn't
> seem to be the problem. I'm still investigating this, so unfortunately
> I'm not really sure.
> 

A SYN packet or a SYN-ACK packet can be lost in the network.

> > A serious rewrite of LISTEN code is needed, because the current
> > implementation doesn't scale :
> > 
> > The SYNACK retransmits are done by a single timer wheel, holding the
> > socket lock for too long. So increasing the backlog to 2^16 or 2^17 is
> > not really an option.
> > 
> > Hash table are nice, but if we have to scan them, holding a single lock,
> > they are not so nice.
> 
> So, the queue is really a hash table, then? So using any (2^n)-1 would
> be a bad idea because when the backlog is next to full, the hash table
> will be really slow? Is that why the + 1 is there? Is assuming everyone
> will use a power of 2 an thus having a load factor of 0.5 at most?
> 

The kind of hash tables we use are power of two.

The size of hash table has little effect, its automatic, to try to get
an average of one item per hash slot, or less. Even if we had 10 items
per slot, it would not be a big deal.

What is important is the backlog, and I guess you didn't increase it
properly. The somaxconn default is quite low (128)

# sysctl -w net/ipv4/tcp_max_syn_backlog=4096
net.ipv4.tcp_max_syn_backlog = 4096
# sysctl -w net.core.somaxconn=4096
net.core.somaxconn = 4096

Then make sure your server use a big enough listen(..., backlog)
parameter.
