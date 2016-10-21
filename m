From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v12 5/9] openvswitch: add processing of L3
 packets
Date: Fri, 21 Oct 2016 13:59:16 +0200
Message-ID: <20161021135916.790e66ac@griffin>
References: <cover.1476708212.git.jbenc@redhat.com>
        <a4590d690c169e0021031405463c8629a6e9ecb8.1476708213.git.jbenc@redhat.com>
        <CAOrHB_Co3DaYJPbrcDRrnQ1P18X9B=n867uWEiaFqJcKPHs=2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755423AbcJUL7V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 07:59:21 -0400
In-Reply-To: <CAOrHB_Co3DaYJPbrcDRrnQ1P18X9B=n867uWEiaFqJcKPHs=2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Oct 2016 21:19:14 -0700, Pravin Shelar wrote:
> On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > @@ -609,8 +597,10 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
> >
> >         err = ovs_flow_key_extract_userspace(net, a[OVS_PACKET_ATTR_KEY],
> >                                              packet, &flow->key, log);
> > -       if (err)
> > +       if (err) {
> > +               packet = NULL;
> >                 goto err_flow_free;
> > +       }
> >
> Why packet is set to NULL? This would leak skb memory in case of error.

Leftover from the times when this was based on top of the patchset that
unified vlan handling. Thanks for catching it.

> > +static u8 key_extract_mac_proto(struct sk_buff *skb)
> > +{
> > +       switch (skb->dev->type) {
> > +       case ARPHRD_ETHER:
> > +               return MAC_PROTO_ETHERNET;
> > +       case ARPHRD_NONE:
> > +               if (skb->protocol == htons(ETH_P_TEB))
> > +                       return MAC_PROTO_ETHERNET;
> > +               return MAC_PROTO_NONE;
> > +       }
> > +       WARN_ON_ONCE(1);
> > +       return MAC_PROTO_ETHERNET;
> This packet should be dropped.

This should never happen, I put WARN_ON_ONCE there to catch impossible
to happen bugs (and BUG_ON is really too strong here). But sure, why
not, will drop the packet in v13.

> > +       switch (vport->dev->type) {
> > +       case ARPHRD_NONE:
> > +               if (mac_proto != MAC_PROTO_NONE) {
> > +                       WARN_ON_ONCE(mac_proto != MAC_PROTO_ETHERNET);
> > +
> It would be easy to read if you check mac_proto for MAC_PROTO_ETHERNET
> and then warn otherwise.

Okay.

> another issue is the packet is not dropped if mac_proto is not
> MAC_PROTO_ETHERNET

Likewise, impossible to happen, but will drop the packet.

Thanks,

 Jiri
