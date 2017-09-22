From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: Re: [PATCH net] net/ncsi: Don't assume last available channel exists
Date: Fri, 22 Sep 2017 11:00:00 +1000
Message-ID: <1506042000.1377.21.camel@mendozajonas.com>
References: <20170920041251.14635-1-sam@mendozajonas.com>
         <20170920.160519.764603868579556859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920.160519.764603868579556859.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-20 at 16:05 -0700, David Miller wrote:
> From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> Date: Wed, 20 Sep 2017 14:12:51 +1000
> 
> > When handling new VLAN tags in NCSI we check the maximum allowed number
> > of filters on the last active ("hot") channel. However if the 'add'
> > callback is called before NCSI has configured a channel, this causes a
> > NULL dereference.
> > 
> > Check that we actually have a hot channel, and warn if it is missing.
> > 
> > Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> 
> Well, a few things.
> 
> We should not allow this driver method to be invoked in the first
> place if the device is not in a state where the operation is legal
> yet.
> 
> Second of all, if !ndp is true, you should not return 0 to indicate
> success.
> 
> But more fundamentally, we should block this method from being
> callable unless the device is in the proper state and can complete the
> operation.
> 
> Seriously, these checks should be completely unnecessary if those
> issues are handled properly.

Good point, this made me step back and reconsider the problem here.

The ncsi_vlan_rx_add_vid() callback exists because the NCSI driver needs
to know which VLAN IDs are set, but we don't have a straightforward way
of accessing that information later in ncsi_configure_channel() - as
opposed to the MAC address for example which is just accessed via
dev->dev_addr. Instead they're kept track of in the ndp->vlan_vids list
and the NCSI driver reconfigures any channels it knows about.

So in that sense the NCSI device *is* ready to handle the operation. The
hot_channel fix here was to check if we were exceeding the maximum number
of VLAN filters supported by the remote channel. That itself is bit
debatable since different channels could support different numbers of
filters but right now the NCSI driver only supports one active channel at
a time.

If we haven't configured a channel yet (or are in the process of doing
so) we won't have a hot_channel - does it make more sense to
- check against the hot_channel as currently done,
- only check the filter size at configure time for /each/ channel,
- only conditionally enable the .ndo_vlan_rx_add_vid net_device callback
once we've configured a channel (eg. for ftgmac100 in the
ftgmac100_ncsi_handler() callback?)

Thanks,
Sam
