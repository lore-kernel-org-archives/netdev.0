From: jamal <hadi@cyberus.ca>
Subject: PATCH: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy
	device post.
Date: 05 Jun 2004 09:24:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086441896.1592.137.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
	 <1082816083.1054.32.camel@jzny.localdomain>
	 <1083007898.7788.276.camel@localhost>
	 <1084017322.1041.30.camel@jzny.localdomain>
	 <1084209482.758.15.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jsR7AYdCRp5xrNxzP/0m"
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <1084209482.758.15.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-jsR7AYdCRp5xrNxzP/0m
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Ok, trivial patch attached. Applies to both latest 2.6 and 2.4
I will go hunting for more drivers that do this; for now, a good start
here.

cheers,
jamal


On Mon, 2004-05-10 at 13:18, Max Krasnyansky wrote:
> On Sat, 2004-05-08 at 04:55, jamal wrote:
> > Max, Dave, Jeff,
> > 
> > I get what was bothering me now - it took me a while to formulate it:
> > 
> > TUN_TUN_DEV dev->type is ARPHRD_PPP
> > dev->type is really related to link layer header, perhaps at the low
> > level if neighbor discovery works well then we have a link-headerless
> > packet which gets manipulated with the correct header by some generic
> > code. The combination of dev->type and dev->hard_header_len works
> > together to achieve this.
> > In the case of TUN_TUN_DEV, the header_len is 0 ;->
> > To be of type ARPHRD_PPP, tun needs to have a header_len which is the
> > size of the l2 ppp header.
> > As an example, TUN_TAP_DEV is fine as type ARPHRD_ETHER and header_len
> > of ETH_HLEN.
> > 
> > A lot of devices are abusing this system, tun is not the only one.
> > 
> > My suggestion is to change dev->type to ARPHRD_VOID for TUN_TUN_DEV or
> > we introduce something like ARPHDR_NONE for devices with link layer
> > headers of size 0.
> > 
> > thoughts?
> 
> I have no problem with that. I mean introducing new ARPHDR_ type.
> ARPHDR_PPP was simply most appropriate for TUN that's why I picked it.
> I vote for ARPHDR_NONE.
> 
> Thanks
> Max
> 
> 
> 
> 

--=-jsR7AYdCRp5xrNxzP/0m
Content-Disposition: attachment; filename=tun24
Content-Type: text/plain; name=tun24; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /usr/src/2426/include/linux/if_arp.h	2002-02-25 14:38:13.000000000 -0500
+++ /usr/src/2426-mod/include/linux/if_arp.h	2004-06-04 15:10:15.000000000 -0400
@@ -85,6 +85,7 @@
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
+#define ARPHRD_NONE	  0xFFFE	/* zero header length */
 
 /* ARP protocol opcodes. */
 #define	ARPOP_REQUEST	1		/* ARP request			*/
--- /usr/src/2426/drivers/net/tun.c	2002-08-02 20:39:44.000000000 -0400
+++ /usr/src/2426-mod/drivers/net/tun.c	2004-06-04 15:10:50.000000000 -0400
@@ -138,8 +138,8 @@
 		dev->addr_len = 0;
 		dev->mtu = 1500;
 
-		/* Type PPP seems most suitable */
-		dev->type = ARPHRD_PPP; 
+		/* Zero header length */
+		dev->type = ARPHRD_NONE; 
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 		dev->tx_queue_len = 10;
 		break;

--=-jsR7AYdCRp5xrNxzP/0m--
