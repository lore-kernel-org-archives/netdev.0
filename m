From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: how to suppress link local addresses
Date: Wed, 27 Apr 2005 23:22:46 -0400
Message-ID: <1114658566.4833.9.camel@book.ducksong.com>
References: <1114626832.12304.97.camel@mcmanus.datapower.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
In-Reply-To: <1114626832.12304.97.camel@mcmanus.datapower.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-27 at 14:33 -0400, patrick mcmanus wrote:

> I've got a 2.6.12-rc2 kernel with IPv6 compiled in monolithically.
> using it on several different boxes and would like them all to run the
> same kernel. Most of the boxes have IPv6 connectivity and are working
> fine.. however one of them is on an IPv4 only net.
> 
> When I bring up an IPv4 interface on that box it also gets an automagic
> ipv6 link-local address as a bonus. I would like to prevent that from
> happening if possible.. I had thought that the conf/*/autoconf sysctl
> should do that for me, but I couldn't get it to work (see my
> illustration below). I'm not certain if that's a bug or I just don't
> understand what that is supposed to do.

It turns out other folks have been here before (isn't that always the
way?):
http://marc.theaimsgroup.com/?l=linux-kernel&m=108725654111368&w=2
http://www.uwsg.iu.edu/hypermail/linux/net/0406.1/0065.html

The conventional wisdom then seemed to be "don't load IPv6" or "fix the
userspace app". That strikes me as kind of unsatisfying, it feels like
this should be the sort of thing that is doable by runtime config. But
who am I to argue? I was just fooled by some bad documentation floating
around out there in an (old?) IPv6 on Linux faq on the what the autoconf
sysctl was supposed to do - the state of external documentation
certainly isn't a kernel issue.

For the sake of future googlers I'll include the primitive patch I am
now using locally.

Index: net/ipv6/addrconf.c
===================================================================
--- 3608de2fc88b062070a9d197eda9cac1fb9635d3/net/ipv6/addrconf.c  (mode:100644 sha1:7196ac2f2d1688d410e2f51973f90c0118549c63)
+++ uncommitted/net/ipv6/addrconf.c  (mode:100664)
@@ -1855,6 +1855,9 @@
                printk(KERN_DEBUG "init loopback: add_dev failed\n");
                return;
        }
+
+       if (idev->cnf.autoconf == 0)
+         return;

        ifp = ipv6_add_addr(idev, &in6addr_loopback, 128, IFA_HOST, IFA_F_PERMANENT);
        if (!IS_ERR(ifp)) {
@@ -1894,9 +1897,10 @@
        }

        idev = addrconf_add_dev(dev);
-       if (idev == NULL)
+       if ((idev == NULL) || (idev->cnf.autoconf == 0))
                return;

+
        memset(&addr, 0, sizeof(struct in6_addr));
        addr.s6_addr32[0] = htonl(0xFE800000);
