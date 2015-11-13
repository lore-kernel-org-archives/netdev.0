From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [patch] netlink: fix a limit in NETLINK_LIST_MEMBERSHIPS
Date: Fri, 13 Nov 2015 15:43:31 +0100
Message-ID: <CANq1E4Rh60iS6WRq6xypV_ahG5N=uErL_hMnVcncc=DTSPvdUw@mail.gmail.com>
References: <20151113142044.GA1445@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151113142044.GA1445@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Fri, Nov 13, 2015 at 3:20 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> This condition doesn't work when len is smaller than expected and not a
> multiple of 4.  In that situation "len - pos" is negative and type
> promoted to a high unsigned value and we do not break out of the loop.
> It causes the program calling it to crash.

Could you give an example how this can happen? The loop-invariant
should be "len >= pos", as such, this shouldn't happen. "pos" starts
out as 0, "len" is guaranteed to be >=0. "pos" is only incremented by
4, if "len - pos >= 4".

What am I missing?

Thanks
David

> Fixes: b42be38b2778 ('netlink: add API to retrieve all group memberships')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..76a8466 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2373,7 +2373,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
>                 err = 0;
>                 netlink_lock_table();
>                 for (pos = 0; pos * 8 < nlk->ngroups; pos += sizeof(u32)) {
> -                       if (len - pos < sizeof(u32))
> +                       if (len < pos + sizeof(u32))
>                                 break;
>
>                         idx = pos / sizeof(unsigned long);
