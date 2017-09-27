From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 17:35:05 +0200
Message-ID: <20170927153505.GL1944@nanopsycho.orion>
References: <1506500975.2867.19.camel@redhat.com>
 <20170927091700.GC1944@nanopsycho.orion>
 <1506505618.2867.34.camel@redhat.com>
 <20170927111150.GE1944@nanopsycho.orion>
 <1506515496.6840.6.camel@redhat.com>
 <20170927125509.GG1944@nanopsycho.orion>
 <20170927172729.5b7a8c44@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>, Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:51440 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdI0PfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 11:35:07 -0400
Received: by mail-wr0-f172.google.com with SMTP id z39so17197568wrb.8
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 08:35:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170927172729.5b7a8c44@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 27, 2017 at 05:27:29PM CEST, jbenc@redhat.com wrote:
>On Wed, 27 Sep 2017 14:55:09 +0200, Jiri Pirko wrote:
>> So where do you attach the tc filter instead of eth0? vxlan0?
>
>Yes, vxlan0. I'm pasting the example from earlier in this thread again:
>
>This will match:
>
>ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
>ip link set dev vxlan0 up
>tc qdisc add dev vxlan0 ingress
>ethtool -K eth0 hw-tc-offload on
>tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 \
>   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]
>
>while this must NOT match:
>
>ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
>ip link set dev vxlan0 up
>tc qdisc add dev eth0 ingress
>ethtool -K eth0 hw-tc-offload on
>tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
>   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

Right. Driver of eth0 should get ndo_setup_tc calls for vxlan0. Similar
thing will be needed for bonding/team. I'm taking this into
considaration for my sharedblock patchset. Work in progress:
https://github.com/jpirko/linux_mlxsw/commits/jiri_devel_shblock
Basically the eth0 driver will register a callback function that would
be called whenever filter is added/deleted on vxlan0
