From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next V3 3/7] net/sched: Reflect HW offload status
Date: Thu, 16 Feb 2017 10:17:44 +0200
Message-ID: <20170216081744.GA8800@splinter.mtl.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
 <1487148757-24809-4-git-send-email-ogerlitz@mellanox.com>
 <CAJ3xEMg32qMp0Hh+BQbHdoMCKwX_ivvZVwo30njvXubR7ZQ8xA@mail.gmail.com>
 <20170215102821.12f419e7@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:43263 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750718AbdBPIRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 03:17:47 -0500
Content-Disposition: inline
In-Reply-To: <20170215102821.12f419e7@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 10:28:21AM -0800, Jakub Kicinski wrote:
> What worries me is that the moment we started offloading packet
> modification we run at the risk of modifying packets twice.  This used
> to be a problem only for eBPF but now mlx5 can also offload things like
> ttl decrement.  For filters which have no skip_* flags set and get
> offloaded if packet doesn't get redirected or modified significantly it
> will match the filter both in HW and on the host and therefore have the
> actions applied twice.  And it will get counted twice.  (It seems nobody
> ever raised this so perhaps I'm mistaken in thinking that this can
> happen?)

FWIW, we already have that problem with bridge offload. There are some
packets that you can easily forward in hardware, but still wants the
software bridge to receive a copy. IGMP queries for example. These
should be flooded to all ports in the bridge, so we do the forwarding in
hardware, but send a copy to the bridge driver for it to mark the
receiving port as an mrouter port.

To prevent the packet from being flooded twice, we set
'skb->offload_fwd_mark' inside the driver and have the bridge driver
check it during its egress check. It's a bit more involved if you've
several ASICs in the same bridge, but that's the gist. See commit
6bc506b4fb06 ("bridge: switchdev: Add forward mark support for stacked
devices") for more details.

> Back to your patch set, I was hoping we will be able to use the new
> IN_HW flag to skip filters in software even if they don't have skip_sw
> set.  If we need to eject actions from HW based on external events, that
> obviously complicates things.  Three trivial solutions to the problem
> I could think of are:

[...]

>  - use one of recently freed skb TC bits to mark packets which were
>    supposed to be processed in HW by could not as needing software
>    fallback (I think this could work for you without parsing the packet
>    in the driver, you could replace the tunnel action with mark action
>    and leave the matching rule in HW classifier/TCAM; for BPF I have a
>    descriptor flag telling me if offloaded BPF completed successfully).

This is similar to what I described above. The tricky part is correctly
marking the packet. In mlxsw, for each received packet we get the trap
ID in the DMA descriptor, so we can easily determine whether we should
set 'skb->offload_fwd_mark' or not.
