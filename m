From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 02:26:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003092617.GI42593@gaz.sfgoth.com>
References: <3F7C6F3B.6070502@sgi.com> <20031002125625.72b8c0a7.shemminger@osdl.org> <20031003004133.3148c39a.davem@redhat.com> <20031003082642.GF42593@gaz.sfgoth.com> <20031003012754.23de3f66.davem@redhat.com> <20031003084847.GH42593@gaz.sfgoth.com> <20031003015220.7ee6e451.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003015220.7ee6e451.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> There is the weird issue (with both the sparc64 example and your's
> here) of whether we should care about what happens when settimeofday()
> occurs.  We probably shouldn't worry about it... as it gives weird
> results even currently.

Nah.  If anything you'll get better results since you're computing
the timeval later.

This is another argument for caching the computation though - otherwise
a settimeofday() could cause the packet timestamp to change drasically
from one observation to the next :-)

> > The worst case of
> > doing a cross-cpu-call should only happen relatively rarely.
> 
> No, they typically won't.  The packet comes in on cpu X, we stamp
> it on X, and we do a wakeup of tcpdump which will typically get
> scheduled first onto some other processor before X is done processing
> incoming packets.  The higher the packet load the more likely this will
> happen.

I was more thinking about the other timestamp users.  I don't consider
tcpdump something that needs as much optimization.  If we really wanted
to we could have set a per-interface flag that says "someone will want
the timestamp so compute it in the bh while we're still on the same
processor"  But see below - there probably isn't much cost anyways...

> This is mainly a product
> of how often you intend to update the tsc+timeval thingy.

You could compute it relatively frequently and then only actually
copy it to the hot cacheline if its diverged significantly from whats
there.  This would make the writes almost never happen (maybe once a
minute)

-Mitch
