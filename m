From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] ipv6 possible opt panic in ip6_append_data()
Date: Wed, 24 Mar 2004 11:20:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403241114130.16922-100000@DYN318430BLD.beaverton.ibm.com>
References: <20040310144758.5e0b4c7c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krishna Kumar <krkumar@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040310144758.5e0b4c7c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[Old subject: Re: [PATCH AND RFC_PATCH] 1. Leak corking option in ipv4 2.
ipv6 opt panic]

Hi Dave,

Following patch implements what you suggested.

Thanks,

- KK

diff -ruN linux-2.6.5-rc2-bk4/net/ipv6/ip6_output.c linux-2.6.5-rc2-bk4.new/net/ipv6/ip6_output.c
--- linux-2.6.5-rc2-bk4/net/ipv6/ip6_output.c	2004-03-24 11:13:23.000000000 -0800
+++ linux-2.6.5-rc2-bk4.new/net/ipv6/ip6_output.c	2004-03-24 11:13:07.000000000 -0800
@@ -821,6 +821,9 @@
 						       sk->sk_allocation);
 				if (unlikely(np->cork.opt == NULL))
 					return -ENOBUFS;
+			} else if (np->cork.opt->tot_len < opt->tot_len) {
+				printk(KERN_DEBUG "ip6_append_data: invalid option length\n");
+				return -EINVAL;
 			}
 			memcpy(np->cork.opt, opt, opt->tot_len);
 			inet->cork.flags |= IPCORK_OPT;


> > I am not sure about this possible bug which is the RFC part of the
> > subject. In IPv6 ip6_append_data(), if it is possible to add extra
> > ipv6
> > options during multiple calls to append_data(), then the check for
> > cork.opt could end up panicing the system because it is allocated
> > for a smaller size of options. If this is a problem, then ipv4 might
> > have
> > a similar issue too. Note: Patch2 has a question embedded in it, I can
> > send a better patch if you think the idea is right.
>
> This is possible, but an APP trying to do this is buggy as I cannot
> see any sane semantics for this.
>
> I would rather we -EINVAL on such socket option changes if cork.opt is
> non-NULL.  Could you whip up a patch for that?  Thanks.
