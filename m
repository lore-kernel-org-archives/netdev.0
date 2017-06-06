From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 11:17:57 +0200
Message-ID: <20170606091757.GC1911@nanopsycho>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
 <20170606061610.GA1911@nanopsycho>
 <20170606002105.7a84432f@cakuba.netronome.com>
 <20170606082336.GB1911@nanopsycho>
 <20170606020945.05a9bcc5@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36001 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdFFJSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 05:18:00 -0400
Received: by mail-wm0-f54.google.com with SMTP id 7so92987734wmo.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 02:17:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170606020945.05a9bcc5@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 06, 2017 at 11:09:45AM CEST, kubakici@wp.pl wrote:
>On Tue, 6 Jun 2017 10:23:36 +0200, Jiri Pirko wrote:
>> Tue, Jun 06, 2017 at 09:21:45AM CEST, kubakici@wp.pl wrote:
>> >On Tue, 6 Jun 2017 08:16:10 +0200, Jiri Pirko wrote:  
>> >> Tue, Jun 06, 2017 at 02:01:41AM CEST, jakub.kicinski@netronome.com wrote:  
>> >> >Hi!
>> >> >
>> >> >This series adds the ability to use one vNIC as a control channel
>> >> >for passing messages to and from the application firmware.  The
>> >> >implementation restructures the existing netdev vNIC code to be able
>> >> >to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
>> >> >are not visible to userspace (other than for dumping ring state), and
>> >> >since they don't have netdevs we use a tasklet for RX and simple skb 
>> >> >list for TX queuing.
>> >> >
>> >> >Due to special status of the control vNIC we have to reshuffle the
>> >> >init code a bit to make sure control vNIC will be fully brought up
>> >> >(and therefore communication with app FW can happen) before any netdev
>> >> >or port is visible to user space.
>> >> >
>> >> >FW will designate which vNIC is supposed to be used as control one
>> >> >by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
>> >> >being prepended to control message, some prefer to look at queue ID
>> >> >to decide that something is a control message.  Our implementation
>> >> >can cater to both.
>> >> >
>> >> >First two users of this code will be eBPF maps and flower offloads.    
>> >> 
>> >> How do you actually do the configuration from the userspace? I did not
>> >> find it in the patches.  
>> >
>> >Yes, there is nothing interesting in those patches, really.  It's all
>> >internal to the driver.  This set basically allows us to dedicate some
>> >queue pairs to high-speed communication with the FW (sending commands,
>> >populating/dumping eBPF and Flower tables).
>> >
>> >The eBPF maps and Flower offload patches should follow in coming weeks.  
>> 
>> Okay. So you don't let the user to dicide for which purpose (bpf/flowe)
>> he wants to use the nic, right?
>
>Yes, right now we just expect the user to drop the FW file he wants
>to run into /lib/firmware/netronome.  Driver will interrogate the
>firmware once loaded to see which "app" it is.
>
>> >> The configuration is asic-wide, should be done by a devlink parent
>> >> handle which was introduced for that exact purpose.
>> >>
>> >> Am I missing something? We need to sync in this. In mlxsw we need to do
>> >> some pre-netdev configuraton as well.  
>> >
>> >For programmable NICs we still need to come up with some API for setting
>> >the target application/firmware name/adapter mode, but I don't think we
>> >have any more fine-grained parameters to set per-device just yet.
>> >
>> >I was thinking of either devlink, or perhaps, since I'm hearing people
>> >want those to be persistent/written into flash, the recent MTD
>> >discussion got me wondering if we should just expose the entire flash
>> >and teach ethtool to modify the vendor-specific parameter table
>> >directly in the flash.  That seems like something that could quickly
>> >get out of hand, though :S  
>> 
>> Yeah, I'm not fan of the mtd exposing some fw internals. I believe that
>> for the config like yours (switching the operation mode of nic), we
>> should have well defined user api. And since this is per-device, not
>> per-netdev, devlink should be the vahicle to carry this.
>
>Well defined API would be nice.  Perhaps we will just start with
>something very simple and then extend it if need be.  E.g. I'm hearing
>people would like to select not only the app but also the version of
>it...  Yes, starting simple is probably the way forward.
>
>> >What were your plans with pre-netdev config?  
>> 
>> We need to pass come initial resource division. Generally the consensus
>> is to have these options exposed through devlink, let the user configure
>> them all and then to have a trigger that would cause driver
>> re-orchestration according to the new values. The flow would look like
>> this:
>> 
>> -driver loads with defaults, inits hw and instantiates netdevs
>> -driver exposes config options via devlink
>> -user sets up the options
>> -user pushes the "go" trigger
>> -upon the trigger command, devlink calls the driver re-init callback
>> -driver shuts down the current instances, re-initializes hw,
>>  re-instantiates the netdevs
>> 
>> Makes sense?
>
>I like the idea of a "go"/apply/reload trigger and extending devlink.
>Do you plan on adding a way to persist the settings?  I'm concerned NIC
>users may want to boot into the right mode once it's set, without
>reloads and reconfigs upon boot.  Also is there going to be a way to
>query the pending/running config?  Sounds like we may want to expose
>three value sets - persistent/default, running and pending/to be
>applied.

I don't think it is a good idea to introduce any kind of configuration
persistency in HW. I believe that user is the master and he has all
needed info. He can store it persistently, but it is up to him. 

So basicaly during boot, we need the devlink configuration to happen
early on, before the netdevices get configured. udev? Not sure how
exactly to do this. Have to ask around :)
