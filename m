From: kuznet@ms2.inr.ac.ru
Subject: Re: RFC2292(bis) checksum support
Date: Mon, 20 May 2002 01:46:48 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205192146.BAA00826@sex.inr.ac.ru>
References: <20020517015714M.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: yoshfuji@linux-ipv6.ORG (YOSHIFUJI Hideaki)
In-Reply-To: <20020517015714M.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at May 16, 2 09:15:08 pm
List-Id: netdev.vger.kernel.org

Hello!

> According to RFC2292 and its successor RFC2292bis, kernel compute and 
> store checksum for output, and verify the recieved checksum on input
> (and discard it if it is in error) if the socket is for ICMPv6 IPV6_CHECKSUM
> socket option is set to the raw socket.  
> Linux does not support this.

This is supposed to be fixed in recent 2.4.19 and 2.5.


> (1) RFC2292bis denies usage of this interface for ICMPv6 socket,

OK. Yes, we can set default value for such sockets to 2, but I do not see
any good reasons to limit functionality of the API just to follow evident
mistake in the rfc. So, I would apply the last three chunks of the patch
except for these lines:

+                       if (sk->num == IPPROTO_ICMPV6 && val != 2)
+                               return(-EINVAL);


One question only: what did you mean in the following chunk?
Apparently, you forgot to delete marked line.

 			csum = (__u16 *) (buff + opt->offset);
 			*csum = hdr->cksum;
			^^^^^^^^^^^^^^^^^^^
+			if (*csum) {
+				/* in case cksum was not initialized */
+				__u32 sum = hdr->cksum;
+				sum += *csum;
+				*csum = hdr->cksum = (sum + (sum>>16));
+			} else {
+				*csum = hdr->cksum;
+			}

Do I guess correctly that you wanted to compensate for occasionally
ununitialized checksum bits in data supplied by user?

Alexey
