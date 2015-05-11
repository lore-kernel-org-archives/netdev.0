From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Mon, 11 May 2015 16:37:45 -0400
Message-ID: <20150511203745.GI11388@htj.duckdns.org>
References: <1431362494-9874-1-git-send-email-tj@kernel.org>
 <1431362494-9874-5-git-send-email-tj@kernel.org>
 <20150511.132339.403868463230045095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150511.132339.403868463230045095.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, May 11, 2015 at 01:23:39PM -0400, David Miller wrote:
> From: Tejun Heo <tj@kernel.org>
> Date: Mon, 11 May 2015 12:41:34 -0400
> 
> > +	/* need to insert extra header fields, detect header and body */
> > +	header = msg;
> > +	body = memchr(msg, ';', msg_len);
> > +	if (WARN_ON_ONCE(!body))
> > +		return;
> > +
> > +	header_len = body - header;
> > +	body_len = msg_len - header_len - 1;
> > +	body++;
> > +
> > +	/*
> > +	 * Transfer multiple chunks with the following extra header.
> > +	 * "ncfrag=<byte-offset>/<total-bytes>"
> > +	 */
> > +	memcpy(buf, header, header_len);
> > +
> > +	while (offset < body_len) {
> > +		int this_header = header_len;
> > +		int this_chunk;
> > +
> > +		this_header += scnprintf(buf + this_header,
> > +					 sizeof(buf) - this_header,
> > +					 ",ncfrag=%d/%d;", offset, body_len);
> > +
> 
> Hmmm, do you intend ncfrag= to be amongst the other metadata in the first
> fragment?  The way I read the code above it's going to be:
> 
> 	<level>,<sequnum>,<timestamp>,<contflag>;,ncfrag=x/y;
> 
> If you intend to keep all the metadata, including the ncfrag bit,
> together, you probably need to clip off the initial semicolon, so
> that it looks like:
> 
> 	<level>,<sequnum>,<timestamp>,<contflag>,ncfrag=x/y;

The current code does produce the latter outcome.

	header = msg;
	body = memchr(msg, ';', msg_len);
	if (WARN_ON_ONCE(!body))
		return;

	header_len = body - header;
	body_len = msg_len - header_len - 1;
	body++;

@body points to ';' after memchr(), so @header_len doesn't include
';'.  @body is incremented after calculating @header_len.

Thanks.

-- 
tejun
