From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.7: sk98lin unload oops
Date: Sun, 4 Jul 2004 16:23:52 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040704152352.GA5243@infradead.org>
References: <200407041342.18821.bernd-schubert@web.de> <20040704151509.GA5100@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265727AbUGDPXz@vger.kernel.org>
To: Bernd Schubert <bernd-schubert@web.de>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040704151509.GA5100@infradead.org>
List-Id: netdev.vger.kernel.org

On Sun, Jul 04, 2004 at 04:15:09PM +0100, Christoph Hellwig wrote:
> > Fortunality everything still works fine (I'm running the script over the 
> > network of the syskonnect cards).
> > 
> > This machine has two of those syskonnect cards, on another machine which has 
> > only one syskonnect card this oops doesn't occur.
> 
> As a colleteral damage the following huge patch should fix it, and I need
> testers for it anyway ;-)

Actually the problem sits deeper.  sk98line tries to register a procfile with
the interfacename of the struct net_device.  The patch below (ontop of
the previous one) makes it work unless you change the interface name manually,
but as Linux explicitly allows that the interface is fundamentally broken and
probably should just go away.


--- drivers/net/sk98lin/skge.c~	2004-07-04 19:15:43.219326648 +0200
+++ drivers/net/sk98lin/skge.c	2004-07-04 19:18:21.562254864 +0200
@@ -5119,9 +5119,12 @@
 	if ((pAC->GIni.GIMacsFound == 2) && pAC->RlmtNets == 2)
 		have_second_mac = 1;
 
+	remove_proc_entry(dev->name, pSkRootDir);
 	unregister_netdev(dev);
-	if (have_second_mac)
+	if (have_second_mac) {
+		remove_proc_entry(pAC->dev[1]->name, pSkRootDir);
 		unregister_netdev(pAC->dev[1]);
+	}
 
 	SkGeYellowLED(pAC, pAC->IoBase, 0);
 
