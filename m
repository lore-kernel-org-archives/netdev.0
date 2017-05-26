From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/18] mlxsw: Improve extensibility
Date: Fri, 26 May 2017 15:20:35 -0400 (EDT)
Message-ID: <20170526.152035.708896761272676930.davem@davemloft.net>
References: <20170526063740.8909-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754180AbdEZTUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:20:38 -0400
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 May 2017 08:37:22 +0200

> Ido says:
> 
> Since the initial introduction of the bridge offload in commit
> 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
> the per-port struct was used to store both physical properties of the
> port as well as logical bridge properties such as learning and active
> VLANs in the VLAN-aware bridge.
> 
> The above resulted in a bloated struct and code that is getting
> increasingly difficult to extend when stacked devices are taken into
> account as well as more advanced use cases such as IGMP snooping.
> 
> Due to the incremental development nature of this driver as well as the
> complexity of the underlying hardware, subsequent design decisions failed
> to generalize the FID and RIF resources, which could've benefited from
> a more generic design, resulting in consolidated code paths and better
> extensibility with regards to future ASICs and use cases.
> 
> This patchset tries to solve both of these design problems, as they're
> tightly coupled. To ease the code review, the changes are done in a
> bottom-up manner, in which the port struct is the first to be patched,
> then the FIDs the ports are mapped to and finally the RIFs configured on
> top.
> 
> The first half of the patchset gradually moves away from the previous
> design to a design that is more in sync with the underlying hardware and
> which clearly separates between hardware-specific structs and logical
> ones such as a bridge port.
> 
> All the bridge-specific information is removed from the port struct, as
> well as the list of VLAN devices ("vPorts") configured on top of it.
> Instead, a linked list of VLANs is introduced, which allows each VLAN
> to hold a state, such as mapping to a particular FID and membership in
> a bridge. The data structures are depicted in the following figure:
 ...
> This model allows us to consolidate many of the code paths relating to
> VLAN-aware and VLAN-unaware bridges, as the latter is simply represented
> using a bridge port with a VLAN list size of one. Another advantage of
> the model is that it's easy to extend it with future per-VLAN
> attributes - such as mrouter indication - by merely pushing these down
> from the bridge port struct to the bridge VLAN one.
> 
> The second half of the patchset builds on top of previous work and
> prepares the driver for the common FID and RIF cores, which are finally
> implemented in the last two patches. These exploit the fact that despite
> the different kinds of FIDs and RIFs, they do share a common object on
> which the core operations can operate on.
> 
> By hiding both objects from the rest of the driver and modeling their
> operations using a VFT, it'll be easier to extend the driver for future
> use cases such as VXLAN.
> 
> Tested using following LNST recipes:
> https://github.com/jpirko/lnst/tree/master/recipes/switchdev

Nice cleanups and consolidation, but like Nikolay I'm not so sure
about all the exports.

It might even be cleaner (believe it or not) to have the bridge
structure (or at least a subset of it) be something public that
drivers can query using inline helpers.
