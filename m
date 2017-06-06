From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 00:21:45 -0700
Message-ID: <20170606002105.7a84432f@cakuba.netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
        <20170606061610.GA1911@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:29702 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751194AbdFFHVz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 03:21:55 -0400
In-Reply-To: <20170606061610.GA1911@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jun 2017 08:16:10 +0200, Jiri Pirko wrote:
> Tue, Jun 06, 2017 at 02:01:41AM CEST, jakub.kicinski@netronome.com wrote:
> >Hi!
> >
> >This series adds the ability to use one vNIC as a control channel
> >for passing messages to and from the application firmware.  The
> >implementation restructures the existing netdev vNIC code to be able
> >to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
> >are not visible to userspace (other than for dumping ring state), and
> >since they don't have netdevs we use a tasklet for RX and simple skb 
> >list for TX queuing.
> >
> >Due to special status of the control vNIC we have to reshuffle the
> >init code a bit to make sure control vNIC will be fully brought up
> >(and therefore communication with app FW can happen) before any netdev
> >or port is visible to user space.
> >
> >FW will designate which vNIC is supposed to be used as control one
> >by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
> >being prepended to control message, some prefer to look at queue ID
> >to decide that something is a control message.  Our implementation
> >can cater to both.
> >
> >First two users of this code will be eBPF maps and flower offloads.  
> 
> How do you actually do the configuration from the userspace? I did not
> find it in the patches.

Yes, there is nothing interesting in those patches, really.  It's all
internal to the driver.  This set basically allows us to dedicate some
queue pairs to high-speed communication with the FW (sending commands,
populating/dumping eBPF and Flower tables).

The eBPF maps and Flower offload patches should follow in coming weeks.

> I'm not really sure that doing it using one "control netdevice" is the
> correct way to go. 

The control queues are not exposed to user space at all.  It's up to
the driver logic to generate and consume all messages passing on those
queues.  I had to make this a separate series because of the amount
of code churn.  I'm also not a fan of exposing control netdevices.
Reasons ranging from NetworkManager latching onto them (even if it's
configured not to) to someone inevitably trying to control the device
from user space with vendor commands and make the driver-kept state go
out of whack :/

> The configuration is asic-wide, should be done by a devlink parent
> handle which was introduced for that exact purpose.
>
> Am I missing something? We need to sync in this. In mlxsw we need to do
> some pre-netdev configuraton as well.

For programmable NICs we still need to come up with some API for setting
the target application/firmware name/adapter mode, but I don't think we
have any more fine-grained parameters to set per-device just yet.

I was thinking of either devlink, or perhaps, since I'm hearing people
want those to be persistent/written into flash, the recent MTD
discussion got me wondering if we should just expose the entire flash
and teach ethtool to modify the vendor-specific parameter table
directly in the flash.  That seems like something that could quickly
get out of hand, though :S

What were your plans with pre-netdev config?

I hope this makes things slightly clearer, sorry for not doing a good
job on the cover letter :)
