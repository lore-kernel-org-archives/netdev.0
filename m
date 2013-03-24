From: Sven Hartge <sven@svenhartge.de>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 01:36:33 +0100
Message-ID: <69jo698argv8@mids.svenhartge.de>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com> <20130323150655.GA10779@order.stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:35764 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329Ab3CXAjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Mar 2013 20:39:42 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UJYyi-0000Gz-EZ
	for netdev@vger.kernel.org; Sun, 24 Mar 2013 01:40:04 +0100
Received: from ip-178-200-42-118.unitymediagroup.de ([178.200.42.118])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 01:40:04 +0100
Received: from sven by ip-178-200-42-118.unitymediagroup.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 01:40:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On Sat, Mar 23, 2013 at 12:54:25AM -0400, rebelyouth wrote:
>> I applied your patch on my the kernel 3.7.9 and look like the patch do 
>> what you said before :
>> 
>> "This does not solve the real problem, which I have not yet understood 
>> (wrong packets will be discarded now and will be hopefully resend). "
>> 
>> There are errors on the RX side of the server and the speed is 5~10% 
>> less but the files are ok in nfsv4 , SFTP/FTP and samba.
>> 
>> Maybe the Atheros drivers for windows had a patch for the checksum 
>> already in the drivers and the chipset  have some hardware bug, but for 
>> me your patch is already an achievement and I really thank you for your 
>> time and consideration.

> The upstream driver (which is a tarball I found with google
> AR81Family-linux-v1.0.1.14.tar.gz) has this function ifdefed out. I have
> a couple of more things I want to test as soon as I have access to the
> hardware again.  If I don't find a better solution I will submit a patch
> which disables rx checksumming as a whole for inclusion to net-next.

I remember having the some problem with an atl1e chip on my Asus
PQ5-Pro. It would corrupt ethernet frames, resulting in dropped
connections when using SSH (bailing out with a HMAC crypto error) etc.

After some conversations with an Atheros engineer (Jie Yang
<Jie.Yang@Atheros.com>) I got the following patch, which I applied for
some time to my local Debian kernel packages. It fixed the problem for
me, until I switched the board to a newer one.

As far as I understand, this patch rips out any checksumming function
and just advertises the chip as not using and providing any.

My mail archive indicates, this bug has been fixed in the upstream atl1e
driver since version l1c-linux-v1.0.0.11-test.tar.gz.

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 9fc6d6d..73d44d5 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1343,29 +1343,8 @@ static inline void atl1e_rx_checksum(struct atl1e_adapter *adapter,
 {
       u8 *packet = (u8 *)(prrs + 1);
       struct iphdr *iph;
-      u16 head_len = ETH_HLEN;
-      u16 pkt_flags;
-      u16 err_flags;
 
       skb->ip_summed = CHECKSUM_NONE;
-      pkt_flags = prrs->pkt_flag;
-      err_flags = prrs->err_flag;
-      if (((pkt_flags & RRS_IS_IPV4) || (pkt_flags & RRS_IS_IPV6)) &&
-              ((pkt_flags & RRS_IS_TCP) || (pkt_flags & RRS_IS_UDP))) {
-              if (pkt_flags & RRS_IS_IPV4) {
-                      if (pkt_flags & RRS_IS_802_3)
-                              head_len += 8;
-                      iph = (struct iphdr *) (packet + head_len);
-                      if (iph->frag_off != 0 && !(pkt_flags & RRS_IS_IP_DF))
-                              goto hw_xsum;
-              }
-              if (!(err_flags & (RRS_ERR_IP_CSUM | RRS_ERR_L4_CSUM))) {
-                      skb->ip_summed = CHECKSUM_UNNECESSARY;
-                      return;
-              }
-      }
-
-hw_xsum :
       return;
 }
 



-- 
Sigmentation fault. Core dumped.
