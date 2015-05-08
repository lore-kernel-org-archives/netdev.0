From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Fri, 8 May 2015 19:22:36 -0400
Message-ID: <20150508232236.GO14981@tuxdriver.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
 <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
 <CAHA+R7MqO2te-OR7mZqdy=TDkrcgyGhb-A4DvbQ07JAaKu49-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54545 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbEHXaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 19:30:21 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7MqO2te-OR7mZqdy=TDkrcgyGhb-A4DvbQ07JAaKu49-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2015 at 01:55:15PM -0700, Cong Wang wrote:
> On Fri, May 8, 2015 at 10:20 AM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > +
> > +/* Setup stats when device is created */
> > +static int geneve_init(struct net_device *dev)
> > +{
> > +       struct geneve_dev *geneve = netdev_priv(dev);
> > +
> > +       dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> > +       if (!dev->tstats)
> > +               return -ENOMEM;
> > +
> > +       /* make new socket outside of RTNL */
> > +       dev_hold(dev);
> > +       queue_work(geneve_wq, &geneve->sock_work);
> > +
> 
> 
> Any reason to create socket in this init() rather than in ndo_open()?

The socket can be created asynchronously and ndo_open can fail if
the socket creation hasn't succeeded.
 
> > +       return 0;
> > +}
> > +
> > +static void geneve_uninit(struct net_device *dev)
> > +{
> > +       struct geneve_dev *geneve = netdev_priv(dev);
> > +       struct geneve_sock *gs = geneve->sock;
> > +
> > +       if (gs)
> > +               geneve_sock_release(gs);
> > +       free_percpu(dev->tstats);
> > +}
> 
> 
> Ditto, ndo_stop().

I really don't see the point of the ndo_open/ndo_stop inquiry.
The socket creation seems analagous to device initialization to me.
 
> > +
> > +static int geneve_newlink(struct net *net, struct net_device *dev,
> > +                        struct nlattr *tb[], struct nlattr *data[])
> > +{
> ...
> > +
> > +       if (data[IFLA_GENEVE_REMOTE])
> > +               geneve->remote.sin_addr.s_addr =
> > +                       nla_get_be32(data[IFLA_GENEVE_REMOTE]);
> 
> 
> nla_get_in_addr()

The implementation of that is (not surprisingly) exactly the same
as nla_get_be32.  I'll take it under advisement for a later patch,
but I don't really think a purely cosmetic change should interfere
with getting this merged.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
