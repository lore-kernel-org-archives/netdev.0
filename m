From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Wed, 19 May 2004 11:30:28 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405190256010.30653@fcat>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
 <Pine.LNX.4.58.0405151354220.9894@fcat>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.58.0405151354220.9894@fcat>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 May 2004, Marc Herbert wrote:

> <http://oss.sgi.com/projects/netdev/archive/2003-09/threads.html#00247>
>
> Sorry to exhume this discussion but I only recently discovered this
> change, the hard way.
>

> I am unfortunately not familiar with this part of the linux kernel,
> but I really think that, if possible, txqueuelen should be initialized
> at some "constant 12=A0ms" and not at the "1000 packets" highly variabl=
e
> latency setting. I=A0can imagine there are some corner cases, like for
> instance when some GEth NIC is hot-plugged into a 100=A0Mb/s, or jumbo
> frames, but hey, those are corner cases : as a first step, even a
> simple constant-per-model txqueuelen initialization would be already
> great.

After some further study, I was glad to discover my suggestion above
both easy and short to implement. See patch below.

Trying to sum-it up:

- Ricardo asks (among others) for a new 1000 packets default
  txqueuelen for Intel's e1000, based on some data (couldn't not find
  this data, please send me the pointer if you have it, thanks).

- Me argues that we all lived happy for ages with this default
  setting of 100=A0packets @=A0100=A0Mb/s (and lived approximately happy =
@
  10 Mb/s), but we'll soon see doom and gloom with this new and
  brutal change to 1000=A0packets for all this _legacy_ 10-100 Mb/s
  hardware. e1000 data only is not enough to justify this radical
  shift.

If you are convinced by _both_ items above, then the patch below
content _both_, and we're done.

If you are not, then... wait for further discussion, including answers
to latest Ricardo's post.


PS: several people seem to think TCP "drops" packets when the qdisc is
full. My analysis of the code _and_=A0my experiments makes me think they
are wrong: TCP rather "blocks" when the qdisc is full. See explanation
here: <http://oss.sgi.com/archives/netdev/2004-05/msg00151.html>
(Subject: Re: TcpOutSegs way too optimistic (netstat -s))


=3D=3D=3D=3D=3D drivers/net/net_init.c 1.11 vs edited =3D=3D=3D=3D=3D
--- 1.11/drivers/net/net_init.c	Tue Sep 16 01:12:25 2003
+++ edited/drivers/net/net_init.c	Wed May 19 11:05:34 2004
@@ -420,7 +420,10 @@
 	dev->hard_header_len 	=3D ETH_HLEN;
 	dev->mtu		=3D 1500; /* eth_mtu */
 	dev->addr_len		=3D ETH_ALEN;
-	dev->tx_queue_len	=3D 1000;	/* Ethernet wants good queues */
+	dev->tx_queue_len	=3D 100; /* This is a sensible generic default for
+					100 Mb/s: about 12ms with 1500 full size packets.
+					Drivers should tune this depending on interface
+					specificities and settings */

 	memset(dev->broadcast,0xFF, ETH_ALEN);

=3D=3D=3D=3D=3D drivers/net/e1000/e1000_main.c 1.56 vs edited =3D=3D=3D=3D=
=3D
--- 1.56/drivers/net/e1000/e1000_main.c	Tue Feb  3 01:43:42 2004
+++ edited/drivers/net/e1000/e1000_main.c	Wed May 19 03:14:32 2004
@@ -400,6 +400,8 @@
 		err =3D -ENOMEM;
 		goto err_alloc_etherdev;
 	}
+
+	netdev->tx_queue_len =3D 1000;

 	SET_MODULE_OWNER(netdev);
