From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Mon, 11 May 2015 13:23:39 -0400 (EDT)
Message-ID: <20150511.132339.403868463230045095.davem@davemloft.net>
References: <1431362494-9874-1-git-send-email-tj@kernel.org>
	<1431362494-9874-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431362494-9874-5-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Mon, 11 May 2015 12:41:34 -0400

> +	/* need to insert extra header fields, detect header and body */
> +	header = msg;
> +	body = memchr(msg, ';', msg_len);
> +	if (WARN_ON_ONCE(!body))
> +		return;
> +
> +	header_len = body - header;
> +	body_len = msg_len - header_len - 1;
> +	body++;
> +
> +	/*
> +	 * Transfer multiple chunks with the following extra header.
> +	 * "ncfrag=<byte-offset>/<total-bytes>"
> +	 */
> +	memcpy(buf, header, header_len);
> +
> +	while (offset < body_len) {
> +		int this_header = header_len;
> +		int this_chunk;
> +
> +		this_header += scnprintf(buf + this_header,
> +					 sizeof(buf) - this_header,
> +					 ",ncfrag=%d/%d;", offset, body_len);
> +

Hmmm, do you intend ncfrag= to be amongst the other metadata in the first
fragment?  The way I read the code above it's going to be:

	<level>,<sequnum>,<timestamp>,<contflag>;,ncfrag=x/y;

If you intend to keep all the metadata, including the ncfrag bit,
together, you probably need to clip off the initial semicolon, so
that it looks like:

	<level>,<sequnum>,<timestamp>,<contflag>,ncfrag=x/y;
