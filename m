From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [atl1-devel] [Bugme-new] [Bug 11736] New: atl1e: INFO:
 inconsistent lock state
Date: Fri, 10 Oct 2008 18:47:24 -0700
Message-ID: <20081010184724.f509fdc1.akpm@linux-foundation.org>
References: <bug-11736-10286@http.bugzilla.kernel.org/>
	<20081010142342.afe1cbb1.akpm@linux-foundation.org>
	<48EFC9BF.3020806@redhat.com>
	<20081010191133.102fe917@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, jie.yang@atheros.com,
	atl1-devel@lists.sourceforge.net, bugme-daemon@bugzilla.kernel.org,
	nm127@freemail.hu, netdev@vger.kernel.org, stable@kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34935 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbYJKBs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 21:48:26 -0400
In-Reply-To: <20081010191133.102fe917@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Oct 2008 19:11:33 -0500 Jay Cliburn <jacliburn@bellsouth.net> wrote:

> On Fri, 10 Oct 2008 17:31:43 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
> > Copying Jie Yang, the atl1e author, as I'm not certain he's on
> > atl1-devel.
> > 
> > Jie --
> > 
> > What do you make of this?
> > 
> > -- Chris
> > 
> > Andrew Morton wrote:
> > > (switched to email.  Please respond via emailed reply-to-all, not
> > > via the bugzilla web interface).
> > > 
> > > On Fri, 10 Oct 2008 14:14:12 -0700 (PDT)
> > > bugme-daemon@bugzilla.kernel.org wrote:
> > > 
> > >> http://bugzilla.kernel.org/show_bug.cgi?id=11736
> > >>
> > >>            Summary: atl1e: INFO: inconsistent lock state
> > >>            Product: Drivers
> > >>            Version: 2.5
> > >>      KernelVersion: 2.6.27
> > >>           Platform: All
> > >>         OS/Version: Linux
> > >>               Tree: Mainline
> > >>             Status: NEW
> > >>           Severity: normal
> > >>           Priority: P1
> > >>          Component: Network
> > >>         AssignedTo: jgarzik@pobox.com
> > >>         ReportedBy: nm127@freemail.hu
> > >>
> > >>
>
> ...
>
> This patch didn't make it into 2.6.27:

urgh, well that's a pickle.

> commit f382a0a8e9403c6d7f8b2cfa21e41fefb5d0c9bd
> Author: Matthew Wilcox <matthew@wil.cx>
> Date:   Tue Aug 12 07:13:14 2008 -0600
> 
>     [netdrvr] atl1e: Don't take the mdio_lock in atl1e_probe
>     
>     Lockdep warns about the mdio_lock taken with interrupts enabled then later
>     taken from interrupt context.  Initially, I considered changing these
>     to spin_lock_irq/spin_unlock_irq, but then I looked at atl1e_phy_init()
>     and saw that it calls msleep().  Sleeping while holding a spinlock is
>     not allowed either.
>     
>     In the probe path, we haven't registered the interrupt handler, so
>     it can't poke at this card yet.  It's before we call register_netdev(),
>     so I don't think any other threads can reach this card either.  If I'm
>     right, we don't need a spinlock at all.
>     
>     Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
> diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
> index 7685b99..9b60352 100644
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
>         }
>  
>         /* Init GPHY as early as possible due to power saving issue  */
> -       spin_lock(&adapter->mdio_lock);
>         atl1e_phy_init(&adapter->hw);
> -       spin_unlock(&adapter->mdio_lock);
>         /* reset the controller to
>          * put the device in a known good starting state */
>         err = atl1e_reset_hw(&adapter->hw);
> 
> 
> Jeff applied it to one of his trees on 13 September.
> http://marc.info/?l=linux-netdev&m=122133579023691&w=2
> 
> I guess it slipped into davem's net-next instead of net.
> 
> I'll submit it to -stable.

OK, thanks.
