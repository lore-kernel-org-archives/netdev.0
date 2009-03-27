From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Fri, 27 Mar 2009 13:50:30 -0500
Message-ID: <ed82fe3e0903271150v34fc18cbua6bb7918a3a71c71@mail.gmail.com>
References: <OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>
	 <20090324.142209.234280606.davem@davemloft.net>
	 <OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>
	 <20090324.154902.206324978.davem@davemloft.net>
	 <OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, avorontsov@ru.mvista.com,
	leoli@freescale.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:53964 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbZC0Sue convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 14:50:34 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1391510qwh.37
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 11:50:31 -0700 (PDT)
In-Reply-To: <OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 6:08 PM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:

> + =A0 =A0 =A0 .ndo_change_mtu =A0 =A0 =A0 =A0 =3D eth_change_mtu,

I have an old patch for change_mtu support for ucc_geth which I've
been meaning to push upstream.  This patch uses this function instead
of eth_change_mtu():

+static int ucc_geth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	int max_rx_buf_length;
+	struct ucc_geth_private *ugeth =3D netdev_priv(dev);
+	int frame_size =3D new_mtu + 18;
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
+
+	if (ugeth->p_rx_glbl_pram) {
+		printk("%s: Interface is active!\n", __FUNCTION__);
+	} else {
+
+		ug_info =3D ugeth->ug_info;
+		uf_info =3D &ug_info->uf_info;
+
+		if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
+			printk(KERN_ERR "%s: Invalid MTU setting\n", dev->name);
+			return -EINVAL;
+		}
+
+		max_rx_buf_length =3D
+		    (frame_size & ~(UCC_GETH_MRBLR_ALIGNMENT - 1)) +
+		    UCC_GETH_MRBLR_ALIGNMENT;
+
+		ugeth->ug_info->uf_info.max_rx_buf_length =3D max_rx_buf_length;
+		dev->mtu =3D new_mtu;
+
+		/* Set the max. rx buffer size (MRBLR) */
+		uf_info->max_rx_buf_length =3D max_rx_buf_length;
+
+		/* set the max. frame length (MFLR) */
+		ug_info->maxFrameLength =3D frame_size;
+
+		ugeth_info("%s: MTU =3D %d (frame size=3D%d)\n", dev->name,
+		       dev->mtu, frame_size);
+	}
+	return 0;
+}

Do you think this is how it should be done?  I don't know enough about
ucc_geth and MTUs to know off-hand.

--=20
Timur Tabi
Linux kernel developer at Freescale
