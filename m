From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 2/5] bridge: notify ensabled devices of
 headroom changes
Date: Wed, 24 Feb 2016 09:43:54 +0100
Message-ID: <1456303434.5436.10.camel@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	 <060a30aa8e6d2c3eda16dd893b348851cd4bd195.1456163137.git.pabeni@redhat.com>
	 <CAOrHB_Cf6Cnp-r4eMChq=9UeUq_Rg7QG41MiP=HmZFAFaCrUAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbcBXIn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:43:59 -0500
In-Reply-To: <CAOrHB_Cf6Cnp-r4eMChq=9UeUq_Rg7QG41MiP=HmZFAFaCrUAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 11:20 -0800, pravin shelar wrote:
> On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > On bridge needed_headroom changes, the enslaved devices are
> > notified via the ndo_set_rx_headroom method
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/bridge/br_if.c | 36 ++++++++++++++++++++++++++++++++++--
> >  1 file changed, 34 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> > index c367b3e..f42f1da 100644
> > --- a/net/bridge/br_if.c
> > +++ b/net/bridge/br_if.c
> > @@ -223,6 +223,31 @@ static void destroy_nbp_rcu(struct rcu_head *head)
> >         destroy_nbp(p);
> >  }
> >
> > +static unsigned get_max_headroom(struct net_bridge *br)
> > +{
> > +       unsigned max_headroom = 0;
> > +       struct net_bridge_port *p;
> > +
> > +       list_for_each_entry(p, &br->port_list, list) {
> > +               unsigned dev_headroom = netdev_get_fwd_headroom(p->dev);
> > +
> 
> IFF_PHONY_HEADROOM is only set for veth and ovs-internal-device, so we
> can not get headroom for tunnel devices. I guess it worked in your
> tests due to the bug in netdev_get_fwd_headroom().

This code should be actually correct; the idea is to ignore the devices
with phony headroom when computing the maximum headroom; all other
devices should be taken in account.

The current, bugged, netdev_get_fwd_headroom() implementation is
actually the culprit for the confusion.

Paolo
