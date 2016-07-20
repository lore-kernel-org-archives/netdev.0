From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v10 04/12] rtnl: add option for setting link xdp prog
Date: Wed, 20 Jul 2016 10:35:22 -0700
Message-ID: <20160720173521.GB16467@gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-5-git-send-email-bblanco@plumgrid.com>
 <578F3899.2030605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34774 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbcGTRfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 13:35:25 -0400
Received: by mail-pa0-f48.google.com with SMTP id fi15so20292642pac.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 10:35:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <578F3899.2030605@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 10:38:49AM +0200, Daniel Borkmann wrote:
> On 07/19/2016 09:16 PM, Brenden Blanco wrote:
> >Sets the bpf program represented by fd as an early filter in the rx path
> >of the netdev. The fd must have been created as BPF_PROG_TYPE_XDP.
> >Providing a negative value as fd clears the program. Getting the fd back
> >via rtnl is not possible, therefore reading of this value merely
> >provides a bool whether the program is valid on the link or not.
> >
> >Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> [...]
> >@@ -2054,6 +2101,23 @@ static int do_setlink(const struct sk_buff *skb,
> >  		status |= DO_SETLINK_NOTIFY;
> >  	}
> >
> >+	if (tb[IFLA_XDP]) {
> >+		struct nlattr *xdp[IFLA_XDP_MAX + 1];
> >+
> >+		err = nla_parse_nested(xdp, IFLA_XDP_MAX, tb[IFLA_XDP],
> >+				       ifla_xdp_policy);
> >+		if (err < 0)
> >+			goto errout;
> >+
> >+		if (xdp[IFLA_XDP_FD]) {
> >+			err = dev_change_xdp_fd(dev,
> >+						nla_get_s32(xdp[IFLA_XDP_FD]));
> >+			if (err)
> >+				goto errout;
> >+			status |= DO_SETLINK_NOTIFY;
> >+		}
> 
> For the setlink case IFLA_XDP_ATTACHED has no meaning currently, so I'd
> suggest it would be good to be strict and still add a:
> 
> 		/* Only used in rtnl_fill_ifinfo currently. */
> 		if (xdp[IFLA_XDP_ATTACHED]) {
> 			err = -EINVAL;
> 			goto errout;
> 		}
> 
Agreed.
> >+	}
> >+
> >  errout:
> >  	if (status & DO_SETLINK_MODIFIED) {
> >  		if (status & DO_SETLINK_NOTIFY)
> >
> 
