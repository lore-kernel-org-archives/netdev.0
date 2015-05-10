From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Sun, 10 May 2015 19:48:30 -0400 (EDT)
Message-ID: <20150510.194830.600095174408470043.davem@davemloft.net>
References: <1431105657-25492-6-git-send-email-linville@tuxdriver.com>
	<CAHA+R7MqO2te-OR7mZqdy=TDkrcgyGhb-A4DvbQ07JAaKu49-Q@mail.gmail.com>
	<20150508232236.GO14981@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org, jesse@nicira.com,
	azhou@nicira.com, stephen@networkplumber.org,
	alexander.h.duyck@redhat.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbbEJXsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 19:48:32 -0400
In-Reply-To: <20150508232236.GO14981@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 8 May 2015 19:22:36 -0400

> On Fri, May 08, 2015 at 01:55:15PM -0700, Cong Wang wrote:
>> On Fri, May 8, 2015 at 10:20 AM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > +
>> > +/* Setup stats when device is created */
>> > +static int geneve_init(struct net_device *dev)
>> > +{
>> > +       struct geneve_dev *geneve = netdev_priv(dev);
>> > +
>> > +       dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
>> > +       if (!dev->tstats)
>> > +               return -ENOMEM;
>> > +
>> > +       /* make new socket outside of RTNL */
>> > +       dev_hold(dev);
>> > +       queue_work(geneve_wq, &geneve->sock_work);
>> > +
>> 
>> 
>> Any reason to create socket in this init() rather than in ndo_open()?
> 
> The socket can be created asynchronously and ndo_open can fail if
> the socket creation hasn't succeeded.

In what manner is the socket creation asynchronous here?  It
synchronously returns success or failure as far as I can tell.

>> Ditto, ndo_stop().
> 
> I really don't see the point of the ndo_open/ndo_stop inquiry.
> The socket creation seems analagous to device initialization to me.

It's about resource allocation.

Even in ethernet drivers, memory allocations such as those done for
RX and TX rings are done at ->ndo_open and released at ->ndo_stop()
time.

Therefore it's sort of reasonable to stretch that idea to how you
will handle sockets here in the geneve driver.
