From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 11:46:58 +0200
Message-ID: <1506505618.2867.34.camel@redhat.com>
References: <1506500975.2867.19.camel@redhat.com>
         <20170927091700.GC1944@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48665 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752531AbdI0JrB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 05:47:01 -0400
In-Reply-To: <20170927091700.GC1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-27 at 11:17 +0200, Jiri Pirko wrote:
> Wed, Sep 27, 2017 at 10:29:35AM CEST, pabeni@redhat.com wrote:
> > So it looks like the H/W offload hook will still be called with the
> > same arguments in both case, and 'bad' rule will still be pushed to the
> > H/W as the driver itself has no way to distinct between the two
> > scenarios.
> 
> Why "bad"?

Such rule is coped differently by the SW and the HW data path.

a rule like:

tc filter add dev eth0 protocol ip parent ffff: flower \
   enc_key_id 102 enc_dst_port 4789 src_ip 3.4.5.6 skip_hw \
   action action mirred redirect eth0_vf_1

will match 0 packets, while:

tc filter add dev eth0 protocol ip parent ffff: flower \
   enc_key_id 102 enc_dst_port 4789 src_ip 3.4.5.6 skip_sw \
   action action mirred redirect eth0_vf_1

[just flipped 'skip_sw' and 'skip_hw' ]
will match the vxlan-tunneled packets. I understand that one of the
design goal for the h/w offload path is being consistent with the sw
one, but that does not hold in the above scenario.

> Regarding the distinction, driver knows if user add a rule directly to
> the eth0, or if the eth0 is egress device in the action. Those are 2
> separete driver entrypoints - of course, talking about code with my
> changes.

ok, but than each driver should catch the scenario "rule with tunnel
match over non tunnel device" and cope with them properly - never match
it - why don't simply avoiding pushing such rules to the H/W ? 

Cheers,

Paolo
