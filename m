From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 2/4] net: cdc_mbim: reject IP packets on DSS VLANs
Date: Sun, 11 May 2014 00:17:21 +0200
Message-ID: <1399760243-26625-3-git-send-email-bjorn@mork.no>
References: <1399760243-26625-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51096 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755500AbaEJWRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 18:17:42 -0400
In-Reply-To: <1399760243-26625-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSS VLANs are pseudo network interfaces representing arbitrary
data streams, and specifically not IP. Preventing spurious IP
packets can sometimes be a hassle. The kernel will for example
send an IPv6 Router Solicit when the interface is brought up
unless the user has been careful enough to disable IPv6 first.
Such packets forwared to a MBIM DSS session will look like
spurious noise to the device, and can cause it to log an error
or even malfunction.

Drop all IP packets on the designated DSS VLANs to prevent such
unwanted spurious transmissions.

Cc: Greg Suarez <gsuarez@smithmicro.com>
Reported-by: Arnaud Desmier <adesmier@sequans.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index dbc19fd945a9..beb8b95160a5 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -237,6 +237,8 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 			c[3] =3D tci;
 			break;
 		case 0x0100: /* VLAN ID 256 - 511 */
+			if (is_ip)
+				goto error;
 			sign =3D cpu_to_le32(USB_CDC_MBIM_NDP16_DSS_SIGN);
 			c =3D (u8 *)&sign;
 			c[3] =3D tci;
--=20
2.0.0.rc2
