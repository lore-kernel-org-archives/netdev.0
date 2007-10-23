From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] USB: net: Fix asix read transfer
	buffer allocations.
Date: Tue, 23 Oct 2007 19:00:14 +0200
Message-ID: <200710231900.14696.netdev@axxeo.de>
References: <20071022155053.GA28526@ru.mvista.com>
	<200710221929.04035.oliver@neukum.org>
	<471CF893.3050605@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <471CF893.3050605@ru.mvista.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Valentine Barshak schrieb:
> Oliver Neukum wrote:
> > Am Montag 22 Oktober 2007 schrieb Valentine Barshak:
> >>  static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
> >>  {
> >>         struct usbnet *dev = netdev_priv(netdev);
> >> +       void *buf;
> >>         u16 res;
> >>  
> >>         mutex_lock(&dev->phy_mutex);
> >>         asix_set_sw_mii(dev);
> >> +
> >> +       buf = kmalloc(2, GFP_KERNEL);
> > 
> > This is done under lock. Can you allocate the buffer once and reuse it?
> I think we can use 2 bytes of the usbnet data buffer for this.
> I'll submit a new patch soon.

If this cannot be done for some reason, then you can at least kmalloc() before
you do "mutex_lock(&dev->phy_mutex);" and kfree() after you did 
"mutex_unlock(&dev->phy_mutex);"

The reason to can do this, is that "buf" has a life time limited to this function.

The reason you should do this, is that kmalloc(, GFP_KERNEL) is allowed to sleep,
which will block the mutex for that time. While this is technically ok, 
since mutexes can sleep, it is not desireable, since other users of that mutex
are blocked until the allocation is done.

If you are able to implement the "2 bytes of  usbnet data buffer" version,
please ignore that mail :-)


Best Regards

Ingo Oeser

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
