From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 15:23:03 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501071501510.5818-100000@localhost.localdomain>
References: <200501071619.54566.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
In-Reply-To: <200501071619.54566.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Jan 2005, Jeremy M. Guthrie wrote:
> > Very interesting that with your workload the napi driver doesn't keep up
> > (from looking at your posts in netdev) and yet the interrupt mode driver
> > can.
> Well, I need to do more digging.   One scenario the interrupt mode can hand 
> stuff off to the CPU but the network stack still drops.  The other scenario, 
> the card drops.  
> 
> ethtool -S eth2
> NIC statistics:
<snip!>
>      tx_packets: 314550698
>      tx_bytes: 4290523139
> ethtool -S eth3
> NIC statistics:
<snip!>
>      rx_packets: 719847127
>      tx_packets: 5
>      rx_bytes: 1880301945
>      tx_bytes: 398
>      rx_errors: 3368295
>      rx_dropped: 1478044
>      rx_fifo_errors: 1890251
>      rx_missed_errors: 1890251
>      rx_long_byte_count: 379837423993
>      rx_csum_offload_good: 672891990
>      rx_csum_offload_errors: 178666

Okay, well, rx_dropped means "receive no buffers count" in our driver, but
doesn't necessarily mean that the packet was completely dropped it just
means that the fifo may have had to queue up the packet on the adapter as
best it could and wait for the OS to provide more skb's, this may or may 
not lead to further errors...

Now, the rx_fifo errors is from hardware counter "missed packet count"
which means that a packet was dropped because the fifo was full (probably
indicated at least some of the time because the card was in "receive no
buffers" state) btw fifo errors and rx_missed are both being fed by the 
same hardware counter.

rx_csum_offload_errors is somewhat worrisome because it means that you're
receiving packets that appear to be corrupted.  This could be from any
number of sources, but is most likely a misconfigured station on your lan
or something is corrupting checksums (a tcpdump would help debug here, but
would really slow things down)  The packets are NOT dropped, but handed to
the stack to decide what to do.

So, to mitigate the rnbc "receive no buffers count" a little you can
provide some more buffering on the receive side by loading the module with
RxDescriptors=2048 or something larger than the default of 256.  this will 
help (if you haven't already) but will also probably increase the amount 
of work your system has to do, as more packets will be able to be stored 
up.
