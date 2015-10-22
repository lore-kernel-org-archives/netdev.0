From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v4 1/2] mpls: multipath route support
Date: Wed, 21 Oct 2015 21:00:07 -0500
Message-ID: <87k2qfek7s.fsf@x220.int.ebiederm.org>
References: <1445217645-42885-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41577 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbJVCIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:08:47 -0400
In-Reply-To: <1445217645-42885-2-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Sun, 18 Oct 2015 18:20:44 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds support for MPLS multipath routes.
>
> Includes following changes to support multipath:
> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'
>
> - 'struct mpls_nh' represents a mpls nexthop label forwarding entry
>
> - moves mpls route and nexthop structures into internal.h
>
> - A mpls_route can point to multiple mpls_nh structs
>
> - the nexthops are maintained as a array (similar to ipv4 fib)
>
> - In the process of restructuring, this patch also consistently changes
>   all labels to u8
>
> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
> multipath routes similar to ipv4/v6 fib
>
> - In this patch, the multipath route nexthop selection algorithm
> simply returns the first nexthop. It is replaced by a
> hash based algorithm from Robert Shearman in the next patch
>
> - mpls_route_update cleanup: remove 'dev' handling in mpls_route_update.
> mpls_route_update though implemented to update based on dev, it was
> never used that way. And the dev handling gets tricky with multiple nexthops.
> Cannot match against any single nexthops dev. So, this patch removes the unused
> 'dev' handling in mpls_route_update.
>
> Example:
>
> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
>                 nexthop as 700 via inet 10.1.1.6 dev swp2 \
>                 nexthop as 800 via inet 40.1.1.2 dev swp3
>
> $ip  -f mpls route show
> 100
>         nexthop as to 200 via inet 10.1.1.2  dev swp1
>         nexthop as to 700 via inet 10.1.1.6  dev swp2
>         nexthop as to 800 via inet 40.1.1.2  dev swp3
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/net/mpls_iptunnel.h |   2 +-
>  net/mpls/af_mpls.c          | 498 +++++++++++++++++++++++++++++++-------------
>  net/mpls/internal.h         |  52 ++++-
>  3 files changed, 403 insertions(+), 149 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index bb185a2..ebefdd4 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
[...]
> @@ -431,15 +417,171 @@ static struct net_device *find_outdev(struct net *net,
>  	return dev;
>  }
>  
> +static int mpls_nh_assign_dev(struct net *net, struct mpls_nh *nh, int oif)
> +{
> +	struct net_device *dev = NULL;
> +	int err = -ENODEV;
> +
> +	dev = find_outdev(net, nh, oif);
> +	if (IS_ERR(dev)) {
> +		err = PTR_ERR(dev);
> +		dev = NULL;
> +		goto errout;
> +	}
> +
> +	/* Ensure this is a supported device */
> +	err = -EINVAL;
> +	if (!mpls_dev_get(dev))
> +		goto errout;
> +
> +	/* For now just support ethernet devices */
> +	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
> +		goto errout;

Roopa you don't need this extra test of ARPHRD_ETHER and ARPHRD_LOOPBACK.
We already guard mpls_add_dev with this, so mpls_dev_get will fail if it
is the wrong kind of device.

> +
> +	RCU_INIT_POINTER(nh->nh_dev, dev);
> +	dev_put(dev);
> +
> +	return 0;
> +
> +errout:
> +	if (dev)
> +		dev_put(dev);
> +	return err;
> +}

Eric
