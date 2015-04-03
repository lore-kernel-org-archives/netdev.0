From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Fri, 3 Apr 2015 14:55:02 +0900
Message-ID: <20150403055500.GA3336@vergenet.net>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34968 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbDCFzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 01:55:14 -0400
Received: by patj18 with SMTP id j18so106501181pat.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 22:55:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On Thu, Apr 02, 2015 at 03:17:06PM -0400, John W. Linville wrote:
> This is an initial implementation of a netdev driver for GENEVE
> tunnels.  This implementation uses a fixed UDP port, and only supports
> a single tunnel (and therefore only a single VNI) per net namespace.
> Only IPv4 links are supported at this time.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Thanks for working on this. I'm very happy to see a Geneve driver hit netdev.

I have a question below.

[snip]

> +/* Scheduled at device creation to bind to a socket */
> +static void geneve_sock_work(struct work_struct *work)
> +{
> +	struct geneve_dev *geneve = container_of(work, struct geneve_dev, sock_work);
> +	struct net *net = geneve->net;
> +	struct geneve_sock *gs;
> +
> +	gs = geneve_sock_add(net, htons(GENEVE_UDP_PORT), geneve_rx, geneve,
> +	                     true, false);
> +	if (!IS_ERR(gs))
> +		geneve->sock = gs;
> +
> +	dev_put(geneve->dev);
> +}
> +
> +/* Setup stats when device is created */
> +static int geneve_init(struct net_device *dev)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +
> +	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> +	if (!dev->tstats)
> +		return -ENOMEM;
> +
> +	/* make new socket outside of RTNL */
> +	dev_hold(dev);
> +	queue_work(geneve_wq, &geneve->sock_work);
> +
> +	return 0;
> +}
> +
> +static void geneve_uninit(struct net_device *dev)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct geneve_sock *gs = geneve->sock;
> +
> +	if (gs)
> +		geneve_sock_release(gs);
> +	free_percpu(dev->tstats);
> +}

I am wondering if there a possibility that geneve_sock_work() could run
after the check for gs in geneve_uninit() thus leaking gs?

[snip]
