From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 04/16] printk: implement support for extended console
 drivers
Date: Mon, 27 Apr 2015 17:09:22 -0400
Message-ID: <20150427210922.GA2152@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-5-git-send-email-tj@kernel.org>
 <20150420154120.GA4589@pathway.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Petr Mladek <pmladek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150420154120.GA4589@pathway.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Petr.

Sorry about the delay.

On Mon, Apr 20, 2015 at 05:43:07PM +0200, Petr Mladek wrote:
...
> > * Extended message formatting for console drivers is enabled iff there
> 
> s/iff/if/

if and only if

> I was afraid that there might be a potential buffer overflow because
> the user-provided dict need not be limited by '\0'. But LOG_DICT_META
> is used only with the internal data that are safe. We might document
> this as well.
> 
> BTW: Do you want to print the internal dict when calling this function
> in devkmsg_read()?

No, plesae see below.

> > +		scnprintf(fragid_buf, sizeof(fragid_buf),
> > +			  ",fragid=%llu", fragid);
> > +	return scnprintf(buf, size, "%u,%llu,%llu,%c%s;",
> > +			 (msg->facility << 3) | msg->level, seq, ts_usec, cont,
> > +			 fragid_buf);
> 
> The above comment suggests that  "cont" and "fragid_buf" are delimited
> by a comma but it is not used here. Is it by intention.

Hmm... how is it not?  The fragid printf has preceding comma.

> > +		dict_len = scnprintf(dict_buf, sizeof(dict_buf), "FRAGID=%llu",
> > +				     cont.fragid);
> > +		log_store(cont.facility, cont.level,
> > +			  flags | LOG_NOCONS | LOG_DICT_META,
> > +			  cont.ts_nsec, dict_buf, dict_len, cont.buf, cont.len);
> 
> I wonder if it would make sense to restart fragid here. Another line
> will get distinguished by "seqnum".

That'd assume that there can only ever be a single continuation
buffer, which is true now but it's possible that we may want to make
it per-cpu in the future.

> Sigh, the whole mess is caused by the fact that we could not extend
> struct printk_log easily. It would be much better if we could put
> fragid there. I finally understand why you need to reuse the dict.

I've been thinking about it and using dict area for internal metadata
is indeed quite messy.  I think a better way to do it is declaring
dict_len as a union w/ fragid.  This'd limit the fragid to 16bit but
that should be more than enough and we can do away with the string
formatting and reading back.

> Another solution would be to allow to disable the continuous buffer
> via some boot option or /sys/kernel/debug entry if you want to debug
> such a problem and have problem with the partial flushing.

It isn't really about debugging partial flushing itself but rather
always being able to push out the messages before the printk
invocation finishes.

Thanks.

-- 
tejun
