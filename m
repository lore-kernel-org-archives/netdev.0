From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 14:31:36 +0200
Message-ID: <1506515496.6840.6.camel@redhat.com>
References: <1506500975.2867.19.camel@redhat.com>
         <20170927091700.GC1944@nanopsycho.orion>
         <1506505618.2867.34.camel@redhat.com>
         <20170927111150.GE1944@nanopsycho.orion>
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
Received: from mx1.redhat.com ([209.132.183.28]:38328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752330AbdI0Mbj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 08:31:39 -0400
In-Reply-To: <20170927111150.GE1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-27 at 13:11 +0200, Jiri Pirko wrote:
> Wed, Sep 27, 2017 at 11:46:58AM CEST, pabeni@redhat.com wrote:
> > On Wed, 2017-09-27 at 11:17 +0200, Jiri Pirko wrote:
> > > Wed, Sep 27, 2017 at 10:29:35AM CEST, pabeni@redhat.com wrote:
> > > > So it looks like the H/W offload hook will still be called with the
> > > > same arguments in both case, and 'bad' rule will still be pushed to the
> > > > H/W as the driver itself has no way to distinct between the two
> > > > scenarios.
> > > 
> > > Why "bad"?
> > 
> > Such rule is coped differently by the SW and the HW data path.
> > 
> > a rule like:
> > 
> > tc filter add dev eth0 protocol ip parent ffff: flower \
> >   enc_key_id 102 enc_dst_port 4789 src_ip 3.4.5.6 skip_hw \
> >   action action mirred redirect eth0_vf_1
> > 
> > will match 0 packets, while:
> > 
> > tc filter add dev eth0 protocol ip parent ffff: flower \
> >   enc_key_id 102 enc_dst_port 4789 src_ip 3.4.5.6 skip_sw \
> >   action action mirred redirect eth0_vf_1
> > 
> > [just flipped 'skip_sw' and 'skip_hw' ]
> > will match the vxlan-tunneled packets. I understand that one of the
> > design goal for the h/w offload path is being consistent with the sw
> > one, but that does not hold in the above scenario.
> 
> Sure, the consistency is important. Howcome "skip_hw" won't match and
> "skip_sw" will match? What's different?

For the SW datapath, we need a metadata based/lwt tunnel to collect the
tunnel information. eth0 is not a such device and does not provide the
metadata. Any match on tunnel based field will fail - correctly.

When the HW datapath is used, the underlaying NIC is programmed exactly
as done when we replace eth0 with vxlan0. The programmed flow matches
vxlan encapsulated traffic.

Cheers,

Paolo
