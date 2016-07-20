From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v10 04/12] rtnl: add option for setting link xdp prog
Date: Wed, 20 Jul 2016 10:38:49 +0200
Message-ID: <578F3899.2030605@iogearbox.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com> <1468955817-10604-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45946 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbcGTIiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 04:38:55 -0400
In-Reply-To: <1468955817-10604-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 09:16 PM, Brenden Blanco wrote:
> Sets the bpf program represented by fd as an early filter in the rx path
> of the netdev. The fd must have been created as BPF_PROG_TYPE_XDP.
> Providing a negative value as fd clears the program. Getting the fd back
> via rtnl is not possible, therefore reading of this value merely
> provides a bool whether the program is valid on the link or not.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
[...]
> @@ -2054,6 +2101,23 @@ static int do_setlink(const struct sk_buff *skb,
>   		status |= DO_SETLINK_NOTIFY;
>   	}
>
> +	if (tb[IFLA_XDP]) {
> +		struct nlattr *xdp[IFLA_XDP_MAX + 1];
> +
> +		err = nla_parse_nested(xdp, IFLA_XDP_MAX, tb[IFLA_XDP],
> +				       ifla_xdp_policy);
> +		if (err < 0)
> +			goto errout;
> +
> +		if (xdp[IFLA_XDP_FD]) {
> +			err = dev_change_xdp_fd(dev,
> +						nla_get_s32(xdp[IFLA_XDP_FD]));
> +			if (err)
> +				goto errout;
> +			status |= DO_SETLINK_NOTIFY;
> +		}

For the setlink case IFLA_XDP_ATTACHED has no meaning currently, so I'd
suggest it would be good to be strict and still add a:

		/* Only used in rtnl_fill_ifinfo currently. */
		if (xdp[IFLA_XDP_ATTACHED]) {
			err = -EINVAL;
			goto errout;
		}

> +	}
> +
>   errout:
>   	if (status & DO_SETLINK_MODIFIED) {
>   		if (status & DO_SETLINK_NOTIFY)
>
