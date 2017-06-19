From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 2/8] xdp: add HW offload mode flag for installing
 programs
Date: Tue, 20 Jun 2017 00:55:41 +0200
Message-ID: <5948566D.40803@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com> <20170616235746.16337-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, netoptimizer@brouer.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57308 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752366AbdFSWzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 18:55:46 -0400
In-Reply-To: <20170616235746.16337-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> Add an installation-time flag for requesting that the program
> be installed only if it can be offloaded to HW.
>
> Internally new command for ndo_xdp is added, this way we avoid
> putting checks into drivers since they all return -EINVAL on
> an unknown command.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a04db264aa1c..05cec8e2cd82 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6959,7 +6959,10 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
>   	struct netdev_xdp xdp;
>
>   	memset(&xdp, 0, sizeof(xdp));
> -	xdp.command = XDP_SETUP_PROG;
> +	if (flags & XDP_FLAGS_HW_MODE)
> +		xdp.command = XDP_SETUP_PROG_HW;
> +	else
> +		xdp.command = XDP_SETUP_PROG;
>   	xdp.extack = extack;
>   	xdp.flags = flags;
>   	xdp.prog = prog;

One thing I'm not sure I follow is that while you pass flags to the ndo
in patch 1, add a new XDP_SETUP_PROG_HW command here in patch 2 based on
the flags, and later on in patch 6, you don't really make use of it, but
look at the flags anyway? Then, why adding separate XDP_SETUP_PROG_HW
in the first place?

[patch 6:]
@@ -3338,6 +3341,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)

  	switch (xdp->command) {
  	case XDP_SETUP_PROG:
+	case XDP_SETUP_PROG_HW:
  		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
  					 xdp->extack);
