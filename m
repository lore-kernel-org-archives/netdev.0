From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next v2 2/5] vxlan: support fdb and learning in
 COLLECT_METADATA mode
Date: Fri, 10 Feb 2017 20:05:34 -0800
Message-ID: <CAPWQB7GGEvpjdnU6O6XM6r8MPQGZG1CV6wYdOkX33T6Ja5jtNw@mail.gmail.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <1485932395-58422-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        Thomas Graf <tgraf@suug.ch>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>, pravin shelar <pshelar@ovn.org>,
        David Ahern <dsa@cumulusnetworks.com>, hadi@mojatatu.com,
        Jarno Rajahalme <jarno@ovn.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:52631 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbdBKEGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 23:06:00 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id E9F79C5A44
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 05:05:57 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id YZEoureD4999 for <netdev@vger.kernel.org>;
        Sat, 11 Feb 2017 05:05:56 +0100 (CET)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id D436BC5A43
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 05:05:55 +0100 (CET)
Received: by mail-qk0-f172.google.com with SMTP id s140so58746667qke.0
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 20:05:55 -0800 (PST)
In-Reply-To: <1485932395-58422-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31 January 2017 at 22:59, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> @@ -1289,7 +1331,12 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
>         if (!vs)
>                 goto drop;
>
> -       vxlan = vxlan_vs_find_vni(vs, vxlan_vni(vxlan_hdr(skb)->vx_vni));
> +       vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
> +
> +       if ((vs->flags & VXLAN_F_COLLECT_METADATA) && !vni)
> +               goto drop;
> +
> +       vxlan = vxlan_vs_find_vni(vs, vni);
>         if (!vxlan)
>                 goto drop;

Hi Roopa,

We've noticed a failure in OVS system-traffic kmod test cases and
bisected it down to this commit. It seems that it's related to this
new drop condition here. Can you explain what's meant to be special
about VNI 0? I can't see anything mentioned about it in RFC7348, so I
don't see why it should be dropped.

In the OVS testsuite, we configure OVS in the root namespace with an
OVS vxlan device (which has VXLAN_F_COLLECT_METADATA set), with vni 0.
Then, we configure a veth pair into another namespace where we have
the other end of the tunnel configured using a regular native linux
vxlan device on vni 0. Prior to this commit, the test worked; after
this test it failed. If we manually change to use a nonzero VNI, it
works. The test is here:

https://github.com/openvswitch/ovs/blob/branch-2.7/tests/system-traffic.at#L218

Jarno also tried setting up two namespaces with regular vxlan devices
and VNI 0, and this worked too. Presumably this is because this would
not use VXLAN_F_COLLECT_METADATA.
