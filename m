From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [PATCH] Allow setting dev->weight using ip(8)
Date: Tue, 31 Aug 2004 11:58:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f04083102586e322b1a@mail.gmail.com>
References: <5cac192f040830035669628d1@mail.gmail.com>
	<1093868860.1075.573.camel@jzny.localdomain>
	<1093869740.1076.587.camel@jzny.localdomain>
	<5cac192f0408300735f05aa2d@mail.gmail.com> <20040830165851.64cf8822.davem@davemloft.net>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040830165851.64cf8822.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Please make a patch against Linus's current tree.
> I put the rest of your rtnetlink device interface
> changes in, and your patches here duplicate all of
> that.

See below.
 
> I agree also with Jamel wrt. ioctl(), let's not go
> there if possible. :-)

Ok. 

I did also go the ioctl() way because that's what iproute2-2.6.8 uses.

[Dave: sorry for the sending you this twice]

--
Eric

===== include/linux/rtnetlink.h 1.41 vs edited =====
--- 1.41/include/linux/rtnetlink.h      Wed Aug 25 02:20:27 2004
+++ edited/include/linux/rtnetlink.h    Tue Aug 31 11:22:55 2004
@@ -565,6 +565,8 @@
 #define IFLA_TXQLEN IFLA_TXQLEN
        IFLA_MAP,
 #define IFLA_MAP IFLA_MAP
+       IFLA_WEIGHT,
+#define IFLA_WEIGHT IFLA_WEIGHT
        __IFLA_MAX
 };

===== net/core/rtnetlink.c 1.23 vs edited =====
--- 1.23/net/core/rtnetlink.c   Wed Aug 25 02:20:27 2004
+++ edited/net/core/rtnetlink.c Tue Aug 31 11:27:15 2004
@@ -177,6 +177,11 @@
        }

        if (1) {
+               u32 weight = dev->weight;
+               RTA_PUT(skb, IFLA_WEIGHT, sizeof(weight), &weight);
+       }
+
+       if (1) {
                struct ifmap map = {
                        .mem_start   = dev->mem_start,
                        .mem_end     = dev->mem_end,
@@ -331,6 +336,13 @@
                        goto out;

                dev->tx_queue_len = *((u32 *) RTA_DATA(ida[IFLA_TXQLEN - 1]));
+       }
+
+       if (ida[IFLA_WEIGHT - 1]) {
+               if (ida[IFLA_WEIGHT - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
+                       goto out;
+
+               dev->weight = *((u32 *) RTA_DATA(ida[IFLA_WEIGHT - 1]));
        }

        err = 0;
