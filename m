From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH v5 2/2] net_sched: implement a root
 container qdisc sch_mqprio
Date: Wed, 5 Jan 2011 09:47:23 -0800
Message-ID: <20110105094723.63d249a6@nehalam>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
	<20110104185646.13692.68146.stgit@jf-dev1-dcblab>
	<20110104225936.GA2030@del.dom.local>
	<4D24ACA4.3000301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45255 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab1AERr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 12:47:26 -0500
In-Reply-To: <4D24ACA4.3000301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 09:38:44 -0800
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 1/4/2011 2:59 PM, Jarek Poplawski wrote:
> > On Tue, Jan 04, 2011 at 10:56:46AM -0800, John Fastabend wrote:
> >> This implements a mqprio queueing discipline that by default creates
> >> a pfifo_fast qdisc per tx queue and provides the needed configuration
> >> interface.
> >>
> >> Using the mqprio qdisc the number of tcs currently in use along
> >> with the range of queues alloted to each class can be configured. By
> >> default skbs are mapped to traffic classes using the skb priority.
> >> This mapping is configurable.
> >>
> >> Configurable parameters,
> >>
> >> struct tc_mqprio_qopt {
> >>         __u8    num_tc;
> >>         __u8    prio_tc_map[TC_BITMASK + 1];
> >>         __u8    hw;
> >>         __u16   count[TC_MAX_QUEUE];
> >>         __u16   offset[TC_MAX_QUEUE];
> >> };
> >>
> >> Here the count/offset pairing give the queue alignment and the
> >> prio_tc_map gives the mapping from skb->priority to tc.
> >>
> >> The hw bit determines if the hardware should configure the count
> >> and offset values. If the hardware bit is set then the operation
> >> will fail if the hardware does not implement the ndo_setup_tc
> >> operation. This is to avoid undetermined states where the hardware
> >> may or may not control the queue mapping. Also minimal bounds
> >> checking is done on the count/offset to verify a queue does not
> >> exceed num_tx_queues and that queue ranges do not overlap. Otherwise
> >> it is left to user policy or hardware configuration to create
> >> useful mappings.
> >>
> >> It is expected that hardware QOS schemes can be implemented by
> >> creating appropriate mappings of queues in ndo_tc_setup().
> >>
> >> One expected use case is drivers will use the ndo_setup_tc to map
> >> queue ranges onto 802.1Q traffic classes. This provides a generic
> >> mechanism to map network traffic onto these traffic classes and
> >> removes the need for lower layer drivers to know specifics about
> >> traffic types.
> >>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >> ---
> >>
> >>  include/linux/netdevice.h |    3
> >>  include/linux/pkt_sched.h |   10 +
> >>  net/sched/Kconfig         |   12 +
> >>  net/sched/Makefile        |    1
> >>  net/sched/sch_generic.c   |    4
> >>  net/sched/sch_mqprio.c    |  413 +++++++++++++++++++++++++++++++++++++++++++++
> >>  6 files changed, 443 insertions(+), 0 deletions(-)
> >>  create mode 100644 net/sched/sch_mqprio.c
> >>
> >> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >> index ae51323..19a855b 100644
> >> --- a/include/linux/netdevice.h
> >> +++ b/include/linux/netdevice.h
> >> @@ -764,6 +764,8 @@ struct netdev_tc_txq {
> >>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
> >>   *                     struct nlattr *port[]);
> >>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
> >> + *
> >> + * int (*ndo_setup_tc)(struct net_device *dev, int tc);
> >
> >  * int (*ndo_setup_tc)(struct net_device *dev, u8 tc);
> >
> >>   */
> >>  #define HAVE_NET_DEVICE_OPS
> >>  struct net_device_ops {
> >> @@ -822,6 +824,7 @@ struct net_device_ops {
> >>                                                  struct nlattr *port[]);
> >>       int                     (*ndo_get_vf_port)(struct net_device *dev,
> >>                                                  int vf, struct sk_buff *skb);
> >> +     int                     (*ndo_setup_tc)(struct net_device *dev, u8 tc);
> >>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
> >>       int                     (*ndo_fcoe_enable)(struct net_device *dev);
> >>       int                     (*ndo_fcoe_disable)(struct net_device *dev);
> >> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> >> index 2cfa4bc..1c5310a 100644
> >> --- a/include/linux/pkt_sched.h
> >> +++ b/include/linux/pkt_sched.h
> >> @@ -2,6 +2,7 @@
> >>  #define __LINUX_PKT_SCHED_H
> >>
> >>  #include <linux/types.h>
> >> +#include <linux/netdevice.h>
> >

This won't be acceptable.

All the TC api needs to be in linux/pkt_sched.h.

I regularly take the sanitized headers from kernel version an put them
in iproute2 source.



-- 
