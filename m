From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 02 Dec 2014 12:21:18 +0100
Message-ID: <87fvcyqoup.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<87ppc957h1.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1411271037050.9464@gmail.com>
	<874mtl55ar.fsf@nemi.mork.no>
	<CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
	<alpine.LNX.2.03.1411271932510.1548@gmail.com>
	<87ppc71xne.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412012202480.1301@gmail.com>
	<B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
	<547D37CA.7050506@audiocodes.com>
	<alpine.LNX.2.03.1412020729470.1351@gmail.com>
	<547D5F84.6020608@audiocodes.com>
	<alpine.LNX.2.03.1412020747360.1921@gmail.com>
	<547D6D7B.5090704@audiocodes.com>
	<E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
	<547D7243.80508@audiocodes.com>
	<alpine.LNX.2.03.1412021130410.2697@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux\@gmail.com" <youtux@gmail.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39045 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933013AbaLBLV2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 06:21:28 -0500
In-Reply-To: <alpine.LNX.2.03.1412021130410.2697@gmail.com> (Enrico Mioso's
	message of "Tue, 2 Dec 2014 11:32:37 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Kevin - it works! the key seems to be in the tx_fixup function; there=
 is a=20
> special handling for frames effectively.
> Please ... help me backport those changes to the standard Linux drive=
r - it=20
> will be a gain for us all, and in general you'll have a more probable=
=20
> maintenance than you would with the driver from huawei.

Very interesting.  The NCM code in the huawei driver has a different
origin, so it is quite different and not too easy to merge into the
existing Linux cdc_ncm driver.

But this does pinpoint differences we should explore.  One is the
placement of the NDP: The Huawei driver puts it at the end.  Another,
which is much easier to test out quickly, is the sequence numbering: Th=
e
Huawei driver doesn't use it.

So I wonder if this makes any difference:

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 80a844e0ae03..37f11770acb6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1049,7 +1049,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct =
sk_buff *skb, __le32 sign)
 		nth16 =3D (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof=
(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
 		nth16->dwSignature =3D cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
 		nth16->wHeaderLength =3D cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16=
));
-		nth16->wSequence =3D cpu_to_le16(ctx->tx_seq++);
+//		nth16->wSequence =3D cpu_to_le16(ctx->tx_seq++);
=20
 		/* count total number of frames in this NTB */
 		ctx->tx_curr_frame_num =3D 0;



Bj=C3=B8rn
