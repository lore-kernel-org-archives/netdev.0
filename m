From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v3 3/3] netconsole: implement extended console support
Date: Sun, 10 May 2015 17:11:46 +0200
Message-ID: <20150510151146.GA31053@via.ecp.fr>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
 <1430505220-25160-4-git-send-email-tj@kernel.org>
 <20150504200456.GI1971@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:39600 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbEJPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 11:20:03 -0400
Content-Disposition: inline
In-Reply-To: <20150504200456.GI1971@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tejun,


2015-05-04, 16:04:56 -0400, Tejun Heo wrote:

[...]

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

Is msg_len guaranteed < 10000?  Otherwise I think the WARN in the send
loop can trigger.

Also, I think your count is correct because sizeof adds one to the
string's length, but you don't explicitly account for the ';' between
header and body fragment here (and in chunk_len). header_len will stop
before the ;.


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
> +
> +	/*
> +	 * Transfer possibly multiple chunks with extra header fields.
> +	 *
> +	 * If @msg needs to be split to fit MAX_PRINT_CHUNK, add
> +	 * "ncfrag=<byte-offset>/<total-bytes>" to identify each chunk.
> +	 */
> +	memcpy(buf, header, header_len);
> +	nr_chunks = DIV_ROUND_UP(body_len, chunk_len);

Wouldn't it be simpler to loop on the remaining size, instead of
doing a division?


> +
> +	for (i = 0; i < nr_chunks; i++) {
> +		int offset = i * chunk_len;
> +		int this_header = header_len;
> +		int this_chunk = min(body_len - offset, chunk_len);
> +
> +		if (nr_chunks > 1)

We already know that there will be more than one chunk, since
you handle msg_len <= MAX_PRINT_CHUNK at the beginning?


> +			this_header += scnprintf(buf + this_header,
> +						 sizeof(buf) - this_header,
> +						 ",ncfrag=%d/%d;",
> +						 offset, body_len);
> +
> +		if (WARN_ON_ONCE(this_header + chunk_len > MAX_PRINT_CHUNK))
> +			return;

This WARN doesn't really seem necessary to me, except for the msg_len
maximum I mentionned earlier.
And if we don't use nr_chunks, we could compute the fragment's length
here in case some computation went wrong.


> +
> +		memcpy(buf + this_header, body, this_chunk);
> +
> +		netpoll_send_udp(&nt->np, buf, this_header + this_chunk);
> +

netpoll_send_udp already does a memcpy (in skb_copy_to_linear_data).
Maybe it would be better to modify netpoll_send_udp, or add a variant
that takes two buffers? or more than two, with something like an iovec?

> +		body += this_chunk;
> +	}
> +}
>
> [...]




Thanks,

-- 
Sabrina
