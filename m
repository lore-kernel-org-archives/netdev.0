From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 4310] New: ppc 8260 fcc ethernet driver cannot
 read LXT971 PHY id
Date: Tue, 8 Mar 2005 11:48:51 -0800
Message-ID: <20050308114851.1f997476.akpm@osdl.org>
References: <200503081415.j28EF9CG002475@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@oss.sgi.com
To: oray@lucent.com
In-Reply-To: <200503081415.j28EF9CG002475@fire-1.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm not sure that we have a maintainer for fcc_enet.c.  Could you
please send in a tested diff?

bugme-daemon@osdl.org wrote:
>
> http://bugme.osdl.org/show_bug.cgi?id=4310
> 
>            Summary: ppc 8260 fcc ethernet driver cannot read LXT971 PHY id
>     Kernel Version: 2.6.10
>             Status: NEW
>           Severity: normal
>              Owner: platform_ppc-32@kernel-bugs.osdl.org
>          Submitter: oray@lucent.com
> 
> 
> Distribution: www.kernel.org
> Hardware Environment: Target: PowerPC 8260 custom board
> Software Environment: Red Hat 9 cross development using ELDK 3.1 distribution.
> Problem Description: Fast ethernet driver (fcc_enet.c) initialization fails to
> read a valid id from registers 2 and 3 of the LXT971 PHY device and calls the
> panic routine. The bug is in the mii_send_receive() function. During the read
> phase, per LXT971 data sheet, the device starts driving the MDIO line after the
> rising edge of the MDC clock and it could take up to 150ns before the data
> settles. The driver reads the MDIO line before waiting for the data to settle
> down and thus reads in garbage. I fixed the problem by moving the sampling of
> the MDIO line to after the MDC clock is taken low. The code snippet follows:   
> 
> 
>                 for (i = 0, off = 15; i < 16; i++, off--)
>                 {
> #define FCC_8260_BUG
>                         FCC_PDATC_MDC(1);
>                         retval <<= 1;
> #ifndef FCC_8260_BUG
>                         if (io->iop_pdatc & fip->fc_mdio)
>                                 retval++;
>                         udelay(1);
>                         FCC_PDATC_MDC(0);
> #else
>                         udelay(1);
>                         FCC_PDATC_MDC(0);
>                         if (io->iop_pdatc & fip->fc_mdio)
>                                 retval++;
> #endif
>                         udelay(1);
> #undef FCC_8260_BUG
>                 }
> 
> 
> Steps to reproduce: Is likely to happen on an 8260 target with any kind of PHY,
> not just the LXT971, hooked up to the FCC port.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
