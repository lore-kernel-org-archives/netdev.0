From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in
 ip6_route_add error paths
Date: Wed, 20 Oct 2004 15:35:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020.153525.50629727.yoshfuji@linux-ipv6.org>
References: <417591A2.4090201@trash.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Oct_20_15:35:25_2004_849)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <417591A2.4090201@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Wed_Oct_20_15:35:25_2004_849)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

In article <417591A2.4090201@trash.net> (at Wed, 20 Oct 2004 00:13:54 +0200), Patrick McHardy <kaber@trash.net> says:

> The recent changes to ip6_route_add added multiple leaks in
> error paths. This patch should fix them.

Agreed. David, please apply.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji

----Next_Part(Wed_Oct_20_15:35:25_2004_849)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Return-Path: <kaber@trash.net>
Delivered-To: yoshfuji@yue.st-paulia.net
Received: from sapphire.st-paulia.net (sapphire.linux-ipv6.org [203.178.140.14])
	by yue.st-paulia.net (Postfix) with ESMTP id 64A1433CE5
	for <yoshfuji@yue.st-paulia.net>; Wed, 20 Oct 2004 07:15:11 +0900 (JST)
Received: by sapphire.st-paulia.net (Postfix)
	id 5B3A223CF9; Wed, 20 Oct 2004 07:34:58 +0900 (JST)
Delivered-To: yoshfuji@sapphire.st-paulia.net
Received: from nezu.linux-ipv6.org (linux6.nezu.wide.ad.jp [203.178.142.218])
	by sapphire.st-paulia.net (Postfix) with ESMTP id 703B023CF8
	for <yoshfuji@sapphire.st-paulia.net>; Wed, 20 Oct 2004 07:34:55 +0900 (JST)
Received: from gw.localnet ([62.206.217.67])
	by nezu.linux-ipv6.org (8.13.1/8.13.1/Debian-13) with ESMTP id i9JMEMii001727
	for <yoshfuji@linux-ipv6.org>; Wed, 20 Oct 2004 07:14:25 +0900
Received: from [172.16.1.123] (helo=trash.net ident=kaber)
	by gw.localnet with esmtp (Exim 3.36 #1 (Debian))
	id 1CK2Ma-0002us-00; Wed, 20 Oct 2004 00:21:52 +0200
Message-ID: <417591A2.4090201@trash.net>
Date: Wed, 20 Oct 2004 00:13:54 +0200
From: Patrick McHardy <kaber@trash.net>
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040413 Debian/1.6-5
X-Accept-Language: en
MIME-Version: 1.0
To: "David S. Miller" <davem@redhat.com>
Cc: netdev@oss.sgi.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in ip6_route_add
 error paths
Content-Type: multipart/mixed;
 boundary="------------040705080908040609060609"

This is a multi-part message in MIME format.
--------------040705080908040609060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The recent changes to ip6_route_add added multiple leaks in
error paths. This patch should fix them.

Regards
Patrick


--------------040705080908040609060609
Content-Type: text/plain;
 name="p2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p2"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 23:46:56+02:00 kaber@coreworks.de 
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/route.c
#   2004/10/19 23:46:17+02:00 kaber@coreworks.de +8 -3
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
+++ b/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
@@ -798,8 +798,10 @@
 
 	rt = ip6_dst_alloc();
 
-	if (rt == NULL)
-		return -ENOMEM;
+	if (rt == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
 
 	rt->u.dst.obsolete = -1;
 	rt->rt6i_expires = clock_t_to_jiffies(rtmsg->rtmsg_info);
@@ -962,7 +964,10 @@
 out:
 	if (dev)
 		dev_put(dev);
-	dst_free((struct dst_entry *) rt);
+	if (idev)
+		in6_dev_put(idev);
+	if (rt)
+		dst_free((struct dst_entry *) rt);
 	return err;
 }
 

--------------040705080908040609060609--

----Next_Part(Wed_Oct_20_15:35:25_2004_849)----
