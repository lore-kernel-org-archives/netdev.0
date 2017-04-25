From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: qed*: debug infrastructures
Date: Mon, 24 Apr 2017 20:44:10 -0700
Message-ID: <20170424204410.538fdabc@cakuba.netronome.com>
References: <CY1PR0701MB1337FA26F1503FC9928B0340901F0@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>
To: "Elior, Ariel" <Ariel.Elior@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:19631 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S980390AbdDYDod (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 23:44:33 -0400
In-Reply-To: <CY1PR0701MB1337FA26F1503FC9928B0340901F0@CY1PR0701MB1337.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Apr 2017 17:38:57 +0000, Elior, Ariel wrote:
> Hi Dave,

Hi Ariel!

I'm not Dave but let me share my perspective :)

> According to the recent messages on the list indicating debugfs is not the way
> to go, I am looking for some guidance on what is. dpipe approach was
> mentioned as favorable, but I wanted to make sure molding our debug features to
> this infrastructure will result in something acceptable. A few points:
> 
> 1.
> One of our HW debug features is a signal recording feature. HW is configured to
> output specific signals, which are then continuously dumped into a cyclic
> buffer on host. There are ~8000 signals, which can be logically divided to ~100
> groups. I believe this can be modeled in dpipe (or similar tool) as a set of
> ~100 tables with ~80 entries each, and user would be able to see them all and
> choose what they like. The output data itself is binary, and meaningless to
> "the user". The amount of data is basically as large a contiguous buffer as
> driver can allocate, i.e. usually 4MB. When user selects the signals, and sets
> meta data regarding to mode of operations, some device configuration will have
> to take place. Does that sound reasonable?
> This debug feature already exists out of tree for bnx2x and qed* drivers and is
> *very* effective in field deployments. I would very much like to see this as an
> in-tree feature via some infrastructure or another.

Sorry for even mentioning it, new debug interfaces would be cool, but
for FW/HW state dumps which are meaningless to the user why not just
use ethtool get-dump/set-dump?  Do you really need the ability to
toggle those 8k signals one-by-one or are there reasonable sets you
could provide from the driver that you could encode on the available
32bits of flags?

What could be useful would be some form of start/stop commands for
debugging to tell the driver/FW when to record events selected by
set-dump and maybe a way for the user to discover what dumps the driver
can provide (a'la ethtool private flags).

> 2.
> Sometimes we want to debug the probe or removal flow of the driver. ethtool has
> the disadvantage of only being available once network device is available. If a
> bug stops the load flow before the ethtool debug paths are available, there is
> no way to collect a dump. Similarly, removal flows which hit a bug but do remove
> the network device, can't be debugged from ethtool. Does dpipe suffer from the
> same problem? qed* (like mlx*) has a common-functionality module. This allows
> creating debugfs nodes even before the network drivers are probed, providing a
> solution for this (debug nodes are also available after network driver removal).
> If dpipe does hold an answer here (e.g. provide preconfiguration which would
> kick in when network device registers) then we might want to port all of our
> register dump logic over there for this advantage. Does that sound reasonable?

Porting the debug/dump infrastructure to devlink would be very much
appreciated.  I'm not sure it would fit into dpipe or be a separate
command.

> 3.
> Yuval mentioned this, but I wanted to reiterate that the same is necessary for
> our storage drivers (qedi/qedf). debugfs does have the advantage of being non
> sub-system specific. Is there perhaps another non subsystem specific debug
> infrastructure which *is* acceptable to the networking subsystem? My guess is
> that the storage drivers will turn to debugfs (in their own subsystem).

devlink is not ethernet-specific, it should be a good fit for iSCSI and
FCOE drivers, too.
