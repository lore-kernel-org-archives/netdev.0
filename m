From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IPV6_RECVPKTINFO fix
Date: Sun, 21 Oct 2012 13:05:24 +0200
Message-ID: <CAKgNAkjp0OBZ5P3UMGxytk-WtzGxrM_i2ktZJXR8CqL-_PasDQ@mail.gmail.com>
References: <20121009130632.GA16787@xs.powerdns.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Yang Hongyang <yanghy-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: bert hubert <bert.hubert-dxZxOz86jR8sYtaaK7K+xw@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121009130632.GA16787-UEKwcDob1UlZy7985ye5QA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Bert,

On Tue, Oct 9, 2012 at 3:06 PM, bert hubert <bert.hubert-dxZxOz86jR8sYtaaK7K+xw@public.gmane.org> wrote:
> Hi everybody,
>
> Recently PowerDNS needed to support the getting of the original destination
> address of packets received on ::. Following the advice in ipv6(7) generated
> an error on setsockopt().
>
> Some googling confirmed that setsockopt() with IPV6_PKTINFO indeed does not
> work, but we found that IPV6_RECVPKTINFO did.
>
> Our experiences are detailed in
> http://bert-hubert.blogspot.nl/2012/10/on-binding-datagram-udp-sockets-to-any.html
>
> Please find attached a quite naive patch to ipv6.7 that at least fixes 'my'
> problem, but does not document if IPV6_PKTINFO ever worked as a flag. It
> does document that IPV6_RECVPKTINFO is available since 2.6.13.
>
> Please let me know if this patch is acceptable, or if you want me to dig
> deeper into the IPV6_PKTINFO situation.

So, the kernel commit 333fad5364d6b457c8d837f7d05802d2aaf8a961 (Sep
2005) does this:

=====
-#define IPV6_PKTINFO           2
-#define IPV6_HOPOPTS           3
-#define IPV6_DSTOPTS           4
-#define IPV6_RTHDR             5
-#define IPV6_PKTOPTIONS                6
+#define IPV6_2292PKTINFO       2
+#define IPV6_2292HOPOPTS       3
+#define IPV6_2292DSTOPTS       4
+#define IPV6_2292RTHDR         5
+#define IPV6_2292PKTOPTIONS    6
...
+/* RFC3542 advanced socket options (50-67) */
+#define IPV6_RECVPKTINFO       50
+#define IPV6_PKTINFO           51
...
+#define IPV6_RECVHOPOPTS       56
+#define IPV6_HOPOPTS           57

 #define IPV6_CHECKSUM          7
-#define IPV6_HOPLIMIT          8
+#define IPV6_2292HOPLIMIT      8
...
+#define IPV6_RTHDRDSTOPTS      59
+#define IPV6_RECVRTHDR         60
+#define IPV6_RTHDR             61
+#define IPV6_RECVDSTOPTS       62
+#define IPV6_DSTOPTS           63
+#define IPV6_RECVHOPLIMIT      64
+#define IPV6_HOPLIMIT          65
=====

Looking more closely (i.e., beyond just the above), the summary is
that IPV6_PKTINFO disappeared from the getsockopt/setsockopt API, and
IPV6_2292PKTINFO took its place. Meanwhile, IPV6_RECVPKTINFO was
added.

Then kernel commit b24a2516d10751d7ed5afb58420df25370c9dffb (Dec 2008)
added IPV6_PKTINFO back to the getsockopt/getsockopt API, but with
what looks to be a rather different meaning (it takes a 'struct
in6_pktinfo' as the third arg).

This seems consistent (if confusing) with the RFCs:
http://www.ietf.org/rfc/rfc2292.txt
http://www.ietf.org/rfc/rfc3542.txt (obsoletes 2292)

Both of those RFCs define an IPV6_PKTINO sockopt, but the former takes
an int arg, and the latter takes the 'struct in6_pktinfo'.

So, my summary of your patch is that it's correct. But I think that
IPV6_RECVPKTINFO is present since 2.6.14, not 2.6.13, and I tweaked
your patch (see below).

But it'd be great if the netdev folk in general could send in
documentation patches, or at least CC linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, for
future API changes.

Cheers,

Michael

--- a/man7/ipv6.7
+++ b/man7/ipv6.7
@@ -141,7 +141,7 @@ structure.
 .\" FIXME IPV6_CHECKSUM is not documented, and probably should be
 .\" FIXME IPV6_JOIN_ANYCAST is not documented, and probably should be
 .\" FIXME IPV6_LEAVE_ANYCAST is not documented, and probably should be
-.\" FIXME IPV6_RECVPKTINFO is not documented, and probably should be
+.\" FIXME IPV6_PKTINFO is not documented, and probably should be
 .\" FIXME IPV6_2292PKTINFO is not documented, and probably should be
 .\" FIXME there are probably many other IPV6_* socket options that
 .\" should be documented
@@ -183,10 +183,11 @@ in an integer.
 Control whether the socket sees multicast packets that it has send itself.
 Argument is a pointer to boolean.
 .TP
-.B IPV6_PKTINFO
+.BR IPV6_RECVPKTINFO " (since Linux 2.6.14)"
 Set delivery of the
 .B IPV6_PKTINFO
 control message on incoming datagrams.
+Such control messages contain a struct in6_pktinfo, as per RFC 3542.
 Only allowed for
 .B SOCK_DGRAM
 or

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
