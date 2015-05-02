From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] netconsole: implement extended console support
Date: Sat, 2 May 2015 13:54:57 +0900
Message-ID: <201505021354.DEH35401.VOOFFMHLJFtOQS@I-love.SAKURA.ne.jp>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
	<1430505220-25160-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:48860 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbEBEzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 00:55:12 -0400
In-Reply-To: <1430505220-25160-4-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo wrote:
> +If a message doesn't fit in 1000 bytes, the message is split into
> +multiple fragments by netconsole. These fragments are transmitted with
> +"ncfrag" header field added.
> +
> + ncfrag=<byte-offset>/<total-bytes>
> +
> +For example,
> +
> + 6,416,1758426,-,ncfrag=0/33;the first chunk,
> + 6,416,1758426,-,ncfrag=16/33;the second chunk.
> +

Wouldn't total-bytes > 1000 than 33 in this example?

> +/**
> + * send_ext_msg_udp - send extended log message to target
> + * @nt: target to send message to
> + * @msg: extended log message to send
> + * @msg_len: length of message
> + *
> + * Transfer extended log @msg to @nt.  If @msg is longer than
> + * MAX_PRINT_CHUNK, it'll be split and transmitted in multiple chunks with
> + * ncfrag header field added to identify them.
> + */
> +static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
> +			     int msg_len)
> +{
> +	static char buf[MAX_PRINT_CHUNK];
> +	const int max_extra_len = sizeof(",ncfrag=0000/0000");
> +	const char *header, *body;
> +	int header_len = msg_len, body_len = 0;
> +	int chunk_len, nr_chunks, i;
> +
> +	if (msg_len <= MAX_PRINT_CHUNK) {
> +		netpoll_send_udp(&nt->np, msg, msg_len);
> +		return;
> +	}
> +
> +	/* need to insert extra header fields, detect header and body */
> +	header = msg;
> +	body = memchr(msg, ';', msg_len);
> +	if (body) {
> +		header_len = body - header;
> +		body_len = msg_len - header_len - 1;
> +		body++;
> +	}
> +
> +	chunk_len = MAX_PRINT_CHUNK - header_len - max_extra_len;
> +	if (WARN_ON_ONCE(chunk_len <= 0))
> +		return;

This path is executed only when msg_len > MAX_PRINT_CHUNK.
And since header_len == msg_len if body == NULL, chunk_len <= 0 is true.
We will hit this WARN_ON_ONCE() if memchr(msg, ';', msg_len) == NULL
which will fail to send the message. Is this what you want?

> +static void write_ext_msg(struct console *con, const char *msg,
> +			  unsigned int len)
> +{
> +	struct netconsole_target *nt;
> +	unsigned long flags;
> +
> +	if ((oops_only && !oops_in_progress) || list_empty(&target_list))
> +		return;
> +
> +	spin_lock_irqsave(&target_list_lock, flags);
> +	list_for_each_entry(nt, &target_list, list)

Don't you need to call netconsole_target_get() here

> +		if (nt->extended && nt->enabled && netif_running(nt->np.dev))
> +			send_ext_msg_udp(nt, msg, len);

and netconsole_target_put() here as with write_msg()?

> +	spin_unlock_irqrestore(&target_list_lock, flags);
> +}
> +
