From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bug 4279] New: When I try to start vpnc the net/core/skbuff.c:91
 crash
Date: Fri, 04 Mar 2005 19:48:47 +0100
Message-ID: <4228AD8F.4020000@trash.net>
References: <20050303095832.6a084856@dxpl.pdx.osdl.net> <4228A354.8020904@qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705000600020206010600"
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Max Krasnyansky <maxk@qualcomm.com>
In-Reply-To: <4228A354.8020904@qualcomm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010705000600020206010600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Max Krasnyansky wrote:
> Hi Stephen,
> 
>> Looks like a something wrong with tun driver on 2.6.11
> 
> Thanks for forwarding this. I'll take a look at it.
> As far as I remember nothing really changed in the TUN write logic.
> Must be some other changes broke it.

This check is wrong, gcc optimizes it away:

                if ((len -= sizeof(pi)) > len)
			return -EINVAL;

This could be responsible for the BUG. If len is 2 or 3 and TUN_NO_PI
isn't set it underflows. alloc_skb() allocates len + 2, which is 0 or
1 byte. skb_reserve tries to reserve 2 bytes and things explode in
skb_put.

Regards
Patrick

--------------010705000600020206010600
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/04 19:41:29+01:00 kaber@coreworks.de 
#   [TUN]: Fix check for underflow
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# drivers/net/tun.c
#   2005/03/04 19:41:20+01:00 kaber@coreworks.de +1 -1
#   [TUN]: Fix check for underflow
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	2005-03-04 19:41:56 +01:00
+++ b/drivers/net/tun.c	2005-03-04 19:41:56 +01:00
@@ -229,7 +229,7 @@
 	size_t len = count;
 
 	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) > len)
+		if ((len -= sizeof(pi)) > count)
 			return -EINVAL;
 
 		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))

--------------010705000600020206010600--
