From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Tue, 12 May 2015 16:36:02 -0700
Message-ID: <20150512163602.ba6c83e3056702cbd840edef@linux-foundation.org>
References: <1431362494-9874-1-git-send-email-tj@kernel.org>
	<1431362494-9874-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431362494-9874-5-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 May 2015 12:41:34 -0400 Tejun Heo <tj@kernel.org> wrote:

> printk logbuf keeps various metadata and optional key=value dictionary
> for structured messages, both of which are stripped when messages are
> handed to regular console drivers.
> 
> It can be useful to have this metadata and dictionary available to
> netconsole consumers.  This obviously makes logging via netconsole
> more complete and the sequence number in particular is useful in
> environments where messages may be lost or reordered in transit -
> e.g. when netconsole is used to collect messages in a large cluster
> where packets may have to travel congested hops to reach the
> aggregator.  The lost and reordered messages can easily be identified
> and handled accordingly using the sequence numbers.
> 
> printk recently added extended console support which can be selected
> by setting CON_EXTENDED flag.

There's no such thing as CON_EXTENDED.  Not sure what this is trying to
say.

>  From console driver side, not much
> changes.  The only difference is that the text passed to the write
> callback is formatted the same way as /dev/kmsg.
> 
> This patch implements extended console support for netconsole which
> can be enabled by either prepending "+" to a netconsole boot param
> entry or echoing 1 to "extended" file in configfs.  When enabled,
> netconsole transmits extended log messages with headers identical to
> /dev/kmsg output.
> 
> There's one complication due to message fragments.  netconsole limits
> the maximum message size to 1k and messages longer than that are split
> into multiple fragments.  As all extended console messages should
> carry matching headers and be uniquely identifiable, each extended
> message fragment carries full copy of the metadata and an extra header
> field to identify the specific fragment.  The optional header is of
> the form "ncfrag=OFF/LEN" where OFF is the byte offset into the
> message body and LEN is the total length.
> 
> To avoid unnecessarily making printk format extended messages,
> Extended netconsole is registered with printk when the first extended
> netconsole is configured.
>
> ...
>
> +static ssize_t store_extended(struct netconsole_target *nt,
> +			      const char *buf,
> +			      size_t count)
> +{
> +	int extended;
> +	int err;
> +
> +	if (nt->enabled) {
> +		pr_err("target (%s) is enabled, disable to update parameters\n",
> +		       config_item_name(&nt->item));
> +		return -EINVAL;
> +	}

What's the reason for the above?

It's unclear (to me, at least ;)) what "disable" means?  Specifically
what steps must the operator take to successfully perform this
operation?  A sentence detailing those steps in netconsole.txt would be
nice.

> +	err = kstrtoint(buf, 10, &extended);
> +	if (err < 0)
> +		return err;
> +	if (extended < 0 || extended > 1)
> +		return -EINVAL;
> +
> +	nt->extended = extended;
> +
> +	return strnlen(buf, count);
> +}
> +
>
> ...
>
> +static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
> +			     int msg_len)
> +{
> +	static char buf[MAX_PRINT_CHUNK];
> +	const char *header, *body;
> +	int offset = 0;
> +	int header_len, body_len;
> +
> +	if (msg_len <= MAX_PRINT_CHUNK) {
> +		netpoll_send_udp(&nt->np, msg, msg_len);
> +		return;
> +	}
> +
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
> +		this_chunk = min(body_len - offset,
> +				 MAX_PRINT_CHUNK - this_header);
> +		if (WARN_ON_ONCE(this_chunk <= 0))
> +			return;
> +
> +		memcpy(buf + this_header, body + offset, this_chunk);
> +
> +		netpoll_send_udp(&nt->np, buf, this_header + this_chunk);
> +
> +		offset += this_chunk;
> +	}

What protects `buf'?  console_sem, I assume?

-	static char buf[MAX_PRINT_CHUNK];
+	static char buf[MAX_PRINT_CHUNK];	/* Protected by console_sem */

wouldn't hurt.

> +}
> +
> +static void write_ext_msg(struct console *con, const char *msg,


I've forgotten what's happening with this patchset.  There were a few
design-level issues raised against an earlier version.  What were those
and how have they been addressed?
