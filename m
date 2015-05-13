From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Wed, 13 May 2015 11:32:32 -0400
Message-ID: <20150513153232.GW11388@htj.duckdns.org>
References: <1431362494-9874-1-git-send-email-tj@kernel.org>
 <1431362494-9874-5-git-send-email-tj@kernel.org>
 <20150512163602.ba6c83e3056702cbd840edef@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150512163602.ba6c83e3056702cbd840edef@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Andrew.

On Tue, May 12, 2015 at 04:36:02PM -0700, Andrew Morton wrote:
> > printk recently added extended console support which can be selected
> > by setting CON_EXTENDED flag.
> 
> There's no such thing as CON_EXTENDED.  Not sure what this is trying to
> say.

Yeah, I ended up splitting the original patchset into two.  One
implementing CON_EXTENDED and this set updating netconsole to use it.
The patchset head message contains the link to the prerequisite
patchset.

 http://article.gmane.org/gmane.linux.kernel/1940567

> > +static ssize_t store_extended(struct netconsole_target *nt,
> > +			      const char *buf,
> > +			      size_t count)
> > +{
> > +	int extended;
> > +	int err;
> > +
> > +	if (nt->enabled) {
> > +		pr_err("target (%s) is enabled, disable to update parameters\n",
> > +		       config_item_name(&nt->item));
> > +		return -EINVAL;
> > +	}
> 
> What's the reason for the above?
> 
> It's unclear (to me, at least ;)) what "disable" means?  Specifically
> what steps must the operator take to successfully perform this
> operation?  A sentence detailing those steps in netconsole.txt would be
> nice.

So, there are configfs dynamic netconsole targets which is created by
mkdir, configured through interface files there and enabled by echoing
1 to the enable file.  The parameters can't be changed while the
target is enabled.  This is the standard warning used for all other
knobs and I think what the warning message means is pretty clear given
the context.  Right?

> What protects `buf'?  console_sem, I assume?
> 
> -	static char buf[MAX_PRINT_CHUNK];
> +	static char buf[MAX_PRINT_CHUNK];	/* Protected by console_sem */
> 
> wouldn't hurt.

Yeah, the whole send path is serialized by console_sem and
target_list_lock.  I'll add the comment.

> > +}
> > +
> > +static void write_ext_msg(struct console *con, const char *msg,
> 
> 
> I've forgotten what's happening with this patchset.  There were a few
> design-level issues raised against an earlier version.  What were those
> and how have they been addressed?

The retransmission part was the most contentious point and Dave
pointed out that there isn't much to be gained by doing that from the
kernel side, so that part got dropped from the patchset and will
become a separate userland program, so the only remaining parts are
support for sending out extended messages from netconsole which
shouldn't be too controversial.

Thanks.

-- 
tejun
