From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Fri, 29 Sep 2017 07:27:11 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7881A37D@ESESSMB107.ericsson.se>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
	<20170925201439.08460295@griffin>
	<20170926045538.GA5896@localhost.localdomain>
	<20170926124914.60101ca1@griffin>
	<20170927013908.GA33716@localhost.localdomain>
	<CAOrHB_CQyokdTWeoj02RENPP5miq5Arx6goCNQ9ZPbUeTu_MeQ@mail.gmail.com>
	<20170929064058.GA16145@localhost.localdomain>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7881A337@ESESSMB107.ericsson.se>
	<20170929071553.GA19053@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170929071553.GA19053-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> > The optimization Yi refers to only affects the slow path translation.
> >
> > OVS 2.8 does not immediately trigger an immediate recirculation after translating
> > encap(nsh,...). There is no need to do so as the flow key of the resulting packet
> > can be determined from the encap() action and its properties. Translation
> > continues with the rewritten flow key and subsequent OpenFlow actions will
> > typically set the new fields in the new NSH header. The push_nsh datapath action
> > (including all NSH header fields) is only generated at the next commit, e.g. for
> > output, cloning, recirculation, encap/decap or another destructive change of
> > the flow key.
> >
> > The implementation of push_nsh in the user-space datapath does not update
> > the miniflow (key) of the packet, only the packet data and some metadata.
> > If the packet needs to be looked up again the slow path triggers recirculation
> > to re-parse the packet. There should be no need for the datapath push_nsh
> > action to try to update the flow key.
> 
> Thanks Jan for clarification, it can still work after removing that
> line, our flows didn't match it after push_nsh, it is output to
> VxLAN-gpe port after push_nsh, I'm not sure if we can match dl_type and NSH
> fields if we don't output and don't recirculate.

No worries, a packet cannot be matched again in the datapath unless it is 
recirculated. And recirculation today always implies re-parsing. 

In the future we want to look into possibilities to optimize performance of 
recirculation, for example by skipping the parsing stage if it is unnecessary.
For that we may need to invalidate the flow key in packet metadata when
the packet is modified without corresponding update of the key itself. But that
is music of the future.

/Jan
