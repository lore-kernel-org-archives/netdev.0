From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 10:23:36 +0200
Message-ID: <20170606082336.GB1911@nanopsycho>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
 <20170606061610.GA1911@nanopsycho>
 <20170606002105.7a84432f@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34003 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbdFFIXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 04:23:39 -0400
Received: by mail-wm0-f46.google.com with SMTP id d64so3385160wmf.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 01:23:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170606002105.7a84432f@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 06, 2017 at 09:21:45AM CEST, kubakici@wp.pl wrote:
>On Tue, 6 Jun 2017 08:16:10 +0200, Jiri Pirko wrote:
>> Tue, Jun 06, 2017 at 02:01:41AM CEST, jakub.kicinski@netronome.com wrote:
>> >Hi!
>> >
>> >This series adds the ability to use one vNIC as a control channel
>> >for passing messages to and from the application firmware.  The
>> >implementation restructures the existing netdev vNIC code to be able
>> >to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
>> >are not visible to userspace (other than for dumping ring state), and
>> >since they don't have netdevs we use a tasklet for RX and simple skb 
>> >list for TX queuing.
>> >
>> >Due to special status of the control vNIC we have to reshuffle the
>> >init code a bit to make sure control vNIC will be fully brought up
>> >(and therefore communication with app FW can happen) before any netdev
>> >or port is visible to user space.
>> >
>> >FW will designate which vNIC is supposed to be used as control one
>> >by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
>> >being prepended to control message, some prefer to look at queue ID
>> >to decide that something is a control message.  Our implementation
>> >can cater to both.
>> >
>> >First two users of this code will be eBPF maps and flower offloads.  
>> 
>> How do you actually do the configuration from the userspace? I did not
>> find it in the patches.
>
>Yes, there is nothing interesting in those patches, really.  It's all
>internal to the driver.  This set basically allows us to dedicate some
>queue pairs to high-speed communication with the FW (sending commands,
>populating/dumping eBPF and Flower tables).
>
>The eBPF maps and Flower offload patches should follow in coming weeks.

Okay. So you don't let the user to dicide for which purpose (bpf/flowe)
he wants to use the nic, right?


>
>> I'm not really sure that doing it using one "control netdevice" is the
>> correct way to go. 
>
>The control queues are not exposed to user space at all.  It's up to
>the driver logic to generate and consume all messages passing on those
>queues.  I had to make this a separate series because of the amount
>of code churn.  I'm also not a fan of exposing control netdevices.
>Reasons ranging from NetworkManager latching onto them (even if it's
>configured not to) to someone inevitably trying to control the device
>from user space with vendor commands and make the driver-kept state go
>out of whack :/

Okay, that got me confused. I thought that you want the control
netdevice. Now that is clear we both don't want to see that, I'm fine :)


>
>> The configuration is asic-wide, should be done by a devlink parent
>> handle which was introduced for that exact purpose.
>>
>> Am I missing something? We need to sync in this. In mlxsw we need to do
>> some pre-netdev configuraton as well.
>
>For programmable NICs we still need to come up with some API for setting
>the target application/firmware name/adapter mode, but I don't think we
>have any more fine-grained parameters to set per-device just yet.
>
>I was thinking of either devlink, or perhaps, since I'm hearing people
>want those to be persistent/written into flash, the recent MTD
>discussion got me wondering if we should just expose the entire flash
>and teach ethtool to modify the vendor-specific parameter table
>directly in the flash.  That seems like something that could quickly
>get out of hand, though :S

Yeah, I'm not fan of the mtd exposing some fw internals. I believe that
for the config like yours (switching the operation mode of nic), we
should have well defined user api. And since this is per-device, not
per-netdev, devlink should be the vahicle to carry this.


>
>What were your plans with pre-netdev config?

We need to pass come initial resource division. Generally the consensus
is to have these options exposed through devlink, let the user configure
them all and then to have a trigger that would cause driver
re-orchestration according to the new values. The flow would look like
this:

-driver loads with defaults, inits hw and instantiates netdevs
-driver exposes config options via devlink
-user sets up the options
-user pushes the "go" trigger
-upon the trigger command, devlink calls the driver re-init callback
-driver shuts down the current instances, re-initializes hw,
 re-instantiates the netdevs

Makes sense?


>
>I hope this makes things slightly clearer, sorry for not doing a good
>job on the cover letter :)

No worries :)
