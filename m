From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] fix select() for SOCK_RAW sockets
Date: Tue, 7 Dec 2004 07:08:34 -0800
Message-ID: <20041207150834.GA75700@gaz.sfgoth.com>
References: <20041207003525.GA22933@linuxace.com> <20041207025218.GB61527@gaz.sfgoth.com> <20041207045302.GA23746@linuxace.com> <20041207054840.GD61527@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>, "David S. Miller" <davem@davemloft.net>,
        shemminger@osdl.org
Content-Disposition: inline
In-Reply-To: <20041207054840.GD61527@gaz.sfgoth.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Phil: Here's a real patch for you to test.  I actually left inet_dgram_ops
alone since it's an exported symbol (two of the users just want the .do_ioctl
value which is the same between SOCK_DGRAM and SOCK_RAW; the other is ipv6
where it's clearly dealing with a UDP socket -- therefore I think its safest
to leave inet_dgram_ops to have the UDP behavior)

Davem: I only tested that this doesn't break UDP; if it works for Phil and
Stephen can verify that it doesn't break his bad-checksum UDP tests then
please push it for 2.6.10.

Patch is versus 2.6.10-rc3.

Signed-off-by: Mitchell Blank Jr <mitch@sfgoth.com>

-Mitch
--- linux-2.6.10-rc3-VIRGIN/net/ipv4/af_inet.c	2004-12-07 06:37:52.480082706 -0800
+++ linux-2.6.10-rc3/net/ipv4/af_inet.c	2004-12-07 06:57:47.799013216 -0800
@@ -821,6 +821,31 @@
 	.sendpage =	inet_sendpage,
 };
 
+/*
+ * For SOCK_RAW sockets; should be the same as inet_dgram_ops but without
+ * udp_poll
+ */
+static struct proto_ops inet_sockraw_ops = {
+	.family =	PF_INET,
+	.owner =	THIS_MODULE,
+	.release =	inet_release,
+	.bind =		inet_bind,
+	.connect =	inet_dgram_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	inet_getname,
+	.poll =		datagram_poll,
+	.ioctl =	inet_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	inet_shutdown,
+	.setsockopt =	sock_common_setsockopt,
+	.getsockopt =	sock_common_getsockopt,
+	.sendmsg =	inet_sendmsg,
+	.recvmsg =	sock_common_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	inet_sendpage,
+};
+
 static struct net_proto_family inet_family_ops = {
 	.family = PF_INET,
 	.create = inet_create,
@@ -861,7 +886,7 @@
                .type =       SOCK_RAW,
                .protocol =   IPPROTO_IP,	/* wild card */
                .prot =       &raw_prot,
-               .ops =        &inet_dgram_ops,
+               .ops =        &inet_sockraw_ops,
                .capability = CAP_NET_RAW,
                .no_check =   UDP_CSUM_DEFAULT,
                .flags =      INET_PROTOSW_REUSE,
