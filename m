From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Fri, 3 Apr 2015 10:41:57 -0400
Message-ID: <20150403144157.GC31348@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <20150403055500.GA3336@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59771 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbDCOpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 10:45:19 -0400
Content-Disposition: inline
In-Reply-To: <20150403055500.GA3336@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2015 at 02:55:02PM +0900, Simon Horman wrote:
> Hi John,
> 
> On Thu, Apr 02, 2015 at 03:17:06PM -0400, John W. Linville wrote:
> > This is an initial implementation of a netdev driver for GENEVE
> > tunnels.  This implementation uses a fixed UDP port, and only supports
> > a single tunnel (and therefore only a single VNI) per net namespace.
> > Only IPv4 links are supported at this time.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> Thanks for working on this. I'm very happy to see a Geneve driver hit netdev.
> 
> I have a question below.
> 
> [snip]
> 
> > +/* Scheduled at device creation to bind to a socket */
> > +static void geneve_sock_work(struct work_struct *work)
> > +{
> > +	struct geneve_dev *geneve = container_of(work, struct geneve_dev, sock_work);
> > +	struct net *net = geneve->net;
> > +	struct geneve_sock *gs;
> > +
> > +	gs = geneve_sock_add(net, htons(GENEVE_UDP_PORT), geneve_rx, geneve,
> > +	                     true, false);
> > +	if (!IS_ERR(gs))
> > +		geneve->sock = gs;
> > +
> > +	dev_put(geneve->dev);
> > +}
> > +
> > +/* Setup stats when device is created */
> > +static int geneve_init(struct net_device *dev)
> > +{
> > +	struct geneve_dev *geneve = netdev_priv(dev);
> > +
> > +	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> > +	if (!dev->tstats)
> > +		return -ENOMEM;
> > +
> > +	/* make new socket outside of RTNL */
> > +	dev_hold(dev);
> > +	queue_work(geneve_wq, &geneve->sock_work);
> > +
> > +	return 0;
> > +}
> > +
> > +static void geneve_uninit(struct net_device *dev)
> > +{
> > +	struct geneve_dev *geneve = netdev_priv(dev);
> > +	struct geneve_sock *gs = geneve->sock;
> > +
> > +	if (gs)
> > +		geneve_sock_release(gs);
> > +	free_percpu(dev->tstats);
> > +}
> 
> I am wondering if there a possibility that geneve_sock_work() could run
> after the check for gs in geneve_uninit() thus leaking gs?
> 
> [snip]

Hey, good catch!  I should add some locking around that...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
