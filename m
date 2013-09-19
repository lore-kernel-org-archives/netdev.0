From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Thu, 19 Sep 2013 12:31:51 -0500
Message-ID: <CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au> <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
 <20130918220756.GA24919@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:59127 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751157Ab3ISRcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 13:32:19 -0400
Received: by mail-ie0-f175.google.com with SMTP id e14so15578561iej.20
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 10:32:12 -0700 (PDT)
In-Reply-To: <20130918220756.GA24919@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 18, 2013 at 5:07 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
>> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
>> > diff --git a/datapath/datapath.h b/datapath/datapath.h
>> > index 5d50dd4..babae3b 100644
>> > --- a/datapath/datapath.h
>> > +++ b/datapath/datapath.h
>> > @@ -36,6 +36,10 @@
>> >
>> >  #define SAMPLE_ACTION_DEPTH 3
>> >
>> > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
>> > +#define HAVE_INNER_PROTOCOL
>> > +#endif
>> > +
>> >  /**
>> >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
>> >   * datapath.
>> > @@ -93,11 +97,16 @@ struct datapath {
>> >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
>> >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
>> >   * packet is not being tunneled.
>> > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
>> > + * kernels before 3.11.
>> >   */
>> >  struct ovs_skb_cb {
>> >         struct sw_flow          *flow;
>> >         struct sw_flow_key      *pkt_key;
>> >         struct ovs_key_ipv4_tunnel  *tun_key;
>> > +#ifndef HAVE_INNER_PROTOCOL
>> > +       __be16                  inner_protocol;
>> > +#endif
>> >  };
>> >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
>> >
>> Can you move this to compat struct ovs_gso_cb {}
>
> I think that you are correct and inner_protocol needs
> to be in struct ovs_gso_cb so that it can
> be accessed via skb_network_protocol() from
> rpl___skb_gso_segment().
>
> However I think it may also need to be present in struct ovs_cb
> so that it can be set correctly.
>
> Currently it is set unconditionally
> in ovs_execute_actions() and Jesse has suggested setting
> it conditionally in pop_mpls() (which is called by do_execute_actions()).
> But regardless it seems to me that the field would need to be available
> in struct ovs_cb.

Since the helper functions are also in the compat code, I think they
should have access to ovs_gso_cb.

>> I think we can simplify code by pushing vlan and then segmenting skb,
>> the way we do it for MPLS.
>
> Are you thinking of something like the following which applies
> prior to the MPLS code.

This is basically what I was thinking about. We might actually be able
to move all of this to compat code by having a replacement for
dev_queue_xmit() similar to what we have for ip_local_out() in the
tunnel code.
