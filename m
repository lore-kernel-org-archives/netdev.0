From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 3/5] ovs: propagate per dp max headroom to all
 vports
Date: Wed, 24 Feb 2016 09:59:07 +0100
Message-ID: <1456304347.5436.21.camel@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	 <4d34406afd196957f32adb69eae3489a05c34086.1456163137.git.pabeni@redhat.com>
	 <CAOrHB_DL0ALY64VWtKGQCY8efxFHEz1DsKzVGvbGk+8q=j1kzQ@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:57960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755628AbcBXI7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:59:12 -0500
In-Reply-To: <CAOrHB_DL0ALY64VWtKGQCY8efxFHEz1DsKzVGvbGk+8q=j1kzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 11:20 -0800, pravin shelar wrote:
> On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > This patch implements bookkeeping support to compute the maximum
> > headroom for all the devices in each datapath. When said value
> > changes, the underlying devs are notified via the
> > ndo_set_rx_headroom method.
> >
> > This also increases the internal vports xmit performance.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/openvswitch/datapath.c           | 48 ++++++++++++++++++++++++++++++++++++
> >  net/openvswitch/datapath.h           |  4 +++
> >  net/openvswitch/vport-internal_dev.c | 10 +++++++-
> >  3 files changed, 61 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> > index c4e8455..7b37288 100644
> > --- a/net/openvswitch/datapath.c
> > +++ b/net/openvswitch/datapath.c
> > @@ -1908,6 +1908,34 @@ static struct vport *lookup_vport(struct net *net,
> >                 return ERR_PTR(-EINVAL);
> >  }
> >
> > +/* Called with ovs_mutex */
> > +static void update_headroom(struct datapath *dp)
> > +{
> > +       int i;
> > +       struct vport *vport;
> > +       struct net_device *dev;
> > +       unsigned dev_headroom, max_headroom = 0;
> > +
> > +       for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
> > +               hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
> > +                       dev = vport->dev;
> > +                       dev_headroom = netdev_get_fwd_headroom(dev);
> > +                       if (dev_headroom > max_headroom)
> > +                               max_headroom = dev_headroom;
> > +               }
> > +       }
> > +
> > +       dp->max_headroom = max_headroom;
> > +       for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
> > +               hlist_for_each_entry_rcu(vport, &dp->ports[i], dp_hash_node) {
> > +                       dev = vport->dev;
> > +                       if (dev->netdev_ops->ndo_set_rx_headroom)
> > +                               dev->netdev_ops->ndo_set_rx_headroom(dev,
> > +                                                                 max_headroom);
> > +               }
> > +       }
> > +}
> > +
> Code looks fine. But It could be kept in sync with bridge code from patch 2.

You are right. 

I can had an helper to wrap the conditional ndo_set_rx_headroom()
invocation, so that all the code here and in the bridge will be devices
traversal only.

Paolo
