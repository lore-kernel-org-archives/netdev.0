From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:01:13 +0100
Message-ID: <20041110010113.GJ31969@postel.suug.ch>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041109161126.376f755c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041109161126.376f755c.davem@davemloft.net> 2004-11-09 16:11
> On Sat, 06 Nov 2004 10:35:45 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 2) Hooking random net/sched requests into rtnetlink.  By being an
> > rtnetlink user you pay the price of taking the rtnl.  Most of the
> > net/sched stuff has nothing to do with rtnetlink.
> 
> I believe this is a false statement.  Every single networking
> config change depends upon device existence and state in some
> way.  By virtue of that, they really depend upon the RTNL being
> held during the duration of their execution.
> 
> Only the actual implementations know when and where such a
> dependency on device state et al. does not exist, and therefore
> where RTNL holding is not necessary.
> 
> Therefore I suggest we just implement the fix for this inside of
> the packet scheduler layer itself.  Simply by dropping the RTNL
> semaphore during the module request, and then regrabbing the RTNL
> semaphore and replaying the request from the beginning.

Sounds reasonable for the sch_api.c and cls_api.c case but
will get very nasty for act_api as you noted and any further sub
layers that might be added in the future. (The classifier I'm
working on is such a case.)

I suggest to add TCA_PRELOAD being an array of module names to
be preloaded so userspace can tell us what modules might be
needed. Those modules would get loaded at the same spot while
rtnl semaphore is dropped. I think the fix is fine for cls/qdisc
to fix it for older iproute2 versions but it might be worth
to make the action code use it right away.

Thoughts?
