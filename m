From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Wed, 04 Jun 2008 01:26:19 +0900 (JST)
Message-ID: <20080604.012619.30196060.yoshfuji@linux-ipv6.org>
References: <1212491322-9161-1-git-send-email-den@openvz.org>
	<20080603.203532.39634783.yoshfuji@linux-ipv6.org>
	<1212493845.6499.29.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58015 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbYFCQZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:25:41 -0400
In-Reply-To: <1212493845.6499.29.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212493845.6499.29.camel@iris.sw.ru> (at Tue, 03 Jun 2008 15:50:45 +0400), "Denis V. Lunev" <den@openvz.org> says:

> On Tue, 2008-06-03 at 20:35 +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <1212491322-9161-1-git-send-email-den@openvz.org> (at Tue,  3 Jun 2008 15:08:42 +0400), "Denis V. Lunev" <den@openvz.org> says:
> > 
> > > ip6_sk_dst_lookup returns held dst entry. It should be released on all paths
> > > beyond this point. Add missed release when up->pending is set.
> > 
> > Which kernel are you refering?
> The patch is made against current net-2.6 tree, though all kernels are
> affected, starting at least RHEL5
> 
> > And, would you please take a look at ipv4 side as well?
> 
> ipv4 is ok, the code looks the same but there is an ip_rt_put at the
> out: label.
> 

Okay, I think we have one more leakage here (in do_confirm path).
How about this?

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1fd784f..47123bf 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -848,12 +848,14 @@ do_append_data:
 		} else {
 			dst_release(dst);
 		}
+		dst = NULL;
 	}
 
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
 out:
+	dst_release(dst);
 	fl6_sock_release(flowlabel);
 	if (!err)
 		return len;

--yoshfuji
