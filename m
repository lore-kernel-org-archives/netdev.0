From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Wed, 06 Sep 2017 11:37:54 +0200
Message-ID: <87bmmo9ngt.fsf@stressinduktion.org>
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
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5D2E@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5D2E-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
	(Jan Scheurich's message of "Wed, 6 Sep 2017 08:27:00 +0000")
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

Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org> writes:

>> >> Yes, I wrote that in my previous mail. I wonder why NSH context metadata
>> >> is not in tun_metadata as well?
>> >
>> > tun_metadata is tunnel metadata, GENEVE needs tunnel port, but NSH is
>> > not so, NSH can't directly use tun_metadata, for MD type 2, we need to a
>> > lot of rework on tun_metadata to make it shared between GENEVE and NSH,
>> > I don't think this can happen in near term. So tun_metadata isn't option
>> > for this now.
>> 
>> Sorry, I couldn't follow you. Why can't you store the context headers in
>> tun_metadata exactly?
>> 
>
> I think we mixing things. Let me try to clarify:
>
> 1. NSH context metadata has end-to-end significance for the SFP. They
> must be part of the NSH header and cannot be transported as tunnel
> metadata, because transport tunnels (e.g. Geneve) only connect pairs
> of SFFs in the path.

No questions asked. I am not talking about a design choice of the
protocol but an implementation detail of the patch.

> So we need OVS to be able to match on and set NSH context header
> fields, also for MD2 TLVs in the future.

So be it.

> 2. OVS today has support for matching on TLV tunnel metadata after
> termination of a Geneve tunnel. This infrastructure is only usable for
> OVS tunnel ports (like Geneve) but not for matching on TLV headers of
> the NSH protocol, which is not modelled as an OVS tunnel port but
> handled in the OpenFlow pipeline (with generic encp/decap actions to
> enter/terminate an NSH SFP). This was a strategic decision by the OVS
> community two years ago.

I am talking about the tun_opts field in the sw_flow_keys structure for
the kernel dp only.

> There is no way we can re-use the existing TLV tunnel metadata
> infrastructure in OVS for matching and setting NSH MD2 TLV headers. We
> will need to introduce a new (perhaps similar) scheme for modelling
> generic TLV match registers in OVS that are assigned to protocol TLVs
> by the controller. This is FFS.

This is what I don't understand.

Why can't you just reuse the space in the struct sw_flow_key where
geneve would put in their metadata. There are 255 empty bytes at the
beginning if you don't have other tunnel metadata anyway.

If you receive packets over vxlan(gpe), tun_opts gets populated with an
ip_tunnel_key. Couldn't you use the options space in there after the
ip_tunnel_key to store the NSH context just for the sake of storing them
somewhere instead of adding 16 bytes to sw_flow_key?

Thanks,
Hannes
