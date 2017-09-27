From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Wed, 27 Sep 2017 09:40:12 +0200
Message-ID: <20170927074012.GA1944@nanopsycho.orion>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
 <20170925170451.GD18763@vergenet.net>
 <20170926121509.50a32571@griffin>
 <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com>
 <20170926145143.28bf52bd@griffin>
 <CAJ3xEMjOkF7vKHY=+q1dHXGdsyEXFPUa6dsGD_-M3+TX=DNouA@mail.gmail.com>
 <1506437410.2643.17.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35173 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdI0HkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 03:40:14 -0400
Received: by mail-wm0-f65.google.com with SMTP id e64so10699952wmi.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 00:40:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1506437410.2643.17.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 26, 2017 at 04:50:10PM CEST, pabeni@redhat.com wrote:
>On Tue, 2017-09-26 at 17:17 +0300, Or Gerlitz wrote:
>> On Tue, Sep 26, 2017 at 3:51 PM, Jiri Benc <jbenc@redhat.com> wrote:
>> > On Tue, 26 Sep 2017 15:41:37 +0300, Or Gerlitz wrote:
>> > > Please note that the way the rule is being set to the HW driver is by delegation
>> > > done in flower, see these commits (specifically "Add offload support
>> > > using egress Hardware device")
>> > 
>> > It's very well possible the bug is somewhere in net/sched.
>> 
>> maybe before/instead you call it a bug, take a look on the design
>> there and maybe
>> tell us how to possibly do that otherwise?
>
>The problem, AFAICT, is in the API between flower and NIC implementing
>the offload, because in the above example the kernel will call the
>offload hook with exactly the same arguments with the 'bad' rule and
>the 'good' one - but the 'bad' rule should never match any packets.
>
>I think that can be fixed changing the flower code to invoke the
>offload hook for filters with tunnel-based match only if the device
>specified in such match has the appropriate type, e.g. given that
>currently only vxlan is supported with something like the code below
>(very rough and untested, just to give the idea):
>
>Cheers,
>
>Paolo
>
>---
>diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>index d230cb4c8094..ff8476e56d4e 100644
>--- a/net/sched/cls_flower.c
>+++ b/net/sched/cls_flower.c
>@@ -243,10 +243,11 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
>                                struct fl_flow_key *mask,
>                                struct cls_fl_filter *f)
> {
>-       struct net_device *dev = tp->q->dev_queue->dev;
>+       struct net_device *ingress_dev, *dev = tp->q->dev_queue->dev;
>        struct tc_cls_flower_offload cls_flower = {};
>        int err;
> 
>+       ingress_dev = dev;
>        if (!tc_can_offload(dev)) {
>                if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
>                    (f->hw_dev && !tc_can_offload(f->hw_dev))) {
>@@ -259,6 +260,12 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
>                f->hw_dev = dev;
>        }
> 
>+       if ((dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_KEYID) ||
>+            dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_PORTS) ||
>+             // ... list all the others tunnel based keys ...
>+             ) && strcmp(ingress_dev->rtnl_link_ops->kind, "vxlan"))
>+               return tc_skip_sw(f->flags) ? -EINVAL : 0;

This kind of hooks are giving me nightmares. The code is screwed up as
it is already. I'm currently working on conversion to callbacks. This
part is handled in:
https://github.com/jpirko/linux_mlxsw/commits/jiri_devel_egdevcb
