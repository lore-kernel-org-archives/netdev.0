From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 10:57:02 -0500
Message-ID: <42209C4E.6000800@pobox.com>
References: <42208D83.80803@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <42208D83.80803@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe wrote:
> Hi Francois and Jon!
> 
> Please find attached a patch that adds the hardware statistics ethtool 
> operations to the r8169 driver. It's against 2.6.11-rc5.
> 
> Signed-Off-By: Richard Dawe <rich@phekda.gotadsl.co.uk>
> 
> Basically it's a port of the 8139cp stats routines to r8169. In 8139cp 
> the stats buffer is in the ring buffers' DMA mapping. In this patch for 
> r8169 it has its own DMA mapping.
> 
> One problem: Bogus stats are generated when I insert the module but 
> don't bring it up. E.g.: if I do this on FC3 (eth0 == r8169):
> 
>   <--(Using 2.6.11-rc5's r8169 driver here)-->
>   service network stop
>   rmmod r8169
>   insmod /path/to/new/r8169.ko
>   ethtool -S eth0
> 
> I get this:
> 
> NIC statistics:
>      tx_ok: 18446604436244066304
>      rx_ok: 4096
>      tx_err: 0
>      rx_err: 0
>      rx_fifo: 4
>      frame_align: 1
>      tx_ok_1col: 488917820
>      tx_ok_mcol: 0
>      rx_ok_phys: 18446604435732824074
>      rx_ok_bcast: 18446744071565939505
>      rx_ok_mcast: 0
>      tx_abort: 18446604435732824064
>      tx_underrun: 18446604436090647520
> 
> If I then bring the interface up ("ifconfig eth0 up"), I get valid stats.
> 
> Any suggestions on how to fix this? I tried a couple of things:
> 
> * Return in get_ethtool_stats if !netif_running(). Made no difference.
> 
> * Zero the stats after creating the DMA mapping with 
> pci_alloc_consistent(). Made no difference.
> 
> I wonder if 8139cp has the same problem?

No idea..  Worth checking.



> +static const char rtl8169_gstrings_stats[][ETH_GSTRING_LEN] = {
> +	"tx_ok", "rx_ok", "tx_err", "rx_err",
> +	"rx_fifo", "frame_align", "tx_ok_1col", "tx_ok_mcol",
> +	"rx_ok_phys", "rx_ok_bcast", "rx_ok_mcast", "tx_abort",
> +	"tx_underrun",
> +};

Don't needlessly reformat copied code.  It's one-string-per-line 
intentionally, for ease of maintenance and ease of adding new strings.

Also, I don't see why you renamed this from ethtool_stats_keys[].


> +	/* begin NIC statistics dump */
> +	RTL_W32(StatsAddrHigh, tp->nic_stats_addr >> 32);
> +	RTL_W32(StatsAddrLow, (tp->nic_stats_addr & 0xffffffff) | DumpStats);
> +	RTL_R32(StatsAddrLow);

This last RTL_R32() can be removed [from 8139cp too], because a flush 
immediately follows anyway:

> +	while (work-- > 0) {
> +		if ((RTL_R32(StatsAddrLow) & DumpStats) == 0)
> +			break;
> +		cpu_relax();
> +	}
