From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked
 on real device
Date: Wed, 22 Jun 2016 14:21:29 +0200
Message-ID: <1466598089.4707.31.camel@redhat.com>
References: <3d191a3c51bd564da8b0c3ffe1e9c90fa7bd4d7b.1466590952.git.pabeni@redhat.com>
	 <20160622105544.GC2068@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbcFVMWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 08:22:20 -0400
In-Reply-To: <20160622105544.GC2068@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 12:55 +0200, Jiri Pirko wrote:
> Wed, Jun 22, 2016 at 12:25:15PM CEST, pabeni@redhat.com wrote:
> >Before the commit 0dfe17823945 ("net: vlan: goto another_round
> >instead of calling __netif_receive_skb"), on tagged skb ingress,
> >ptype specific protocol matches were delivered only to the
> >related vlan device, if any.
> >After said commit, jumping back to the 'another_round' label, allows
> >the later ptype specific check to match both orig_dev and skb->dev,
> >delivering the skb to both the vlan device and the underlying
> >device.
> >This cause i.e. packet sockets bound to a specific protocol type on
> >one of said devices to receive also frames really targeting the
> >other device.
> >This commit resets orig_dev before performing another round due to
> >vlan processing, allowing the skb to be delivered once again only
> >to the vlan specific ptypes.
> 
> I don't get why vlan should behave differently in this comparing to
> other stacked devices like bond/team/br etc.
> 
> Could you please explain?

vlan behavior has changed with the commit 0dfe17823945 (which is old,
but still...), this patch is trying to restore the old one.

The new behavior fouls existing applications which where expecting ptype
specific match to be delivered only on the relevant device. 

AFAIC jumping back to the 'another_round' is possible for team, bond,
macvlan, macsec and ipvlan device, beyond vlan devices. I think the
latter should be treated differently, beyond history reasons, because
the vlan device processing, stripping the vlan tag, actually changes the
ethernet type present into the ethernet header in respect to the wire
packet layout; strict match on that value should give different results
before and after vlan stripping.

Paolo
