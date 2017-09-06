From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Wed, 6 Sep 2017 08:27:00 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5D2E@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<20170905113848.GC92895@cran64.bj.intel.com>
	<878thtmgra.fsf@stressinduktion.org>
	<20170906005359.GA103260@cran64.bj.intel.com>
	<87o9qo9ru6.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"e@erig.me" <e@erig.me>, "jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>, "Yang, Yi"
	<yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <87o9qo9ru6.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
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

> >> Yes, I wrote that in my previous mail. I wonder why NSH context metadata
> >> is not in tun_metadata as well?
> >
> > tun_metadata is tunnel metadata, GENEVE needs tunnel port, but NSH is
> > not so, NSH can't directly use tun_metadata, for MD type 2, we need to a
> > lot of rework on tun_metadata to make it shared between GENEVE and NSH,
> > I don't think this can happen in near term. So tun_metadata isn't option
> > for this now.
> 
> Sorry, I couldn't follow you. Why can't you store the context headers in
> tun_metadata exactly?
> 

I think we mixing things. Let me try to clarify:

1. NSH context metadata has end-to-end significance for the SFP. They must be part of the NSH header and cannot be transported as tunnel metadata, because transport tunnels (e.g. Geneve) only connect pairs of SFFs in the path. So we need OVS to be able to match on and set NSH context header fields, also for MD2 TLVs in the future. 

2. OVS today has support for matching on TLV tunnel metadata after termination of a Geneve tunnel. This infrastructure is only usable for OVS tunnel ports (like Geneve) but not for matching on TLV headers of the NSH protocol, which is not modelled as an OVS tunnel port but handled in the OpenFlow pipeline (with generic encp/decap actions to enter/terminate an NSH SFP). This was a strategic decision by the OVS community two years ago.

There is no way we can re-use the existing TLV tunnel metadata infrastructure in OVS for matching and setting NSH MD2 TLV headers. We will need to introduce a new (perhaps similar) scheme for modelling generic TLV match registers in OVS that are assigned to protocol TLVs by the controller. This is FFS.

BR, Jan
