From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [-next] openvswitch BUILD_BUG_ON failed
Date: Thu, 29 Aug 2013 23:21:09 +0200
Message-ID: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-Next <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On m68k, where the alignment of 32-bit words is 2 bytes:

net/openvswitch/flow.c:1984:2: error: call to
'__compiletime_assert_1984' declared with attribute error:
BUILD_BUG_ON failed: sizeof(struct sw_flow_key) % sizeof(long)

(http://kisskb.ellerman.id.au/kisskb/buildresult/9422860/)

This was introduced by commit 5828cd9a68873df1340b420371c02c47647878fb
Author: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date:   Tue Aug 27 13:02:21 2013 -0700

    openvswitch: optimize flow compare and mask functions

    Make sure the sw_flow_key structure and valid mask boundaries are always
    machine word aligned. Optimize the flow compare and mask operations
    using machine word size operations. This patch improves throughput on
    average by 15% when CPU is the bottleneck of forwarding packets.

    This patch is inspired by ideas and code from a patch submitted by Peter
    Klausler titled "replace memcmp() with specialized comparator".
    However, The original patch only optimizes for architectures
    support unaligned machine word access. This patch optimizes for all
    architectures.

A quick fix to satisfy the build check is to make the padding explicit
(gmail-whitespace-damaged diff):

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index b65f885..15f08d9 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -78,6 +78,7 @@ struct sw_flow_key {
                u32     priority;       /* Packet QoS priority. */
                u32     skb_mark;       /* SKB mark. */
                u16     in_port;        /* Input switch port (or DP_MAX_PORTS).
+               u16     pad;
        } phy;
        struct {
                u8     src[ETH_ALEN];   /* Ethernet source address. */

However, I have some doubts about other alignment "enforcements":

"__aligned(__alignof__(long))" makes the whole struct aligned to the
alignment rule for "long":
   1. This is only 2 bytes on m68k, i.e. != sizeof(long).
   2. This is 4 bytes on many 32-bit platforms, which may be less than the
      default alignment for "__be64" (cfr. some members of struct
      ovs_key_ipv4_tunnel), so this may make those 64-bit members unaligned.
I guess you want (at least) 4 byte alignment on 32-bit, and prefer 8 byte
alignment on 64-bit?
Not specifying any alignment constraint will give you most of that (except
on 64-bit platforms where 64-bit words must be only 4-byte aligned).

There's another build check "BUILD_BUG_ON(sizeof(long) % sizeof(u32))".
Isn't this always true on Linux, as "long" is never smaller than 4 bytes?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
