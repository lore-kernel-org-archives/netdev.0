From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 5/5] geneve: add initial netdev driver for GENEVE tunnels
Date: Mon, 11 May 2015 11:17:28 -0400
Message-ID: <20150511151728.GB2838@tuxdriver.com>
References: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
 <CAHA+R7MqO2te-OR7mZqdy=TDkrcgyGhb-A4DvbQ07JAaKu49-Q@mail.gmail.com>
 <20150508232236.GO14981@tuxdriver.com>
 <20150510.194830.600095174408470043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cwang@twopensource.com, netdev@vger.kernel.org, jesse@nicira.com,
	azhou@nicira.com, stephen@networkplumber.org,
	alexander.h.duyck@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49206 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbEKPaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:30:17 -0400
Content-Disposition: inline
In-Reply-To: <20150510.194830.600095174408470043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 07:48:30PM -0400, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 8 May 2015 19:22:36 -0400
> 
> > On Fri, May 08, 2015 at 01:55:15PM -0700, Cong Wang wrote:
> >> On Fri, May 8, 2015 at 10:20 AM, John W. Linville
> >> <linville@tuxdriver.com> wrote:
> >> > +
> >> > +/* Setup stats when device is created */
> >> > +static int geneve_init(struct net_device *dev)
> >> > +{
> >> > +       struct geneve_dev *geneve = netdev_priv(dev);
> >> > +
> >> > +       dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> >> > +       if (!dev->tstats)
> >> > +               return -ENOMEM;
> >> > +
> >> > +       /* make new socket outside of RTNL */
> >> > +       dev_hold(dev);
> >> > +       queue_work(geneve_wq, &geneve->sock_work);
> >> > +
> >> 
> >> 
> >> Any reason to create socket in this init() rather than in ndo_open()?
> > 
> > The socket can be created asynchronously and ndo_open can fail if
> > the socket creation hasn't succeeded.
> 
> In what manner is the socket creation asynchronous here?  It
> synchronously returns success or failure as far as I can tell.

Well, I misspoke -- I meant to indicate "outside of RTNL".  But, I
have been bitten again by copying (an older version of) vxlan a bit
too closely.  I don't think I need to worry about the RTNL stuff at
socket open time for this driver.
 
> >> Ditto, ndo_stop().
> > 
> > I really don't see the point of the ndo_open/ndo_stop inquiry.
> > The socket creation seems analagous to device initialization to me.
> 
> It's about resource allocation.
> 
> Even in ethernet drivers, memory allocations such as those done for
> RX and TX rings are done at ->ndo_open and released at ->ndo_stop()
> time.
> 
> Therefore it's sort of reasonable to stretch that idea to how you
> will handle sockets here in the geneve driver.

Sure, thanks for laying it out for me!  I'll rework this bit, and
address some of the other comments raised by Cong Wang and Jesse
Gross and spin a v2.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
