From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] usbnet: remove generic hard_header_len check
Date: Thu, 13 Feb 2014 12:20:16 +0100
Message-ID: <20140213112016.GA4245@lianli>
References: <1392249836-27151-1-git-send-email-emilgoode@gmail.com>
 <87fvnn4c2k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <edumazet@google.com>,
	Ming Lei <ming.lei@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Liu Junliang <liujunliang_ljl@163.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fvnn4c2k.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 10:05:39AM +0100, Bj=C3=B8rn Mork wrote:
> Emil Goode <emilgoode@gmail.com> writes:
>=20
> > This patch removes a generic hard_header_len check from the usbnet
> > module that is causing dropped packages under certain circumstances
> > for devices that send rx packets that cross urb boundaries.
> >
> > One example is the AX88772B which occasionally send rx packets that
> > cross urb boundaries where the remaining partial packet is sent wit=
h
> > no hardware header. When the buffer with a partial packet is of les=
s
> > number of octets than the value of hard_header_len the buffer is
> > discarded by the usbnet module.
> >
> > With AX88772B this can be reproduced by using ping with a packet
> > size between 1965-1976.
> >
> > The bug has been reported here:
> >
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D29082
> >
> > This patch introduces the following changes:
> > - Removes the generic hard_header_len check in the rx_complete
> >   function in the usbnet module.
> > - Introduces a ETH_HLEN check for skbs that are not cloned from
> >   within a rx_fixup callback.
> > - For safety a hard_header_len check is added to each rx_fixup
> >   callback function that could be affected by this change.
> >   These extra checks could possibly be removed by someone
> >   who has the hardware to test.
> >
> > The changes place full responsibility on the rx_fixup callback
> > functions that clone skbs to only pass valid skbs to the
> > usbnet_skb_return function.
> >
> > Signed-off-by: Emil Goode <emilgoode@gmail.com>
> > Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
>=20
>=20
> Great work!  Looks good to me.

Thank you :)

> Just a couple of questions:
>=20
> > diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.=
c
> > index ff5c871..b2e2aee 100644
> > --- a/drivers/net/usb/qmi_wwan.c
> > +++ b/drivers/net/usb/qmi_wwan.c
> > @@ -80,10 +80,10 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev=
, struct sk_buff *skb)
> >  {
> >  	__be16 proto;
> > =20
> > -	/* usbnet rx_complete guarantees that skb->len is at least
> > -	 * hard_header_len, so we can inspect the dest address without
> > -	 * checking skb->len
> > -	 */
> > +	/* This check is no longer done by usbnet */
> > +	if (skb->len < dev->net->hard_header_len)
> > +		return 0;
> > +
> >  	switch (skb->data[0] & 0xf0) {
> >  	case 0x40:
> >  		proto =3D htons(ETH_P_IP);
> > diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_h=
ost.c
> > index a48bc0f..524a47a 100644
> > --- a/drivers/net/usb/rndis_host.c
> > +++ b/drivers/net/usb/rndis_host.c
> > @@ -492,6 +492,10 @@ EXPORT_SYMBOL_GPL(rndis_unbind);
> >   */
> >  int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> >  {
> > +	/* This check is no longer done by usbnet */
> > +	if (skb->len < dev->net->hard_header_len)
> > +		return 0;
> > +
>=20
> Wouldn't it be better to test against ETH_HLEN, since that is a const=
ant
> and "obviously correct" in this case?
=20
Some minidrivers change the default hard_header_len value so using it
guarantees that the patch will not make any change to how the code is
currently working. Using ETH_HLEN could be more informative about what
the minidriver should check before passing skbs to usbnet_skb_return().
Then I think the comment should be changed as well. My intention was to
not make any changes that affect how the code works for devices I canno=
t
test, but I think either way is fine and if you insist on changing it
let me know.

> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> > index 4671da7..dd10d58 100644
> > --- a/drivers/net/usb/usbnet.c
> > +++ b/drivers/net/usb/usbnet.c
> > @@ -542,17 +542,19 @@ static inline void rx_process (struct usbnet =
*dev, struct sk_buff *skb)
> >  	}
> >  	// else network stack removes extra byte if we forced a short pac=
ket
> > =20
> > -	if (skb->len) {
> > -		/* all data was already cloned from skb inside the driver */
> > -		if (dev->driver_info->flags & FLAG_MULTI_PACKET)
> > -			dev_kfree_skb_any(skb);
> > -		else
> > -			usbnet_skb_return(dev, skb);
> > +	/* all data was already cloned from skb inside the driver */
> > +	if (dev->driver_info->flags & FLAG_MULTI_PACKET)
> > +		goto done;
> > +
> > +	if (skb->len < ETH_HLEN) {
> > +		dev->net->stats.rx_errors++;
> > +		dev->net->stats.rx_length_errors++;
> > +		netif_dbg(dev, rx_err, dev->net, "rx length %d\n", skb->len);
> > +	} else {
> > +		usbnet_skb_return(dev, skb);
> >  		return;
> >  	}
> > =20
> > -	netif_dbg(dev, rx_err, dev->net, "drop\n");
> > -	dev->net->stats.rx_errors++;
> >  done:
> >  	skb_queue_tail(&dev->done, skb);
> >  }
>=20
>=20
> At first glance I wondered where the dev_kfree_skb_any(skb) went.  Bu=
t
> then I realized that you leave that to the common rx_cleanup path, us=
ing
> the dev->done queue.  Is that right?  If so, then I guess it could us=
e a
> bit of explaining in the commit message?

Yes I should have put a comment in the changelog about this. All skbs t=
hat
are passed to rx_process have their state set to rx_cleanup and just be=
cause
the skb was cloned doesn't mean that we should free the original in a
different way. As it is I think we are acctually missing a call to
usb_free_urb that is called on the common rx_cleanup path.
I will resend and add a comment about this.

Best regards,

Emil Goode
