From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is
 permitted on ingress
Date: Thu, 20 Dec 2012 22:13:32 +0200
Message-ID: <20121220221332.103cd142.shmulik.ladkani@gmail.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-4-git-send-email-vyasevic@redhat.com>
	<20121220160713.30cdfc05@pixies.home.jungo.com>
	<50D331A8.3080206@redhat.com>
	<20121220182402.6143fcb1@pixies.home.jungo.com>
	<50D342B7.9010901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f193.google.com ([74.125.82.193]:35017 "EHLO
	mail-we0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab2LTUOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 15:14:25 -0500
Received: by mail-we0-f193.google.com with SMTP id r1so729458wey.0
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 12:14:24 -0800 (PST)
In-Reply-To: <50D342B7.9010901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Thu, 20 Dec 2012 11:54:15 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> > (2) frame ingress on a "non-vlan" port may egress on a "vlan enabled"
> >    port, depending on the ingress VID and the port-membership map of the
> >    egress port
> >    (and thus, PVID should be defined even to "non-vlan" ports, for the
> >    case where untagged frame is received on the non-vlan port)
> 
> Sort of.  The way I did it (testing now), is like this:
>     if there is egress policy
> 	apply policy and forward.
>     else if there was ingress policy (pvid)
> 	apply it and forward
>     else
> 	forward as is (old bridge behavior).
> 
> This way if there was a pvid on an ingress port and nothing on egress,
> then pvid applies.  If there was nothing configured on ingress port,
> but we have a egress policy, we'll apply any vlan information from
> the frame to egress policy.  In this case, ingress untagged traffic 
> would be assigned vlan 0.

Sorry, got too cryptic too me ;)
We're probably aligned, but if you don't mind I'd like to make sure I
got it right.

I'd expect the following logic if the bridge is a vlan bridge:

1. Frame ingress on a port
  Frame's VID is collected: if frame was tagged, its the VID found in
  the tag; if frame was untagged (or prio-tagged), the VID would be
  port's PVID.
2. Ingress membership verification
  Verify the ingress port is a member of the frame's VID vlan (collected
  on step 1).
  (Usually policy is 'drop' in case port is not a member).
  Easily calculated by testing if the port bit is set in vlan's port
  membership map.
3. Switching logic
  Consult FDB for a forward/flood/drop decision, resulting in a map of
  candidate ports the frame might egress upon (e.g. in the common case,
  a valid existing unicast entry, the result is just one candidate
  port).
4. Egress membership verification
  For each candidate port found on step 3, verify it is a member of the
  frame's VID vlan.
  (Usually, candidate ports that aren't members of the vlan will not be
  selected for actual egress).
  This can be easily calculated by masking the candidates port map
  (found on step 3) with the vlan's port membership map. The resulting
  masked map is final egress portmap.
5. Frame tag construction and egress 
  For each final egress port (found on step 4), verify its
  tagged/untagged policy in the vlan's egress-policy map.
  Properly add/remove the vlan tag (if needed) according to port's
  egress policy, and transmit.

To my best understanding, if all the ports are "vlan-enabled" (having a
non-empty vid list, i.e. belonging to at least one vlan), the behavior
of the implemented bridge is aligned with the above scheme.

For "non-vlan" ports (having en empty vid list), we treat them as if
they belong to ANY POSSIBLE vlan (as if their bit is always set in every
vlan port membeship map). Meaning, in step (2) verification always
suceeds for such ports, and in step (4) such ports will never be masked
out of the egress candidates portmap.

Please let me know if the implementation fits this.

> I'll try to document things sufficiently.  This hybrid approach may
> produce some unintended results.  We could always remove it or introduce
> the tunable to change default policy to drop once vlan configuration is
> in effect.

Ok.

Regards,
Shmulik
