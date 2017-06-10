From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: cast l2tp traffic counter to unsigned
Date: Sat, 10 Jun 2017 16:13:35 -0400 (EDT)
Message-ID: <20170610.161335.734544822657172006.davem@davemloft.net>
References: <20170609142947.16969-1-dheidler@suse.de>
        <20170609151621.11e610a2@xeon-e3>
        <1497054551.736.99.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dheidler@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        tparkin@katalix.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497054551.736.99.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Jun 2017 17:29:11 -0700

> On Fri, 2017-06-09 at 15:16 -0700, Stephen Hemminger wrote:
>> On Fri,  9 Jun 2017 16:29:47 +0200
>> Dominik Heidler <dheidler@suse.de> wrote:
>> 
>> > This fixes a counter problem on 32bit systems:
>> > When the rx_bytes counter reached 2 GiB, it jumpd to (2^64 Bytes - 2GiB) Bytes.
>> > 
>> > rtnl_link_stats64 has __u64 type and atomic_long_read returns
>> > atomic_long_t which is signed. Due to the conversation
>> > we get an incorrect value on 32bit systems if the MSB of
>> > the atomic_long_t value is set.
>> > 
>> > CC: Tom Parkin <tparkin@katalix.com>
>> > Fixes: 7b7c0719cd7a ("l2tp: avoid deadlock in l2tp stats update")
>> > Signed-off-by: Dominik Heidler <dheidler@suse.de>
>> > ---
>> >  net/l2tp/l2tp_eth.c | 13 +++++++------
>> >  1 file changed, 7 insertions(+), 6 deletions(-)
>> > 
>> > diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
>> > index 8b21af7321b9..668a75e002e9 100644
>> > --- a/net/l2tp/l2tp_eth.c
>> > +++ b/net/l2tp/l2tp_eth.c
>> > @@ -114,12 +114,13 @@ static void l2tp_eth_get_stats64(struct net_device *dev,
>> >  {
>> >  	struct l2tp_eth *priv = netdev_priv(dev);
>> >  
>> > -	stats->tx_bytes   = atomic_long_read(&priv->tx_bytes);
>> > -	stats->tx_packets = atomic_long_read(&priv->tx_packets);
>> > -	stats->tx_dropped = atomic_long_read(&priv->tx_dropped);
>> > -	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
>> > -	stats->rx_packets = atomic_long_read(&priv->rx_packets);
>> > -	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
>> > +	stats->tx_bytes   = (unsigned long) atomic_long_read(&priv->tx_bytes);
>> > +	stats->tx_packets = (unsigned long) atomic_long_read(&priv->tx_packets);
>> > +	stats->tx_dropped = (unsigned long) atomic_long_read(&priv->tx_dropped);
>> > +	stats->rx_bytes   = (unsigned long) atomic_long_read(&priv->rx_bytes);
>> > +	stats->rx_packets = (unsigned long) atomic_long_read(&priv->rx_packets);
>> > +	stats->rx_errors  = (unsigned long) atomic_long_read(&priv->rx_errors);
>> > +
>> >  }
>> >  
>> >  static const struct net_device_ops l2tp_eth_netdev_ops = {
>> 
>> This is not the right way to fix this.
>> 
>> 1. shouldn't be using atomic's for network counters, look at other network devices.
>> 
>> 2. should be using u64_stats_fetch  api to handle 64 bit counters.
> 
> But they do not want 64bit counters, and not per cpu counters for a
> driver handling few packets per second.
> 
> Just use native size of "unsigned long".

Ahh yeah, indeed.  I've applied this l2tp patch, therefore.

> We use the same atomic_long_t for (struct netdev)->rx_dropped,
> tx_dropped & rx_nohandler
> 
> So I guess same fix is needed in dev_get_stats()

Looks like it, I'll apply a formal submission of this.
