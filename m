From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ipv4-mapped ipv4 connect() for UDP broken in test10
Date: Thu, 27 Nov 2003 21:11:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127.211135.09649297.yoshfuji@linux-ipv6.org>
References: <20031126081745.GA31415@codeblau.de>
	<20031126.190407.102714104.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
        felix-kernel@fefe.de
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031126.190407.102714104.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031126.190407.102714104.yoshfuji@linux-ipv6.org> (at Wed, 26 Nov 2003 19:04:07 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> (But I'm not sure this fix your problem...)

Well, let me clarify:

I'm sure the original code has a bug.
I do think that it is related to your report 
(but I don't have time to confirm it.)

s6_addr[3] should be s6_addr32[3] because the code is intended to extract 
IPv4 address from the IPv4-mapped address (::ffff:0.0.0.0/96)
to convert sockaddr_in6{} to sockaddr_in{}.

My analysis against the report is as follows:

Because the address is IPv4-mapped address (::ffff:0.0.0.0/96) at the point,
s6_addr[3] is always 0. The socket will be always connected to 0.0.0.0,
which means 127.0.0.1.

The patch is definitely logically correct.
Please apply this.  Thanks.

===== net/ipv6/udp.c 1.54 vs edited =====
--- 1.54/net/ipv6/udp.c	Tue Nov 18 11:41:56 2003
+++ edited/net/ipv6/udp.c	Wed Nov 26 19:01:15 2003
@@ -825,7 +825,7 @@
 			struct sockaddr_in sin;
 			sin.sin_family = AF_INET;
 			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
-			sin.sin_addr.s_addr = daddr->s6_addr[3];
+			sin.sin_addr.s_addr = daddr->s6_addr32[3];
 			msg->msg_name = &sin;
 			msg->msg_namelen = sizeof(sin);
 do_udp_sendmsg:

--yoshfuji
