From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: do not set cb_running if dump's start() errs
Date: Mon, 09 Oct 2017 14:27:44 +0200
Message-ID: <1507552064.26041.50.camel@sipsolutions.net>
References: <20171009115648.25989-1-Jason@zx2c4.com>
         <1507550326.26041.39.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, davem@davemloft.net,
        Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507550326.26041.39.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just decided to take another look:

On Mon, 2017-10-09 at 13:58 +0200, Johannes Berg wrote:
> On Mon, 2017-10-09 at 13:56 +0200, Jason A. Donenfeld wrote:
> 
> > @@ -2266,16 +2266,17 @@ int __netlink_dump_start(struct sock *ssk,
> > struct sk_buff *skb,
> >  	cb->min_dump_alloc = control->min_dump_alloc;
> >  	cb->skb = skb;
> >  
> > +	if (cb->start) {
> > +		ret = cb->start(cb);
> > +		if (ret)
> > +			goto error_unlock;
> > +	}
> > +
> >  	nlk->cb_running = true;
> >  
> >  	mutex_unlock(nlk->cb_mutex);
> 
> Hmm. Now start is invoked with the mutex held, I'm not sure it
> actually _matters_, but that should probably be reviewed and
> mentioned in the commit log?

It sort of seems designed to run ->start outside the lock, otherwise we
wouldn't really have to acquire it again in netlink_dump() but could
just keep it across the call (with some locking changes in
netlink_recvmsg())?

Then again, clearly none of the (few) existing users actually care.

Btw - we should (separately) also remove "start" from struct
netlink_callback, it's only ever used within this function and we can
use control->start instead of cb->start here.

johannes
