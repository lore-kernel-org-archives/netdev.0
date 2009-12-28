From: Milan Dadok <milan@dadok.name>
Subject: [PATCH] 0/1 net: packet: Keep 802.1Q VLAN tag in packet on SOCK_DGRAM socket
Date: Mon, 28 Dec 2009 15:34:23 +0100
Message-ID: <004401ca87ca$da08e500$8e1aaf00$@name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <uaca@i.hate.spam.alumni.uv.es>,
	<johann.baudy@gnu-log.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751783AbZL1Ojx@vger.kernel.org>
Content-Language: cs
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I found next bug in af_socket.c during testing why 
tcpdump -i any -env
don't show correctly outgoing 802.1Q packet 

Vanilla kernel 2.6.31 display something like that
14:45:51.237238 Out 00:1b:21:xx:xx:xx ethertype Unknown (0x0033), length 72:

In function tpacket_rcv (and packet_rcv - I don't patch that for now) there
is comment
/* Special case: outgoing packets have ll header at head */
skb_pull(skb, skb_network_offset(skb))

Normally that is true, but on physical network card with no hw vlan
acceleration ll header contains VLAN tag too, added by upper dev in
vlan_dev.c.
So we must remove only ll header of current physical dev, not bytes added by
upper dev (ie. vlan_dev.c)
With more nested vlan devices it is going to be more complicated.

			hard_header_len   network_offset    must leave from
ll header
vlan1099@vlan1010 26			14                0 = 14 - 14 = 26 -
(26-22) - (22-18) - (18-14)
vlan1010@vlan10   22			18      1x8021Q   4 = 18 - 14 = 22 -
(22-18) - (18-14)
vlan10@eth1       18			22      2x8021Q	8 = 22 - 14 = 18 -
(18-14)
eth1              14			26      3x8021Q	12 = 26 - 14

Next patch don't look nicely and need more work (move is_vlan_dev to another
.h, support another encapsulation, non ETH devices etc.), but it is working
for me.
There may be another solution of this too.

tcpdump -env -i any 'host 192.168.101.11 or (vlan and host 192.168.101.11)'
15:14:47.103377  In 00:1b:21:xx:xx:xx ethertype 802.1Q (0x8100), length 80:
vlan 51, p 0, ethertype IPv4, 77.75.72.3 > 192.168.101.11: ICMP echo reply,
id 512, seq 28192, length 40
15:14:47.103377  In 00:1b:21:xx:xx:xx ethertype IPv4 (0x0800), length 76:
77.75.72.3 > 192.168.101.11: ICMP echo reply, id 512, seq 28192, length 40
15:14:47.103398 Out 00:0a:5e:xx:xx:xx ethertype IPv4 (0x0800), length 76:
77.75.72.3 > 192.168.101.11: ICMP echo reply, id 512, seq 28192, length 40
15:14:47.103406 Out 00:0a:5e:xx:xx:xx ethertype 802.1Q (0x8100), length 80:
vlan 10, p 0, ethertype IPv4, 77.75.72.3 > 192.168.101.11: ICMP echo reply,
id 512, seq 28192, length 40

I tested it on vlan1010@vlan10 interface too.

Milan

PS. to fully support VLAN in tcpdump I made next patches to libpcap, I'm
going to send it to tcpdump maintainer.
(any comments on 'kernel filter don't have access to skb VLAN TCI field'?)

Patch to libpcap

This patch is for tcpdump correclly filter and display VLAN encapsulated
packet.

My testing configuration was
eth0 - hw vlan accelerated network card
eth1 - no hw vlan accelerated network card
many vlan1,vlan51

These command now works correctlly
tcpdump -env -i eth0 not vlan
tcpdump -env -i eth1 not vlan
tcpdump -env -i eth0 vlan 51
tcpdump -env -i eth1 vlan 51
tcpdump -env -i any vlan 51
tcpdump -env -i any

tcpdump -env -i any 'host 192.168.111.11 or (vlan and host 192.168.111.11)'
that works too - it show correctly 1 routed packet on 4 interfaces (in
eth0,in vlan1,out vlan2,out eth1)
(vconfig set_flag 1 1 on all vlans)

Solved bugs

- on any interface 802.1Q packet from hw vlan accelerated card (in,out) was
not displayed correctly
  because SLL header does not have same len as MAC header (!= 2 * ETH_ALEN)

- userland filter was run before sll and 802.1Q packet restoring, but
offsets in filter was counted
  with sll and 802.1Q headers already in packet

- if filter have vlan condition, filter must be in userland, because kernel
filter don't have access to skb VLAN TCI field

- There must be one kernel patch applied to kernel 2.6.32 for correctly
display and filter 802.1q packet on any interface 

diff -urpN pcap-linux.c.orig pcap-linux.c
--- pcap-linux.c.orig   2009-12-26 10:56:30.000000000 +0100
+++ pcap-linux.c        2009-12-28 15:11:38.000000000 +0100
@@ -1933,6 +1933,7 @@ pcap_setfilter_linux_common(pcap_t *hand
                return -1;
 #endif /* SO_ATTACH_FILTER */

+       printf("Using %s filter\n", handle->md.use_bpf?"kernel":"userland");
        return 0;
 }

@@ -3072,23 +3073,6 @@ pcap_read_linux_mmap(pcap_t *handle, int
                        return -1;
                }

-               /* run filter on received packet
-                * If the kernel filtering is enabled we need to run the
-                * filter until all the frames present into the ring
-                * at filter creation time are processed.
-                * In such case md.use_bpf is used as a counter for the
-                * packet we need to filter.
-                * Note: alternatively it could be possible to stop applying
-                * the filter when the ring became empty, but it can
possibly
-                * happen a lot later... */
-               bp = (unsigned char*)h.raw + tp_mac;
-               run_bpf = (!handle->md.use_bpf) ||
-                       ((handle->md.use_bpf>1) && handle->md.use_bpf--);
-               if (run_bpf && handle->fcode.bf_insns &&
-                               (bpf_filter(handle->fcode.bf_insns, bp,
-                                       tp_len, tp_snaplen) == 0))
-                       goto skip;
-
                /*
                 * Do checks based on packet direction.
                 */
@@ -3117,11 +3101,7 @@ pcap_read_linux_mmap(pcap_t *handle, int
                                goto skip;
                }

-               /* get required packet info from ring header */
-               pcaphdr.ts.tv_sec = tp_sec;
-               pcaphdr.ts.tv_usec = tp_usec;
-               pcaphdr.caplen = tp_snaplen;
-               pcaphdr.len = tp_len;
+               bp = (unsigned char*)h.raw + tp_mac;

                /* if required build in place the sll header*/
                if (handle->md.cooked) {
@@ -3163,27 +3143,58 @@ pcap_read_linux_mmap(pcap_t *handle, int
                        hdrp->sll_protocol = sll->sll_protocol;

                        /* update packet len */
-                       pcaphdr.caplen += SLL_HDR_LEN;
-                       pcaphdr.len += SLL_HDR_LEN;
+                       tp_snaplen += SLL_HDR_LEN;
+                       tp_len += SLL_HDR_LEN;
                }

 #ifdef HAVE_TPACKET2
-               if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci
&&
-                   tp_snaplen >= 2 * ETH_ALEN) {
+               /*
+                * Add VLAN TAG if set in TPACKET2
+                */
+               if (handle->md.tp_version == TPACKET_V2 &&
(h.h2->tp_vlan_tci)) {
                        struct vlan_tag *tag;
+                       int ethlen;

                        bp -= VLAN_TAG_LEN;
-                       memmove(bp, bp + VLAN_TAG_LEN, 2 * ETH_ALEN);

-                       tag = (struct vlan_tag *)(bp + 2 * ETH_ALEN);
+                       if (!handle->md.cooked) {
+                               ethlen = 2 * ETH_ALEN;
+                       } else {
+                               ethlen = sizeof(struct sll_header) -
sizeof(sll->sll_protocol);
+                       }
+                       memmove(bp, bp + VLAN_TAG_LEN, ethlen);
+                       tag = (struct vlan_tag *)(bp + ethlen);
+
                        tag->vlan_tpid = htons(ETH_P_8021Q);
                        tag->vlan_tci = htons(h.h2->tp_vlan_tci);

-                       pcaphdr.caplen += VLAN_TAG_LEN;
-                       pcaphdr.len += VLAN_TAG_LEN;
+                       tp_snaplen += VLAN_TAG_LEN;
+                       tp_len += VLAN_TAG_LEN;
                }
 #endif

+               /* run filter on received packet
+                * If the kernel filtering is enabled we need to run the
+                * filter until all the frames present into the ring
+                * at filter creation time are processed.
+                * In such case md.use_bpf is used as a counter for the
+                * packet we need to filter.
+                * Note: alternatively it could be possible to stop applying
+                * the filter when the ring became empty, but it can
possibly
+                * happen a lot later... */
+               run_bpf = (!handle->md.use_bpf) ||
+                       ((handle->md.use_bpf>1) && handle->md.use_bpf--);
+               if (run_bpf && handle->fcode.bf_insns &&
+                               (bpf_filter(handle->fcode.bf_insns, bp,
+                                       tp_len, tp_snaplen) == 0))
+                       goto skip;
+
+               /* get required packet info from ring header */
+               pcaphdr.ts.tv_sec = tp_sec;
+               pcaphdr.ts.tv_usec = tp_usec;
+               pcaphdr.caplen = tp_snaplen;
+               pcaphdr.len = tp_len;
+
                /*
                 * The only way to tell the kernel to cut off the
                 * packet at a snapshot length is with a filter program;
@@ -4270,6 +4281,7 @@ iface_get_arptype(int fd, const char *de
 }

 #ifdef SO_ATTACH_FILTER
+static u_int orig_nl;
 static int
 fix_program(pcap_t *handle, struct sock_fprog *fcode, int is_mmapped)
 {
@@ -4295,6 +4307,13 @@ fix_program(pcap_t *handle, struct sock_
        fcode->len = len;
        fcode->filter = (struct sock_filter *) f;

+       /*
+        * Is filter testing some encapsulated packets - VLAN, MPLS?
+        * put to userland after encapsulated packet is restored from TCI
+        */
+       if (handle->md.tp_version == TPACKET_V2 && orig_nl!=-1U)
+               return 0;
+
        for (i = 0; i < len; ++i) {
                p = &f[i];
                /*
