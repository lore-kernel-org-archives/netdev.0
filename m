From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/3] e1000e: increase skb size to prevent dma over skb
	boundary (v2)
Date: Mon, 7 Dec 2009 12:53:39 -0800
Message-ID: <9929d2390912071253w5413f701ub91d888a886fa714@mail.gmail.com>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
	 <20091207144817.GC8073@hmsreliant.think-freely.org>
	 <20091207160236.GF8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:39452 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935561AbZLGUxd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 15:53:33 -0500
Received: by pwj9 with SMTP id 9so1155016pwj.21
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 12:53:39 -0800 (PST)
In-Reply-To: <20091207160236.GF8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2009 at 08:02, Neil Horman <nhorman@tuxdriver.com> wrote=
:
> Sorry to reply to myself, but given the comments regarding the e1000 =
driver, I
> should take the same changes into account here. =C2=A0New version of =
the patch, much
> cleaner than previously.
>
>
> Update e1000e driver to not allow dma beyond the end of the allocated=
 sk
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>
>
> netdev.c | =C2=A0 14 +++++++++++++-
> 1 file changed, 13 insertions(+), 1 deletion(-)
>
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index c3105c5..84e1b5d 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -2332,6 +2332,16 @@ static void e1000_setup_rctl(struct e1000_adap=
ter *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Setup buffer sizes */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl &=3D ~E1000_RCTL_SZ_4096;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl |=3D E1000_RCTL_BSEX;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We need to normalize the rx_buffer_len=
 here
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* since the hardware only knows about 7 =
discrete
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* frame lengths here. =C2=A0To accomodat=
e that we need
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to set the rx length in the hardware t=
o the next highest
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* size over the rx_buffer_len, then incr=
ease rx_buffer_len
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to match it, so that we can get a full=
 mtu sized frame
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 adapter->rx_buffer_len =3D roundup_pow_of_two(=
adapter->rx_buffer_len);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (adapter->rx_buffer_len) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case 256:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl |=3D E100=
0_RCTL_SZ_256;
> @@ -2346,7 +2356,6 @@ static void e1000_setup_rctl(struct e1000_adapt=
er *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl &=3D ~E10=
00_RCTL_BSEX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case 2048:
> - =C2=A0 =C2=A0 =C2=A0 default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl |=3D E100=
0_RCTL_SZ_2048;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl &=3D ~E10=
00_RCTL_BSEX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> @@ -2359,6 +2368,9 @@ static void e1000_setup_rctl(struct e1000_adapt=
er *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case 16384:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rctl |=3D E100=
0_RCTL_SZ_16384;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 panic("Bad rx_buff=
er_len size\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> --

I have added this patch to my queue of e1000e patches for
reveiw/testing.  Upon successful review/testing I will submit to
Dave/netdev.

--=20
Cheers,
Jeff
