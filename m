From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [IPSEC] Too many SADs!
Date: Wed, 23 Mar 2005 10:57:25 +0100
Message-ID: <1111571845.3833.25.camel@nienna.balabit>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-K1x4Qy0k3vMShwSfUgYa"
Cc: netdev@oss.sgi.com, sfrost@snowman.net,
        ipsec-tools-devel <ipsec-tools-devel@lists.sourceforge.net>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
In-Reply-To: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-K1x4Qy0k3vMShwSfUgYa
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j2N9xSBa004799


  Hi,

2005-03-22, k keltez=E9ssel 00.52-kor Wolfgang Walter ezt =EDrta:
> We had the same problem. Seems to be a limitation of the pfkey-implemen=
tation=20
> of linux.

  This is not really a limitation of the PFKEY implementation, at least
not a limitation related to some upper limit of the number of entries
(no such limit exists). The problem itself is caused by the too
simplistic SAD/SPD dumping code in the implementation, which does not
care about possibly lost messages. The problem is as follows: when
setkey requests a dump, the kernel responds with a stream of messages.
Each of these contains the dump of an SAD/SPD entry, and contains a
decreasing sequence number. The sequence number of the last message is
zero, this way the receiving user-space application can tell that the
dump is over.

  The problem occurs when there's not enough space in the socket buffer
of the PFKEY socket. In this case the kernel simply drops all messages
after the buffer becomes full, thus losing the precious end-of-dump
marker last message as well. Racoon's setkey obviously cannot cope with
this and is still waiting for the missing messages.

  The problem itself comes from the unreliable nature of PFKEY, so it's
not something which can be solved, but there are more ways to work it
around.=20

  AFAIK early Solaris PFKEY implementations made sure the first and last
message in the dump is delivered. This way the user-space application
has the possibility to detect problems and do something about them.
Another solution is to make dumping an all-or-nothing operation, even at
the cost of the socket buffer growing past its upper limit (this is in
current NetBSD versions, for example). More information about the
problem and its NetBSD workaround can be found here:

  http://mail-index.netbsd.org/tech-net/2004/05/21/0006.html

  As a quick and dirty hack to see if you have the same problem, try
increasing the net.core.rmem_default sysctl value. If you set that to a
larger value than the memory needed for the complete dump you should
have no problems. Of course I wouldn't recommend this as a long-term
"solution".

  Oh, wait, this is where a limitation of ipsec-tools comes into the
picture. For some unknown reason, libipsec (PFKEY interface used by both
setkey and racoon) sets the socket buffer size to 128K for _all_ PFKEY
sockets. So even if you set a much higher default value through sysctl,
setkey dumbly sets the limit to 128K. IMHO this is a bug in ipsec-tools,
it should not impose such limitations. I've attached a quick-and-dirty
patch which removes those ugly setsockopts.

> We switched to iproute2 and openswan which both use the netfilter-inter=
face.=20
> Therefor they can handle thousands of SAD and SPD rules.

  Seems to justify the PFKEY problems I've summarized above.

--=20
 Regards,
  Krisztian Kovacs

--=-K1x4Qy0k3vMShwSfUgYa
Content-Disposition: attachment; filename=ipsec-tools_pfkey_limitation_fix.diff
Content-Type: text/x-patch; name=ipsec-tools_pfkey_limitation_fix.diff; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit

--- ipsec-tools-0_5-branch/src/libipsec/pfkey.c	2004-09-13 16:09:18.000000000 +0200
+++ ipsec-tools-0_5-branch/src/libipsec/pfkey.c.new	2005-03-23 10:55:50.000000000 +0100
@@ -1713,13 +1713,6 @@
 		return -1;
 	}
 
-	/*
-	 * This is a temporary workaround for KAME PR 154.
-	 * Don't really care even if it fails.
-	 */
-	(void)setsockopt(so, SOL_SOCKET, SO_SNDBUF, &bufsiz, sizeof(bufsiz));
-	(void)setsockopt(so, SOL_SOCKET, SO_RCVBUF, &bufsiz, sizeof(bufsiz));
-
 	__ipsec_errcode = EIPSEC_NO_ERROR;
 	return so;
 }

--=-K1x4Qy0k3vMShwSfUgYa--
