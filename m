From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 12:25:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912102529.GA27096@wotan.suse.de>
References: <20040908065152.GC27886@wotan.suse.de> <E1C4wYe-0005qT-00@gondolin.me.apana.org.au> <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net> <20040912100114.GB11484@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca, ak@suse.de,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040912100114.GB11484@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 12, 2004 at 06:01:14AM -0400, Jeff Garzik wrote:
> 
> Oh and update Documentation/networking/netdevice.txt.
> 
> If people are going to screw with the TX path, at least do it right and
> make it non-mysterious for everyone else.
> 
> See Al Viro's Documentation/filesystem/directory-locking doc for a
> proper way to document a locking change that potentially affects every
> net driver in the kernel.

<broken record mode>
No it doesn't. It only affects every driver who sets NETIF_F_LLTX.
For drivers that don't set this flag there is no change at all. 
</record>

I wasn't aware of Documentation/netdevices.txt, but I agree it 
would be a good idea to update it. Patch for that attached.
DaveM, please apply.

-Andi

---------------------------------------------------------------------

Add documentation for new NETIF_F_LLTX feature.


diff -u linux-2.6.8-work/Documentation/networking/netdevices.txt-o linux-2.6.8-work/Documentation/networking/netdevices.txt
--- linux-2.6.8-work/Documentation/networking/netdevices.txt-o	2004-03-21 21:12:11.000000000 +0100
+++ linux-2.6.8-work/Documentation/networking/netdevices.txt	2004-09-12 12:24:02.000000000 +0200
@@ -43,8 +43,21 @@
 
 dev->hard_start_xmit:
 	Synchronization: dev->xmit_lock spinlock.
+	When the driver sets NETIF_F_LLTX in dev->features this will be
+	called without holding xmit_lock. In this case the driver 
+	has to lock by itself when needed. It is recommended to use a try lock
+	for this and return -1 when the spin lock fails. 
+	The locking there should also properly protect against 
+	set_multicast_list
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed false
+	Return codes: 
+	0 everything ok. 
+	1 Cannot transmit packet, try later 
+	(usually a bug, means queue start/stop flow control is broken in your 
+	driver) 
+	-1 Locking failed, please retry quickly. Only valid when 
+	NETIF_F_LLTX is set.
 
 dev->tx_timeout:
 	Synchronization: dev->xmit_lock spinlock.
