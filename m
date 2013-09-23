From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Mon, 23 Sep 2013 12:47:23 -0700
Message-ID: <CALnjE+o_bcNbU6kv2eUBaNS4tincV+BmrFyJtZZRTaMPMVv8gw@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
	<CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
	<20130918220756.GA24919@verge.net.au>
	<CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
	<20130922053800.GA4890@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:50864 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752875Ab3IWTrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:47:45 -0400
Received: by mail-qa0-f46.google.com with SMTP id j7so1829348qaq.12
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 12:47:44 -0700 (PDT)
In-Reply-To: <20130922053800.GA4890@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 10:38 PM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Sep 19, 2013 at 12:31:51PM -0500, Jesse Gross wrote:
>> On Wed, Sep 18, 2013 at 5:07 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
>> >> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> > diff --git a/datapath/datapath.h b/datapath/datapath.h
>> >> > index 5d50dd4..babae3b 100644
>> >> > --- a/datapath/datapath.h
>> >> > +++ b/datapath/datapath.h
>> >> > @@ -36,6 +36,10 @@
>> >> >
>> >> >  #define SAMPLE_ACTION_DEPTH 3
>> >> >
>> >> > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
>> >> > +#define HAVE_INNER_PROTOCOL
>> >> > +#endif
>> >> > +
>> >> >  /**
>> >> >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
>> >> >   * datapath.
>> >> > @@ -93,11 +97,16 @@ struct datapath {
>> >> >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
>> >> >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
>> >> >   * packet is not being tunneled.
>> >> > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
>> >> > + * kernels before 3.11.
>> >> >   */
>> >> >  struct ovs_skb_cb {
>> >> >         struct sw_flow          *flow;
>> >> >         struct sw_flow_key      *pkt_key;
>> >> >         struct ovs_key_ipv4_tunnel  *tun_key;
>> >> > +#ifndef HAVE_INNER_PROTOCOL
>> >> > +       __be16                  inner_protocol;
>> >> > +#endif
>> >> >  };
>> >> >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
>> >> >
>> >> Can you move this to compat struct ovs_gso_cb {}
>> >
>> > I think that you are correct and inner_protocol needs
>> > to be in struct ovs_gso_cb so that it can
>> > be accessed via skb_network_protocol() from
>> > rpl___skb_gso_segment().
>> >
>> > However I think it may also need to be present in struct ovs_cb
>> > so that it can be set correctly.
>> >
>> > Currently it is set unconditionally
>> > in ovs_execute_actions() and Jesse has suggested setting
>> > it conditionally in pop_mpls() (which is called by do_execute_actions()).
>> > But regardless it seems to me that the field would need to be available
>> > in struct ovs_cb.
>>
>> Since the helper functions are also in the compat code, I think they
>> should have access to ovs_gso_cb.
>
> Pravin also believes that is the case so I have moved inner_protocol
> to struct ovs_gso_cb as he requested.
>
>> >> I think we can simplify code by pushing vlan and then segmenting skb,
>> >> the way we do it for MPLS.
>> >
>> > Are you thinking of something like the following which applies
>> > prior to the MPLS code.
>>
>> This is basically what I was thinking about. We might actually be able
>> to move all of this to compat code by having a replacement for
>> dev_queue_xmit() similar to what we have for ip_local_out() in the
>> tunnel code.
>
> I would appreciate Pravin's opinion on this but it seems to me
> that it should be possible.
>
> The following applies on top of my previous proposed change
> in this thread - simplification of segmentation - and before
> the MPLS patch-set. Is this along the lines of what you were
> thinking of?
>
>
> From: Simon Horman <horms@verge.net.au>
>
> datapath: Move segmentation compatibility code into a compatibility function
>
> *** Do not apply: for informational purposes only
>
> Move segmentation compatibility code out of netdev_send and into
> rpl_dev_queue_xmit(), a compatibility function used in place
> of dev_queue_xmit() as necessary.
>
> As suggested by Jesse Gross.
>
> Some minor though verbose implementation notes:
>
> * This rpl_dev_queue_xmit() endeavours to return a valid error code or
>   zero on success as per dev_queue_xmit(). The exception is that when
>   dev_queue_xmit() is called in a loop only the status of the last call is
>   taken into account, thus ignoring any errors returned by previous calls.
>   This is derived from the previous calls to dev_queue_xmit() in a loop
>   where netdev_send() ignores the return value of dev_queue_xmit()
>   entirely.
>
> * netdev_send() continues to ignore the value of dev_queue_xmit().
>   So the discussion of the return value of rpl_dev_queue_xmit()
>   above is has no bearing on run-time behaviour.
>
> * The return value of netdev_send() may differ from the previous
>   implementation in the case where segmentation is performed before
>   calling the real dev_queue_xmit(). This is because previously in
>   this case netdev_send() would return the combined length of the
>   skbs resulting from segmentation. Whereas the current code
>   always returns the length of the original skb.

This approach looks good to me.

>
> Compile tested only.
>
This patch does not work since vport-netdev does not include compat
gso header. after including gso.h it gives me compiler error.
Can you post combined patch with fixes?

It is better to move rpl_dev_queue_xmit definition from gso.h to
linux/netdevice.h.

Thanks.
