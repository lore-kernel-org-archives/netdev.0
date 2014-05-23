From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 11:33:46 +0200
Message-ID: <87vbsw4z5x.fsf@nemi.mork.no>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140522.171033.1040508444998374401.davem@davemloft.net>
	<87ppj5vupf.fsf@nemi.mork.no> <537F0DCA.6030901@mentor.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kamal@canonical.com>,
	<edumazet@google.com>, <mszeredi@suse.cz>, <fw@strlen.de>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537F0DCA.6030901@mentor.com> (Jim Baxter's message of "Fri, 23
	May 2014 09:58:50 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Jim Baxter <jim_baxter@mentor.com> writes:

>> I'll create and test a patch for the cdc_ncm host driver unless someone
>> else wants to do that. I haven't really played with the gadget driver
>> before, so I'd prefer if someone knowing it (Jim maybe?) could take care
>> of it.  If not, then I can always make an attempt using dummy_hcd to
>> test it.
> I can create a patch for the host driver, I will issue the gadget patch
> first to resolve any issues, the fix would be similar.

Well, I couldn't help myself.  I just had to test it.  The attached
patch works for me, briefly tested with an Ericsson H5321gw NCM device.
I have no ideas about the performance impact as that modem is limited to
21 Mbps HSDPA.


Bj=C3=B8rn


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-net-cdc_ncm-reduce-skb-truesize-in-rx-path.patch
Content-Transfer-Encoding: quoted-printable

>From 4c7431cd046a6972e153e23249ad490a3692f9a3 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
Date: Fri, 23 May 2014 09:40:51 +0200
Subject: [RFC] net: cdc_ncm: reduce skb truesize in rx path
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Cloning the big skbs we use for USB buffering chokes up TCP and
SCTP because the socket memory limits are hitting earlier than
they should. It is better to unconditionally copy the unwrapped
packets to freshly allocated skbs.

Reported-by: Jim Baxter <jim_baxter@mentor.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 93c9ca9924eb..2bbbd65591c7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1289,12 +1289,11 @@ next_ndp:
 			break;
=20
 		} else {
-			skb =3D skb_clone(skb_in, GFP_ATOMIC);
+			/* create a fresh copy to reduce truesize */
+			skb =3D netdev_alloc_skb_ip_align(dev->net,  len);
 			if (!skb)
 				goto error;
-			skb->len =3D len;
-			skb->data =3D ((u8 *)skb_in->data) + offset;
-			skb_set_tail_pointer(skb, len);
+			memcpy(skb_put(skb, len), skb_in->data + offset, len);
 			usbnet_skb_return(dev, skb);
 			payload +=3D len;	/* count payload bytes in this NTB */
 		}
--=20
2.0.0.rc4


--=-=-=--
