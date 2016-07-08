From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Fri, 08 Jul 2016 17:33:42 +0200
Message-ID: <1467992022.30694.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1467907022.git.pabeni@redhat.com>
	 <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
	 <1467908002.1273.42.camel@edumazet-glaptop3.roam.corp.google.com>
	 <a7fd6676-4ba5-e1ec-7b57-9b4b7aee24be@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33206 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881AbcGHPdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:33:46 -0400
Received: by mail-pa0-f68.google.com with SMTP id ts6so8107295pac.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 08:33:46 -0700 (PDT)
In-Reply-To: <a7fd6676-4ba5-e1ec-7b57-9b4b7aee24be@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 11:12 -0400, Hannes Frederic Sowa wrote:
> Hi Eric,
> 
> On 07.07.2016 12:13, Eric Dumazet wrote:
> > On Thu, 2016-07-07 at 17:58 +0200, Paolo Abeni wrote:
> >> GRO is now handled entirely by the udp_offload layer and  there is no need
> >> for trying it again at the device level. We can drop gro_cell usage,
> >> simplifying the driver a bit, while maintaining the same performance for
> >> TCP and improving slightly for UDP.
> >> This basically reverts the commit 58ce31cca1ff ("vxlan: GRO support
> >> at tunnel layer")
> > 
> > Note that gro_cells provide GRO support after RPS, so this helps when we
> > must perform TCP checksum computation, if NIC lacks CHECKSUM_COMPLETE
> > 
> > (Say we receive packets all steered to a single RX queue due to RSS hash
> > being computed on outer header only)
> > 
> > Some people disable GRO on the physical device, but enable GRO on the
> > tunnels.
> 
> we are currently discussing your feedback and wonder how much it makes
> sense to support such a scenario?
> 
> We have part of the inner hash in the outer UDP source port. So even the
> outer hash does provide enough entropy to get frames of one tunnel on
> multiple CPUs via hardware hashing - given that you don't care about OoO
> for UDP (I infer that from the fact that RPS will also reorder UDP
> frames in case of fragmentation).
> 
> I wonder why it makes sense to still take single RX queue nics into
> consideration? We already provide support for multiqueue devices for
> most VM-related interfaces as well. Can you describe why someone would
> do such a scenario?

I was simply pointing out there are some use cases where the ability to
split incoming traffic on multiple cpus can help, especially with dumb
NIC.

Fact that GRO is already handled on the NIC itself is not something that
is hard coded. GRO can be enabled or disabled.

If you remove GRO support at tunnel, then you remove some flexibility.

For example, when GRO for GRE was added by Jerry Chu, we did not remove
GRO on GRE devices, because mlx4 NICs for example are unable to compute
TCP checksum when GRE encapsulation is used. A single CPU can not decap
at line rate on 40Gbit NIC without RX checksum offloading. An admin can
choose to use RPS to  split traffic coming on a single RX queue to X
cpus, and enable GRO after RPS, instead of before.

UDP might be different, if the sender properly adds entropy on outer
header (which is not something you can do with GRE)

You probably could default GRO on tunnels to off, since by default GRO
would already happen at the physical interface.
