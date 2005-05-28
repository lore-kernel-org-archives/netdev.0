From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH 4/5] [NET] Add skb_find_text() to search for a text pattern
 in skbs
Date: Sat, 28 May 2005 05:11:46 +0200
Message-ID: <4297E172.5020907@eurodev.net>
References: <20050527224725.GG15391@postel.suug.ch> <20050527224858.GK15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527224858.GK15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> +static int get_skb_text(int offset, unsigned char **text,
> +			struct ts_config *conf, struct ts_state *state)
> +{
> +	/* args[0]: lower limit
> +	 * args[1]: upper limit
> +	 * args[2]: skb
> +	 * args[3]: fragment index
> +	 * args[4]: current fragment data buffer
> +	 * args[5]: octets consumed up to previous fragment */
> +	int from = state->args[0], to = state->args[1];
> +	struct sk_buff *skb = (struct sk_buff *) state->args[2];
> +	int limit = min_t(int, skb_headlen(skb), to);
> +	int real_offset = offset + from;
> +	skb_frag_t *f;
> +
> +	if (!skb_is_nonlinear(skb)) {
> +		if (real_offset < limit) {
> +linear:
> +			*text = skb->data + real_offset;
> +			return limit - real_offset;
> +		}
> +
> +		return 0;
> +	}
> +
> +	if (real_offset < limit)
> +		goto linear;
> +
> +next_fragment:
> +	f = &skb_shinfo(skb)->frags[state->args[3]];
> +	limit = min_t(int, f->size + state->args[5], to);
> +
> +	if (!state->args[4])
> +		state->args[4] = (long) kmap_skb_frag(f);
> +
> +	if (real_offset < limit) {
> +		*text = (unsigned char *) state->args[4] + f->page_offset +
> +			(real_offset - (int) state->args[5]);
> +		return limit - real_offset;
> +	}
> +
> +	kunmap_skb_frag((void *) state->args[4]);
> +	state->args[3]++;
> +	state->args[4] = (long) NULL;
> +	state->args[5] += f->size;
> +
> +	if (state->args[3] >= skb_shinfo(skb)->nr_frags)
> +		return 0;
> +
> +	goto next_fragment;
> +}

Still miss something here. You aren't looking for matches in skbs 
inserted in skb_shinfo(skb)->frag_list. Have a look at rusty's skb_iter 
functions. Since he cooked those for this purpose (string matching), why 
don't we use them instead of yours ?

--
Pablo
