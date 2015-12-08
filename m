From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 8 Dec 2015 15:33:05 +0100
Message-ID: <20151208143305.GB18728@al>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
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
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 12:39:12PM +0000, Hayes Wang wrote:
> Peter Wu [mailto:peter@lekensteyn.nl]
> > Sent: Tuesday, December 08, 2015 7:18 PM
> > 
> > When an interface is brought up which was previously suspended (via
> > runtime PM), it would hang. This happens because napi_disable is called
> > before napi_enable.
> > 
> > Solve this by avoiding napi_enable in the resume during open function
> > (netif_running is true when open is called, IFF_UP is set after a
> > successful open; netif_running is false when close is called, but IFF_UP
> > is then still set).
> > 
> > While at it, remove WORK_ENABLE check from rtl8152_open (introduced with
> > the original change) because it cannot happen:
> > 
> >  - After this patch, runtime resume will not set it during rtl8152_open.
> >  - When link is up, rtl8152_open is not called.
> >  - When link is down during system/auto suspend/resume, it is not set.
> > 
> > Fixes: 41cec84cf285 ("r8152: don't enable napi before rx ready")
> > Link: https://lkml.kernel.org/r/20151205105912.GA1766@al
> > Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> > ---
> >  v2: moved rtl_runtime_suspend_enable from close to rtl8152_suspend
> 
> Acked-by: Hayes Wang <hayeswang@realtek.com>
> 
> Best Regards,
> Hayes

I found another problem with runtime PM. When a device is suspended via
autosuspend and a system suspend takes place, there is no network I/O
after resume. Triggering a renegotiation (ethtool -r eth1) brings back
network activity.

Can you have a look? I guess that reset_resume needs different
treatment, but don't know how to do it properly as suspend is not called
before system reset (because the device is apparently already in
suspended state).

I think that this new issue can be addressed in a different patch, this
patch solves a more severe lockup. Opinions?
-- 
Kind regards,
Peter Wu
https://lekensteyn.nl
