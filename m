From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Sat, 07 Feb 2004 14:25:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.142519.117436499.yoshfuji@linux-ipv6.org>
References: <20040207.132233.21960944.yoshfuji@linux-ipv6.org>
	<OF9F84892D.B2226F9C-ON88256E33.00185F62-88256E33.00196063@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF9F84892D.B2226F9C-ON88256E33.00185F62-88256E33.00196063@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF9F84892D.B2226F9C-ON88256E33.00185F62-88256E33.00196063@us.ibm.com> (at Fri, 6 Feb 2004 20:39:47 -0800), David Stevens <dlstevens@us.ibm.com> says:

> > Why not in icmpv6_rcv()?
> 
>       I don't understand this question. It's needed every place
> *except* icmpv6_rcv().

Sorry for any confusion.


> > > -     hdr = skb->nh.ipv6h;
> > > -     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
> > > -           deliver = 1;
> > > -
> 
> > Please do not remove this.
> > We need to check destination (but not source)
> > because the driver may be in "promisc." mode.
> 
>       I'm not removing it, I'm moving it. The original code
> is:
:
> 
> In promiscuous mode, it will parse the extension headers
> for non-local multicasts before dropping them. But what
> you suggested will do two multicast address look-ups for
> every multicast packet (including the valid ones). One
> for the destination and another for the destination/source
> filter.

Yes, but it changes the original and traditional behavior.

Well...

It is okay not to check destination here with good hardware / driver.
We however should check the destination before the process of 
extension headers for bad hardware / driver.
ipv6_chk_mcast_addr() in ip6_mc_input() has been helper for them
We should keep it in ip6_mc_input().

So... hmm... Let's check dev->flags ^ (IFF_PROMISC|IFF_ALLMULTI) like this.
I don't think it is so costy for usual operation.
If you think it is, please introduce hash table for mc_list in idev;
it should have been "heavy." :-)
(You can do it later, of course.)

===== net/ipv6/ip6_input.c 1.14 vs edited =====
--- 1.14/net/ipv6/ip6_input.c	Tue Jun 17 00:11:36 2003
+++ edited/net/ipv6/ip6_input.c	Sat Feb  7 14:14:30 2004
@@ -218,7 +218,8 @@
 	IP6_INC_STATS_BH(Ip6InMcastPkts);
 
 	hdr = skb->nh.ipv6h;
-	if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
+	if ((skb->dev->flags ^ (IFF_PROMISC|IFF_ALLMULTI)) == 0 ||
+	    ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL))
 		deliver = 1;
 
 	/*
===== net/ipv6/mcast.c 1.50 vs edited =====
--- 1.50/net/ipv6/mcast.c	Thu Jan 29 09:06:25 2004
+++ edited/net/ipv6/mcast.c	Sat Feb  7 13:58:58 2004
@@ -918,7 +918,7 @@
 				break;
 		}
 		if (mc) {
-			if (!ipv6_addr_any(src_addr)) {
+			if (src_addr && !ipv6_addr_any(src_addr)) {
 				struct ip6_sf_list *psf;
 
 				spin_lock_bh(&mc->mca_lock);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
