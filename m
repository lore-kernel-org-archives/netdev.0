From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [2/5] ieee80211: ieee80211_device alignment fix and cleanup
Date: Tue, 31 May 2005 15:30:50 +0200
Message-ID: <20050531153050.139b1408@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
	<20050524151117.5e059d1d@griffin.suse.cz>
	<4297E78A.4030906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>, jbohac@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4297E78A.4030906@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 May 2005 23:37:46 -0400, Jeff Garzik wrote:
> 1) I am not convinced that the subclassing of net_device should be done 
> in this manner.  Read drivers/net/wan/hdlc_generic.c and .../pc300_drv.c 
> for examples of how hdlc_device is handled.

We see two differences to the hdlc concept:
1. the driver private data is allocated together with the net_device and
ieee80211_device data;
2. ieee80211_device is passed to functions instead of net_device.

Allocating all the structures together just extends the concept of
net_device allocation. The advantage is that all the structures are
located close to each other in the memory which (hopefully) improves
cache performance.

Passing ieee80211_device seems to be more appropriate in this case,
since drivers will be accessing ieee80211 data far more frequently than
net_device data. For example, part of the plan is to integrate Wireless
Extensions into the ieee80211 layer -- for all the ioctl handlers, it
will be much more interesting to have the ieee80211_device passed to
them. Furthermore, driver writers will not be tempted to think that
net_device->priv points to _their_ private data (which the name
suggests, but is not true).

Or did you mean something different?

> 2) Please put all the new, protocol-layer functions 
> ieee80211_type_trans(), ieee80211_change_mtu(), ieee80211_header(), etc. 
> in their own file.

Will be posted in the next patch series.

> 3) Temporary or not, the following construct is simply not necessary. 
> Modify the definition rather than repeating this two-call piece of code 
> in multiple areas:
> 	ieee80211_priv(netdev_priv(dev));

As soon as we're done integrating WE into ieee80211, most of this will
disappear. But sure, we can add a ieee80211_priv_from_netdev (or so)
macro for now.

 
> 4) A low-level wireless hardware driver should look like other net 
> drivers, and use the existing driver API.  The low level driver should

> implement its own dev->hard_start_xmit().
> Certainly, the driver will make many calls to generic ieee80211_xxx 
> functions to get things done.

Actually, hard_start_xmit has to do a lot of work regarding software
fragmentation, encryption, sequence numbering, etc. Sure, every driver
could call some ieee80211_prepare_to_xmit function in its own
hard_start_xmit, but we see no point in doing this as it would have to
be done by almost every driver. Drivers for very clever cards may
probably be an exception, but the risk is, that if they implement part
of the logic themselves, they will be more difficult to maintain as new
features are implemented in the ieee80211 layer. Furthermore, it is
against one of our premises ("the simpler card, the simpler driver").

We think that this concept of an "ieee80211 sublayer" has more
advantages than the concept of an "ieee80211 library". Do you have any
reasons why it should be the other way round?

 Jiri Benc & Jirka Bohac


-- 
Jiri Benc
SUSE Labs
