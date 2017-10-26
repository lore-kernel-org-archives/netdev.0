From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [patch net-next 2/4] net: sched: move the can_offload check
 from binding phase to rule insertion phase
Date: Thu, 26 Oct 2017 13:55:19 -0700
Message-ID: <20171026135519.6f213c41@cakuba.netronome.com>
References: <20171025143500.28973-1-jiri@resnulli.us>
        <20171025143500.28973-3-jiri@resnulli.us>
        <20171026.100131.1516530767097739079.davem@davemloft.net>
        <20171026060748.GA1928@nanopsycho.orion>
        <CAKgT0UcxGO2rTg0dxLG9p=5ew7=VdW6hMZrdQnTBAYAMWMXQ5A@mail.gmail.com>
        <20171026154019.GH1928@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, mlxsw@mellanox.com,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>, idosch@mellanox.com,
        Simon Horman <simon.horman@netronome.com>,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:49874 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdJZUz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 16:55:29 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so10165095wmd.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 13:55:28 -0700 (PDT)
In-Reply-To: <20171026154019.GH1928@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 17:40:19 +0200, Jiri Pirko wrote:
> Thu, Oct 26, 2017 at 05:29:08PM CEST, alexander.duyck@gmail.com wrote:
> >On Wed, Oct 25, 2017 at 11:07 PM, Jiri Pirko <jiri@resnulli.us> wrote:  
> >> Thu, Oct 26, 2017 at 03:01:31AM CEST, davem@davemloft.net wrote:  
> >>>From: Jiri Pirko <jiri@resnulli.us>
> >>>Date: Wed, 25 Oct 2017 16:34:58 +0200
> >>>  
> >>>> From: Jiri Pirko <jiri@mellanox.com>
> >>>>
> >>>> This restores the original behaviour before the block callbacks were
> >>>> introduced. Allow the drivers to do binding of block always, no matter
> >>>> if the NETIF_F_HW_TC feature is on or off. Move the check to the block
> >>>> callback which is called for rule insertion.
> >>>>
> >>>> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
> >>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>  
> >>>
> >>>I agree with Jakub's feedback, if every callback has to make this check
> >>>why not just do it in the core where the callback is invoked?  
> >>
> >> We cannot add it to the core. The idea of the block callbacks is to get
> >> independent of the "dev". For the block sharing, driver registers one
> >> block callback for multiple devs. Core has no access to "dev".  
> >
> >If the plan is to have one block represent multiple devices are we
> >then looking at the offload flag potentially being tied together for
> >all those devices then at some point in the future? I assume that
> >means that this workaround will have to eventually go away for some of
> >the Mellanox devices since it wouldn't make sense to have a netdev
> >pointer if the context block supports multiple netdevices. Do I have
> >that right? If so, is the idea to just assume the offload is always-on  
> 
> You do.
> 
> >(fixed) or do you have some other idea in mind for how to deal with a
> >feature that is controlled globally for the device versus a port?  
> 
> I plan to check the offload feature flag for all ports that share the
> block and allow the offload only in case all are on.

Clearly we draw the line between what should the responsibility of the
driver do and what belongs higher in the stack differently :)

> Also, there would be forbidden to turn the offload flag off in case
> there is at least one offloaded rule for the block. This is how mlx5
> does it.

My grep-foo fails me I only see that check in nfp.  I though John
already did that in ixgbe.  And then everyone copied, since it's
sort-of UAPI?  Or at least users may come to expect certain
consistent behaviour.  Same story for phys_port_name for representors,
and OpenStack expect certain names by now.  That copying of behaviour
concerns me, not necessarily multiplication of code.
