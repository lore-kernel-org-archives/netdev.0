From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 19:12:13 +0100
Message-ID: <20050226181213.GA13230@electric-eye.fr.zoreil.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <200502261132.29261.jdmason@us.ibm.com> <4220B9C6.1010106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, Richard Dawe <rich@phekda.gotadsl.co.uk>,
        netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4220B9C6.1010106@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> >+static void rtl8169_get_ethtool_stats(struct net_device *netdev,
> >+       struct ethtool_stats *stats, u64 *data)
> >+{
> >+       struct rtl8169_private *tp = netdev_priv(netdev);
> >+       void __iomem *ioaddr = tp->mmio_addr;
> >+       int work = 100;
> >+       int i;
> >+
> >+       /* begin NIC statistics dump */
> >+       RTL_W32(StatsAddrHigh, tp->nic_stats_addr >> 32);
> >+       RTL_W32(StatsAddrLow, (tp->nic_stats_addr & 0xffffffff) | 
> >DumpStats);
> >+       RTL_R32(StatsAddrLow);
> >+
> >+       while (work-- > 0) {
> >+               if ((RTL_R32(StatsAddrLow) & DumpStats) == 0)
> >+                       break;
> >+               cpu_relax();
> >+       }
> >+
> >+       if (RTL_R32(StatsAddrLow) & DumpStats)
> >+               return; /* no stats - took too long */
> >+
> >+       i = 0;
> >+       data[i++] = le64_to_cpu(tp->nic_stats->tx_ok);
[...]
> >+       data[i++] = le16_to_cpu(tp->nic_stats->tx_underrun);
> >+       if (i != RTL8169_STATS_LEN)
> >+               BUG();
> >+}
> >+
> >
> >It seems to me that 'i' could be re-used, instead of having both 'i' and 
> >'work'.
> 
> No.  That's a completely useless pseudo-optimization.  Write readable 
> code, and let the compiler do the rest.

Btw I'd simply remove the 'work' variable and schedule in an interruptible
way until the dump is done.

BUG() is a bit exagerated imho.

--
Ueimor
