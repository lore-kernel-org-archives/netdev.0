From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] netconsole: implement extended console support
Date: Sat, 2 May 2015 09:24:32 -0400
Message-ID: <20150502132432.GF1949@htj.duckdns.org>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
 <1430505220-25160-4-git-send-email-tj@kernel.org>
 <201505021354.DEH35401.VOOFFMHLJFtOQS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201505021354.DEH35401.VOOFFMHLJFtOQS@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Tetsuo.

On Sat, May 02, 2015 at 01:54:57PM +0900, Tetsuo Handa wrote:
> Tejun Heo wrote:
> > +For example,
> > +
> > + 6,416,1758426,-,ncfrag=0/33;the first chunk,
> > + 6,416,1758426,-,ncfrag=16/33;the second chunk.
> > +
> 
> Wouldn't total-bytes > 1000 than 33 in this example?

It's trying to give an example on how the ncfrag header looks like but
yeah I'll tweak it a bit and add further explanation.

> > +/**
> > + * send_ext_msg_udp - send extended log message to target
> > + * @nt: target to send message to
> > + * @msg: extended log message to send
> > + * @msg_len: length of message
> > + *
> > + * Transfer extended log @msg to @nt.  If @msg is longer than
> > + * MAX_PRINT_CHUNK, it'll be split and transmitted in multiple chunks with
> > + * ncfrag header field added to identify them.
> > + */
> > +static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
> > +			     int msg_len)
> > +{
> > +	static char buf[MAX_PRINT_CHUNK];
> > +	const int max_extra_len = sizeof(",ncfrag=0000/0000");
> > +	const char *header, *body;
> > +	int header_len = msg_len, body_len = 0;
> > +	int chunk_len, nr_chunks, i;
> > +
> > +	if (msg_len <= MAX_PRINT_CHUNK) {
> > +		netpoll_send_udp(&nt->np, msg, msg_len);
> > +		return;
> > +	}
> > +
> > +	/* need to insert extra header fields, detect header and body */
> > +	header = msg;
> > +	body = memchr(msg, ';', msg_len);
> > +	if (body) {
> > +		header_len = body - header;
> > +		body_len = msg_len - header_len - 1;
> > +		body++;
> > +	}
> > +
> > +	chunk_len = MAX_PRINT_CHUNK - header_len - max_extra_len;
> > +	if (WARN_ON_ONCE(chunk_len <= 0))
> > +		return;
> 
> This path is executed only when msg_len > MAX_PRINT_CHUNK.
> And since header_len == msg_len if body == NULL, chunk_len <= 0 is true.
> We will hit this WARN_ON_ONCE() if memchr(msg, ';', msg_len) == NULL
> which will fail to send the message. Is this what you want?

Yeah, extended consoles should be fed messages w/ proper headers.  If
not, we warn and bail.

> > +static void write_ext_msg(struct console *con, const char *msg,
> > +			  unsigned int len)
> > +{
> > +	struct netconsole_target *nt;
> > +	unsigned long flags;
> > +
> > +	if ((oops_only && !oops_in_progress) || list_empty(&target_list))
> > +		return;
> > +
> > +	spin_lock_irqsave(&target_list_lock, flags);
> > +	list_for_each_entry(nt, &target_list, list)
> 
> Don't you need to call netconsole_target_get() here
> 
> > +		if (nt->extended && nt->enabled && netif_running(nt->np.dev))
> > +			send_ext_msg_udp(nt, msg, len);
> 
> and netconsole_target_put() here as with write_msg()?

Ah, I dropped the patch which removed it from write_msg() but the
following pattern doesn't do anything.  It's just pure confusion.

	lock;
	ref++ on an item on the index;
	do something w/o releasing lock;
	ref-- on the item;
	unlock;

netconsole_netdev_event() has to release lock to process the item so
refcnting is needed there.  It got duplicated in write_msg() for no
reason.  I'll add a patch to remove it.

Thanks.

-- 
tejun
