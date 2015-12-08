From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH] r8152: fix lockup when runtime PM is enabled
Date: Tue, 8 Dec 2015 12:10:08 +0100
Message-ID: <20151208111008.GA18728@al>
References: <1449507520-10671-1-git-send-email-peter@lekensteyn.nl>
 <0835B3720019904CB8F7AA43166CEEB2F8D48F@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Lu Baolu <baolu.lu@linux.intel.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F8D48F@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 03:18:59AM +0000, Hayes Wang wrote:
> Peter Wu
> > Sent: Tuesday, December 08, 2015 12:59 AM
> [...]
> > +			if (tp->netdev->flags & IFF_UP) {
> 
> Maybe you could just replace the checking of netif_running(tp->netdev)
> with this.

Simply replacing netif_running by IFF_UP does not work, it hangs during
close when the device is suspended. This patch is correct, but I have a
v2 patch that moves rtl_runtime_suspend_enable from close to suspend.

This is the evaluated scenario (run = netif_running, up = IFF_UP set):

    # suspended before open
    suspend (run=0, up=0)
    open    (run=1)
    resume  (run=1, up=0)   <-- fixed by patch
    (open ends)

    # while up
    suspend (run=1, up=1)
    resume  (run=1, up=1)   <-- no issue, values match
    suspend (run=1, up=1)

    # close while suspended
    close   (run=0, up=1)
    resume  (run=0, up=1)   <-- fixed in patch v2
    (close cont and ends)   <-- rtl_runtime_suspend_enable removed in v2
    suspend (run=0, up=0)

    # while down
    resume  (run=0, up=0)
    suspend (run=0, up=0)

    # open while suspended, open fails
    open    (run=1)
    resume  (run=1, up=0)   <-- fixed by patch
    (open fails)
    suspend (run=0, up=0)

> Excuse me. I have a question. Before the open() is finished, the
> netif_running() would be true, but the IFF_UP wouldn't be set. Is it
> right?

That is right, this happens behind the scenes:

    # open
    netif_running = true
    open()
    if open succeeded
        set IFF_UP
    else
        netif_running = false

    # close
    netif_running = false
    close()
    clear IFF_UP
-- 
Kind regards,
Peter Wu
https://lekensteyn.nl
