From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Mon, 14 Jan 2008 08:39:26 -0800
Message-ID: <20080114083926.03232343@deepthought>
References: <bug-9721-10286@http.bugzilla.kernel.org/>
	<200801112216.08992.rjw@sisk.pl>
	<4787EB69.9060900@yahoo.de>
	<200801120010.22440.rjw@sisk.pl>
	<478A1083.5060406@yahoo.de>
	<478A2976.9000204@yahoo.de>
	<20080113112712.e93f07a4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: supersud501 <supersud501@yahoo.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20080113112712.e93f07a4.akpm@linux-foundation.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Jan 2008 11:27:12 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 13 Jan 2008 16:08:38 +0100 supersud501 <supersud501@yahoo.de> wrote:
> 
> > 
> > 
> > supersud501 wrote:
> > > 
> > > 
> > > Rafael J. Wysocki wrote:
> > > 
> > >>
> > >> Since it seems to be 100% reproducible, it would be very helpful if 
> > >> you could
> > >> use git-bisect to identify the offending commit.
> > >>
> > > 
> > > allright, bisect found the offending commit, here's what i've done:
> > > 
> > > first i started bisect with the following command (since i assumed it is 
> > > a net-driver problem):
> > > 
> > > git-bisect start 'v2.6.24-rc6' 'v2.6.23' '--' 'drivers/net/'
> > > 
> > > after building many kernels and saying good/bad if wol worked/didn't 
> > > work etc. it identified the following commit:
> > > 
> > > # bad: [ac93a3946b676025fa55356180e8321639744b31] sky2: enable PCI 
> > > config writes
> > > 
> > > and refs/bisect/bad gives:
> > > 
> > > 14:16:53 /usr/src/linux-2.6/.git # cat refs/bisect/bad
> > > ac93a3946b676025fa55356180e8321639744b31
> > > 
> > > 
> > > need some more info?
> > > 
> > 
> > i just checked it: commented out the passage of the commit in kernel 
> > 2.6.24-rc7-git4 and compiled it: wol WORKS. so this one line is causing 
> > my wol-disturbance...
> > 
> > 
> 
> So simply reverting this:
> 
> commit ac93a3946b676025fa55356180e8321639744b31
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Mon Nov 5 15:52:08 2007 -0800
> 
>     sky2: enable PCI config writes
>     
>     On some boards, PCI configuration space access is turned off by default.
>     The 2.6.24 driver doesn't turn it on, and should have.
>     
>     Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index c27c7d6..4f41a94 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2791,6 +2791,9 @@ static void sky2_reset(struct sky2_hw *hw)
>  	sky2_write8(hw, B0_CTST, CS_RST_SET);
>  	sky2_write8(hw, B0_CTST, CS_RST_CLR);
>  
> +	/* allow writes to PCI config */
> +	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
> +
>  	/* clear PCI errors, if any */
>  	pci_read_config_word(pdev, PCI_STATUS, &status);
>  	status |= PCI_STATUS_ERROR_BITS;
> 
> fixes this regression?
> 
> If so, we should revert that change.
> 
> > but i noticed another "bug" on 2.6.24-rc7-git with sky2: dmesg shows a 
> > lot of lines every 5 seconds:
> > 
> > [...]
> > [  357.400462] sky2 0000:02:00.0: error interrupt status=0xc0000000
> > [  362.442039] printk: 41 messages suppressed.
> > [  362.442043] sky2 0000:02:00.0: error interrupt status=0x80000000
> > [  367.439151] printk: 18 messages suppressed.
> > [  367.439156] sky2 0000:02:00.0: error interrupt status=0x80000000
> > [  372.436267] printk: 30 messages suppressed.
> > [  372.436271] sky2 0000:02:00.0: error interrupt status=0x80000000
> > [  377.350236] printk: 19 messages suppressed.
> > [...]
> > 
> > since i do not notice any errors (yet) i'll wait till next rc, maybe it 
> > will be gone then...
> 
> That's not good.  is this new behaviour?
> 

No, reverting that change will break other systems (including mine).

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
