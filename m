From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [PATCH] bluetooth : move children of connection device to NULL
	before connection down
Date: Thu, 24 Jan 2008 09:26:01 +0800
Message-ID: <20080124012601.GA2982@darkstar.te-china.tietoenator.com>
References: <20080121044913.GA4162@darkstar.te-china.tietoenator.com> <20080121045401.GB4162@darkstar.te-china.tietoenator.com> <20080121.031417.171098597.davem@davemloft.net> <1200982696.7978.148.camel@aeonflux> <20080123140629.c24d4d68.akpm@linux-foundation.org> <20080124011926.GA2950@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bluez-devel@lists.sourceforge.net, cornelia.huck@de.ibm.com,
	gombasg@sztaki.hu, htejun@gmail.com, viro@zeniv.linux.org.uk,
	kay.sievers@vrfy.org, greg@kroah.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753487AbYAXBcI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080124011926.GA2950@darkstar.te-china.tietoenator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2008 at 09:19:26AM +0800, Dave Young wrote:
> On Wed, Jan 23, 2008 at 02:06:29PM -0800, Andrew Morton wrote:
> > > On Tue, 22 Jan 2008 07:18:16 +0100 Marcel Holtmann <marcel@holtmann.org> wrote:
> > > Hi Dave,
> > > 
> > > > > Add people missed in cc-list.
> > > > 
> > > > Thanks Dave for your continued efforts on Bluetooth bugs like this.
> > > > 
> > > > Marcel, are you going to review/ACK/integrate/push-upstream/whatever
> > > > any of these Bluetooth patches?
> > > > 
> > > > It hasn't been getting much love from you as of late, you are one of
> > > > the listed maintainers, and I don't want to lose any of Dave's
> > > > valuable bug fixing work.
> > > 
> > > I will be fully back in business next week. Just got stuck in a project
> > > that needed 200% of my time to get it going.
> > >
> > 
> > These patches in -mm:
> > 
> > bluetooth-hidp_process_hid_control-remove-unnecessary-parameter-dealing.patch
> > bluetooth-uninlining.patch
> > drivers-bluetooth-bpa10xc-fix-memleak.patch
> > drivers-bluetooth-btsdioc-fix-double-free.patch
> > bluetooth-blacklist-another-broadcom-bcm2035-device.patch
> > bluetooth-rfcomm-tty_close-before-destruct.patch
> > hci_ldisc-fix-null-pointer-deref.patch
> > 
> > could benefit from some attention please.
> 
> Hi, andrew
> 
> For the patch bluetooth-rfcomm-tty_close-before-destruct.patch I have to rethinkabout it.
> 
> 1. The subject is not correct, should be rfcomm-tty-destroy-before-tty_close.
> 2. Don't know what I was thinking that time, could you replace it with the following better one? Sorry for that.
> 
> ---
> rfcomm dev could be deleted in tty_hangup, so we must not call rfcomm_dev_del again to prevent from destroying rfcomm dev before tty close.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> 
> ---
>  net/bluetooth/rfcomm/tty.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -upr a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
> --- a/net/bluetooth/rfcomm/tty.c	2008-01-24 09:03:59.000000000 +0800
> +++ b/net/bluetooth/rfcomm/tty.c	2008-01-24 09:03:59.000000000 +0800
> @@ -429,6 +429,8 @@ static int rfcomm_release_dev(void __use
>  	if (dev->tty)
>  		tty_vhangup(dev->tty);
>  
> +	if (!test_bit(RFCOMM_RELEASE_ONHUP, &dev->flags))
> +		rfcomm_dev_del(dev);
>  	rfcomm_dev_del(dev);
	~~~~~~~~~~~~~~~~~
>  	rfcomm_dev_put(dev);
>  	return 0;

Please ignore the previous silly one, now resubmit :
----------

rfcomm dev could be deleted in tty_hangup, so we must not call rfcomm_dev_del again to prevent from destroying rfcomm dev before tty close.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

---
 net/bluetooth/rfcomm/tty.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -upr a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
--- a/net/bluetooth/rfcomm/tty.c	2008-01-24 09:21:56.000000000 +0800
+++ b/net/bluetooth/rfcomm/tty.c	2008-01-24 09:21:56.000000000 +0800
@@ -429,7 +429,8 @@ static int rfcomm_release_dev(void __use
 	if (dev->tty)
 		tty_vhangup(dev->tty);
 
-	rfcomm_dev_del(dev);
+	if (!test_bit(RFCOMM_RELEASE_ONHUP, &dev->flags))
+		rfcomm_dev_del(dev);
 	rfcomm_dev_put(dev);
 	return 0;
 }
