From: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 17:59:29 +0100
Message-ID: <20130122165929.GH4608@sociomantic.com>
References: <20130122161038.GG4608@sociomantic.com>
 <1358873142.3464.3964.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:54842 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab3AVQ7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:59:34 -0500
Content-Disposition: inline
In-Reply-To: <1358873142.3464.3964.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 08:45:42AM -0800, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 17:10 +0100, Leandro Lucarella wrote:
> > Hi, I'm having some problems with missing SYNs in a server with a high
> > rate of incoming connections and, even when far from understanding the
> > kernel,  I ended up looking at the kernel's source to try to understand
> > better what's going on, because some stuff doesn't make a lot of sense
> > to me.
[snip]
> > 1. What's the relation between the socket backlog and the queue created
> >    by reqsk_queue_alloc()? Because the backlog is only adjusted not to
> >    be grater than sysctl_somaxconn, but the queue size can be quite
> >    different.
> > 2. The comment just above the definition of reqsk_queue_alloc() about
> >    sysctl_max_syn_backlog says "Maximum number of SYN_RECV sockets in
> >    queue per LISTEN socket.". But then nr_table_entries is not only
> >    rounded up to the next power of 2, is incremented by one before that,
> >    so a backlog of, for example, 128, would end up with 256 table
> >    entries even if sysctl_max_syn_backlog is 128.
> > 3. Why is there a nr_table_entries + 1 at all in there? Looking at the
> >    commit that introduced this[1] I can't find any explanation and I've
> >    read some big projects are using backlogs of 511 because of this[2].
> >    (which BTW, ff the queue is really a hash table, looks like an awful
> >    idea).
> > 4. I found some places sk->sk_ack_backlog is checked against
> >    sk->sk_max_ack_backlog to see if new requests should be dropped, but
> >    I also saw checks like inet_csk_reqsk_queue_young(sk) > 1 or
> >    inet_csk_reqsk_queue_is_full(sk), so I guess the queue is used too.
[snip]
> 
> What particular problem do you have ?

What I'm seeing are clients taking either useconds to connect, or 3
seconds, which suggest SYNs are getting lost, but the network doesn't
seem to be the problem. I'm still investigating this, so unfortunately
I'm not really sure.

> A serious rewrite of LISTEN code is needed, because the current
> implementation doesn't scale :
> 
> The SYNACK retransmits are done by a single timer wheel, holding the
> socket lock for too long. So increasing the backlog to 2^16 or 2^17 is
> not really an option.
> 
> Hash table are nice, but if we have to scan them, holding a single lock,
> they are not so nice.

So, the queue is really a hash table, then? So using any (2^n)-1 would
be a bad idea because when the backlog is next to full, the hash table
will be really slow? Is that why the + 1 is there? Is assuming everyone
will use a power of 2 an thus having a load factor of 0.5 at most?

-- 
Leandro Lucarella
Senior R&D Developer
-----------------------------------------------------------
sociomantic labs GmbH
Paul-Lincke-Ufer 39/40
10999 Berlin
DEUTSCHLAND
-----------------------------------------------------------
http://www.sociomantic.com
-----------------------------------------------------------
Fon:       +49 (0) 30 3087 4615
Fax:       +49 (0) 30 3087 4619
Mobile:    +49 (0)157 3636 7373
Skype:     llucarella
Twitter:   http://www.twitter.com/sociomantic
Facebook:  http://bit.ly/labsfacebook
-----------------------------------------------------------
sociomantic labs GmbH, Location: Berlin
Commercial Register - AG Charlottenburg: HRB 121302 B
VAT No. - USt-ID: DE 266262100
Managing Directors: Thomas Nicolai, Thomas Brandhoff
