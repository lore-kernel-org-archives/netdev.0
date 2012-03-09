From: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference
 on tty_close
Date: Fri, 9 Mar 2012 14:04:13 +0100
Message-ID: <20120309130413.GC4497@localhost>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
 <1331136120-27075-2-git-send-email-jhovold@gmail.com>
 <1331148797.3392.191.camel@aeonflux>
 <20120308115721.GB4497@localhost>
 <1331228722.14217.7.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1331228722.14217.7.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2012 at 09:45:22AM -0800, Marcel Holtmann wrote:
> Hi Johan,
> 
> > > > Do not close protocol driver until device has been unregistered.
> > > > 
> > > > This fixes a race between tty_close and hci_dev_open which can result in
> > > > a NULL-pointer dereference.
> > > > 
> > > > The line discipline closes the protocol driver while we may still have
> > > > hci_dev_open sleeping on the req_lock mutex resulting in a NULL-pointer
> > > > dereference when lock is acquired and hci_init_req called.
> > 
> > [...]
> > 
> > > what kernel version is this against? Our changes in bluetooth-next fixed
> > > some of the destruct handling.
> > 
> > This is against the latest rc as it needs to be fixed in 3.3, but I
> > missed a dependency to bluetooth-next as you point out below.
> > 
> > > Also hci_unregister_dev should be calling the destruct handler and thus
> > > your change is now accessing hu but it got freed already.
> > 
> > You're right, my patch depends on 010666a126fc ("Bluetooth: Make
> > hci-destruct callback optional") and 797fe796c4 ("Bluetooth: uart-ldisc:
> > Fix memory leak and remove destruct cb") from bluetooth-next. 
> > 
> > But since the latter one fixes a memory leak it should have been marked
> > for stable as well as pushed to Linus for 3.3, right?
> 
> we need to look into this and propose patches for -stable. Is your
> problem still present with bluetooth-next or not?

Yes, both races are present in bluetooth-next of today (b8622cbd58f34)
and only takes an additional manual step to trigger (as the core no
longer tries to open the device twice automatically).

My two patches on top of either the two patches by David Herrmann
mentioned above or the following minimal fix of the same memory leak
would be sufficient to fix both races in 3.3:

diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 0711448..97c5faa 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -237,7 +237,6 @@ static void hci_uart_destruct(struct hci_dev *hdev)
                return;
 
        BT_DBG("%s", hdev->name);
-       kfree(hdev->driver_data);
 }
 
 /* ------ LDISC part ------ */
@@ -316,6 +315,7 @@ static void hci_uart_tty_close(struct tty_struct *tty)
                                hci_free_dev(hdev);
                        }
                }
+               kfree(hu);
        }
 }


Thanks,
Johan
