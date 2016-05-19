From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable v2] net: cdc_ncm: update datagram size after changing mtu
Date: Thu, 19 May 2016 20:22:53 +0200
Message-ID: <877fepx5z6.fsf@nemi.mork.no>
References: <1463651769-27513-1-git-send-email-robert.dobrowolski@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, stable@vger.kernel.org,
	oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rafal Redzimski <rafal.f.redzimski@intel.com>
To: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52987 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261AbcESSXY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:23:24 -0400
In-Reply-To: <1463651769-27513-1-git-send-email-robert.dobrowolski@linux.intel.com>
	(Robert Dobrowolski's message of "Thu, 19 May 2016 11:56:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Dobrowolski <robert.dobrowolski@linux.intel.com> writes:

> From: Rafal Redzimski <rafal.f.redzimski@intel.com>
>
> Current implementation updates the mtu size and notify cdc_ncm
> device using USB_CDC_SET_MAX_DATAGRAM_SIZE request about datagram
> size change instead of changing rx_urb_size.
>
> Whenever mtu is being changed, datagram size should also be
> updated. Also updating maxmtu formula so it takes max_datagram_size w=
ith
> use of cdc_ncm_max_dgram_size() and not ctx.
>
> Signed-off-by: Robert Dobrowolski <robert.dobrowolski@linux.intel.com=
>
> Signed-off-by: Rafal Redzimski <rafal.f.redzimski@intel.com>
> ---
> Changes in v2:
> - Changed the way maxmtu is being calculated. Its now based
> on cdc_ncm_max_dgram_size and not on ctx->max_datagram_size.
> New datagram size is calculated correctly.
>
>  drivers/net/usb/cdc_ncm.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 2fb31ed..53759c3 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -740,12 +740,14 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ct=
x)
>  int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
>  {
>  	struct usbnet *dev =3D netdev_priv(net);
> -	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
> -	int maxmtu =3D ctx->max_datagram_size - cdc_ncm_eth_hlen(dev);
> +	int maxmtu =3D cdc_ncm_max_dgram_size(dev) - cdc_ncm_eth_hlen(dev);
> =20
>  	if (new_mtu <=3D 0 || new_mtu > maxmtu)
>  		return -EINVAL;
> +
>  	net->mtu =3D new_mtu;
> +	cdc_ncm_set_dgram_size(dev, new_mtu + cdc_ncm_eth_hlen(dev));
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(cdc_ncm_change_mtu);


Looking very good to me, although I cannot make it do anything useful
with my current test device. I am a bit curious about what your device
descriptor looks like if you actually hit this problem...

But your patch is a nice improvement in any case, so FWIW:

Revieved-by: Bj=C3=B8rn Mork <bjorn@mork.no>


tl;dr
My quick test was done with an MBIM device having:

      CDC MBIM:
        bcdMBIMVersion       1.00
        wMaxControlMessage   4096
        bNumberFilters       32
        bMaxFilterSize       128
        wMaxSegmentSize      2048
        bmNetworkCapabilities 0x20
          8-byte ntb input size
      CDC MBIM Extended:
        bcdMBIMExtendedVersion           1.00
        bMaxOutstandingCommandMessages     64
        wMTU                             1500


Your change has no effect for this device. Why? Because
cdc_ncm_max_dgram_size() returns 2048 from the wMaxSegmentSize.  But
cdc_ncm_set_dgram_size() clamps the new value between
CDC_MBIM_MIN_DATAGRAM_SIZE (2048) and CDC_NCM_MAX_DATAGRAM_SIZE (8192).
So the only possible datagram size for this device is 2048, and we will
never send a new segment size to the device.

I wonder if the cdc_ncm_set_dgram_size() clamping can possibly be
correct.  What do yout think?  CDC_MBIM_MIN_DATAGRAM_SIZE is the minimu=
m
*wMaxSegmentSize* according to the MBIM spec, but I can't see anything
saying that you can't set a lower segment size. Why shouldn't that be
possible? Must be a bug AFAICS.

The issue is the same for NCM, only with different defaults.  We use
1514 as the lowest possible segment size we can set, while this is
really supposed to be the lowest *maximum* segment size.

And then we come to the extended MBIM descriptor, with the wMTU which i=
s
applied as an additional ceiling on the main MBIM interface.  This is
wrong. We support multiplexing both IP and non-IP sessions on top of th=
e
main MBIM interface, and the wMTU should only be applied to IP sessions=
=2E
Applying it to the main MBIM interface makes it a hard limit for all
sessions.

The wMTU post-processing also results in inconsistent error reporting.
Attempting to set the MTU larger than wMaxSegmentSize correctly returns
an error with your patch:

 nemi:/tmp# ip link set dev wwan0 mtu 2100
 RTNETLINK answers: Invalid argument

But setting an MTU anywhere between wMTU and wMaxSegmentSize is silentl=
y
rejected:

 nemi:/tmp# ip link set dev wwan0 mtu 2000
 nemi:/tmp# ip link show dev wwan0=20
 42: wwan0: <BROADCAST,MULTICAST,NOARP> mtu 1500 qdisc noop state DOWN =
mode DEFAULT group default qlen 1000
     link/ether ee:76:bf:b6:fc:78 brd ff:ff:ff:ff:ff:ff
=20
I believe the current cdc_ncm_set_dgram_size() code stinks.  At the ver=
y
least, it should return errors which you could propagate.  But we shoul=
d
also split up handling of the two different MTU limits, so they can be
applied only where applicable.

I'll put this somewhere on my mental todo-list (which means that it is
lost already :).  Feel free to pick it up if you like.  In any case:
Thanks a lot for starting to fix up this stuff.  It's long overdue.


Bj=C3=B8rn
