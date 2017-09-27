From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: Re: [PATCH net] net/ncsi: Don't assume last available channel exists
Date: Wed, 27 Sep 2017 14:12:40 +1000
Message-ID: <1506485560.1757.16.camel@mendozajonas.com>
References: <20170920041251.14635-1-sam@mendozajonas.com>
         <20170920.160519.764603868579556859.davem@davemloft.net>
         <1506042000.1377.21.camel@mendozajonas.com>
         <20170921.181111.2086501653519863373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921.181111.2086501653519863373.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-09-21 at 18:11 -0700, David Miller wrote:
> From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> Date: Fri, 22 Sep 2017 11:00:00 +1000
> 
> > If we haven't configured a channel yet (or are in the process of doing
> > so) we won't have a hot_channel - does it make more sense to
> > - check against the hot_channel as currently done,
> > - only check the filter size at configure time for /each/ channel,
> > - only conditionally enable the .ndo_vlan_rx_add_vid net_device callback
> > once we've configured a channel (eg. for ftgmac100 in the
> > ftgmac100_ncsi_handler() callback?)
> 
> The last isn't so feasible.
> 
> The device shouldn't be marked attached until a channel is available,
> because it seems like communication cannot occur until one is.  Right?

Yes that's right.

> 
> You could experiment with netif_device_detach()/netif_device_attach().
> 
> When the device is in the detached state, callbacks such as
> ->ndo_vlan_rx_add_vid() will not be invoked.

This looked like the way at first, but _detach() ceases any tx/rx on the
interface right?
NCSI still needs the interface to be active since the 'channels' are on a
separate network controller that the interface is connected to, eg on the
machines I'm using:

BMC					     'Host' network controller
----------------------			     ----------------------------
|ftgmac100 interface | <---- NCSI Link ----> | BCM5719 interface	| --> external interface
----------------------			     ----------------------------

Looking at the NCSI init path I believe we're guaranteed to have an ndp
struct by the time ndo_vlan_rx_add_vid() is called, making some of those
checks overly cautious. It might be easiest to just track new vids as we
see them (up to the NCSI spec limit), and then deal with configured
channels on a case by case basis since their limits can be different.
I'll work on a V2 but hopefully I haven't misinterpreted
_detach()/_attach() :)

Sam
