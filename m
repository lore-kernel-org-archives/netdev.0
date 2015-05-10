From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 3/3] netconsole: implement extended console support
Date: Sun, 10 May 2015 11:34:19 -0400
Message-ID: <20150510153419.GA5856@htj.duckdns.org>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
 <1430505220-25160-4-git-send-email-tj@kernel.org>
 <20150504200456.GI1971@htj.duckdns.org>
 <20150510151146.GA31053@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150510151146.GA31053@via.ecp.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Sabrina.

On Sun, May 10, 2015 at 05:11:46PM +0200, Sabrina Dubroca wrote:
> > +static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
> > +			     int msg_len)
> > +{
> > +	static char buf[MAX_PRINT_CHUNK];
> > +	const int max_extra_len = sizeof(",ncfrag=0000/0000");
> 
> Is msg_len guaranteed < 10000?  Otherwise I think the WARN in the send
> loop can trigger.

Yeap, the absolute maximum is 8k.

> Also, I think your count is correct because sizeof adds one to the
> string's length, but you don't explicitly account for the ';' between
> header and body fragment here (and in chunk_len). header_len will stop
> before the ;.

Hmm... ';' would be accounted for in the length of the original
message.  This function just needs to count the extra number of bytes
to be added which means that sizeof() - 1 would be the precise count
here.  Do we care?

> > +	/*
> > +	 * Transfer possibly multiple chunks with extra header fields.
> > +	 *
> > +	 * If @msg needs to be split to fit MAX_PRINT_CHUNK, add
> > +	 * "ncfrag=<byte-offset>/<total-bytes>" to identify each chunk.
> > +	 */
> > +	memcpy(buf, header, header_len);
> > +	nr_chunks = DIV_ROUND_UP(body_len, chunk_len);
> 
> Wouldn't it be simpler to loop on the remaining size, instead of
> doing a division?

Indeed, this is a remnant of earlier code which emitted total number
of chunks.  Will restructure.

> > +
> > +	for (i = 0; i < nr_chunks; i++) {
> > +		int offset = i * chunk_len;
> > +		int this_header = header_len;
> > +		int this_chunk = min(body_len - offset, chunk_len);
> > +
> > +		if (nr_chunks > 1)
> 
> We already know that there will be more than one chunk, since
> you handle msg_len <= MAX_PRINT_CHUNK at the beginning?

Ditto, earlier code had two types of conditions which trigger this
code path.  Will remove.

> > +			this_header += scnprintf(buf + this_header,
> > +						 sizeof(buf) - this_header,
> > +						 ",ncfrag=%d/%d;",
> > +						 offset, body_len);
> > +
> > +		if (WARN_ON_ONCE(this_header + chunk_len > MAX_PRINT_CHUNK))
> > +			return;
> 
> This WARN doesn't really seem necessary to me, except for the msg_len
> maximum I mentionned earlier.
> And if we don't use nr_chunks, we could compute the fragment's length
> here in case some computation went wrong.

I think it'd be better to keep it tho.  It's one unlikely branch in an
already unlikely path.  It doesn't really cost anything.  Stuff
happens, code changes and it'd suck if e.g. netconsole ends up causing
memory corruption following changes / failures in upper layers.

> > +
> > +		memcpy(buf + this_header, body, this_chunk);
> > +
> > +		netpoll_send_udp(&nt->np, buf, this_header + this_chunk);
> > +
> 
> netpoll_send_udp already does a memcpy (in skb_copy_to_linear_data).
> Maybe it would be better to modify netpoll_send_udp, or add a variant
> that takes two buffers? or more than two, with something like an iovec?

The splitting is a very rare event.  I don't think we need to be
worrying about its performance at this level.

Thanks.

-- 
tejun
