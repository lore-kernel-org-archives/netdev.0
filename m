From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Fw: [Bugme-new] [Bug 3992] New: Bondig. Not correct work function
 ARP Monitoring. Broken link.
Date: Tue, 11 Jan 2005 23:17:53 +0100
Message-ID: <41E45091.7030208@tpack.net>
References: <20050105133525.2bab2e09.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030505010805030005000500"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: stanislav@muhachev.petro.ru
In-Reply-To: <20050105133525.2bab2e09.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030505010805030005000500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j0BMHosh006303

> http://bugme.osdl.org/show_bug.cgi?id=3D3992
>=20
>            Summary: Bondig. Not correct work function ARP Monitoring. B=
roken
>                     link.
>     Kernel Version: 2.6.10
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: stanislav@muhachev.petro.ru
>=20
...
>=20
> bonding vpn1 & vpn2 =F2=EE bond0 (bonding default setup -> nothing fail=
over=20
> setings)
> link =EE=EA!(192.168.100.1-192.168.100.2)
>=20
> setting arp monitor in bonding (TUN/TAP driver not support Mii status)
> link down!

I am not sure I understand your setup completely ...
But as stated in bonding.txt, the ARP monitor requires the underlying
driver to update dev->trans_start and dev->last_rx.

Since the TUN/TAP driver doesn't maintain these, it could very well
explain the behavior you are seeing.

The patch below adds the required functionality to the TUN/TAP driver.
Please test if this helps in your case.

-Tommy

--------------030505010805030005000500
Content-Type: text/plain;
 name="tun.c.patch"
Content-Disposition: inline;
 filename="tun.c.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.6.10-bk14/drivers/net/tun.c	2005-01-10 16:28:48.000000000 +0100
+++ linux-2.6.10-work/drivers/net/tun.c	2005-01-11 23:05:56.759691345 +0100
@@ -92,6 +92,7 @@
 			goto drop;
 	}
 	skb_queue_tail(&tun->readq, skb);
+	dev->trans_start = jiffies;
 
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
@@ -240,6 +241,7 @@
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
  
 	netif_rx_ni(skb);
+	tun->dev->last_rx = jiffies;
    
 	tun->stats.rx_packets++;
 	tun->stats.rx_bytes += len;

--------------030505010805030005000500--
