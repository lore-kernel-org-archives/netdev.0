From: xiaoming gao <gxm.linux.kernel@gmail.com>
Subject: [PATCH] net bridge: add null pointer check, fix panic
Date: Thu, 20 Jun 2013 11:08:11 +0800
Message-ID: <51C2721B.9050603@gmail.com>
References: <51C2710D.2060405@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030706040605000202080302"
To: stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C2710D.2060405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030706040605000202080302
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit

From: newtongao <newtongao@tencent.com>
Date: Wed, 19 Jun 2013 14:58:33 +0800
Subject: [PATCH] net bridge: add null pointer check,fix panic

in kernel 3.0, br_port_get_rcu() may return NULL when network interface be deleting from bridge,
but in function br_handle_frame and br_handle_local_finish, the pointer didn't be checked before using,
so all br_port_get_rcu callers must do null check,or there occurs the null pointer panic.

kernel 3.4 also has this bug,i have verified.
mainline kernel still did not  check br_port_get_rcu()'s NULL pointer, but i have not tested it yet.

method to reproduce null pointer panic:
1. in function del_nbp,amplify the gap between "dev->priv_flags &= ~IFF_BRIDGE_PORT;" and "netdev_rx_handler_unregister(dev);" , such as add new line "while(1);".
2. create net bridge testbr and bind some network interface(e.g. testif) on it.
3. send packets to testif frequetly,such as ping testif.
4. brctl delif testbr testif.

backtrace:
[1002130.426411] FS:  00007f2235153700(0000) GS:ffff88007b020000(0000) knlGS:0000000000000000
[1002130.524656] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[1002130.594931] CR2: 0000000000000021 CR3: 0000000001dc7000 CR4: 0000000000002660
[1002130.681798] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[1002130.768654] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[1002130.855525] Process ksoftirqd/1 (pid: 9, threadinfo ffff880062642000, task ffff880062640800)
[1002130.957868] Stack:
[1002130.983758]  0000000080000000 ffff88007bc06a40 ffff88005e3c6c80 ffffffff81901d10
[1002131.073887]  ffff88005efc2000 0000000000000001 ffff880062643bf0 ffffffff818497d9
[1002131.163945]  ffff88006147e090 0000000000000020 ffff88007bc06a40 ffff88005e3c6c80
[1002131.254023] Call Trace:
[1002131.285086]  [<ffffffff81901d10>] ? br_handle_frame_finish+0x2b0/0x2b0
[1002131.364677]  [<ffffffff818497d9>] __netif_receive_skb+0x109/0x4a0
[1002131.439081]  [<ffffffff81849b12>] __netif_receive_skb+0x442/0x4a0
[1002131.513493]  [<ffffffff810e3a6e>] ? __kmalloc_node+0x3e/0x50
[1002131.582744]  [<ffffffff8184b7d8>] netif_receive_skb+0x78/0x80
[1002131.653053]  [<ffffffff8184b928>] napi_skb_finish+0x48/0x60
[1002131.721269]  [<ffffffff8184bf1d>] napi_gro_receive+0xfd/0x130
[1002131.791551]  [<ffffffff8192b2f6>] vlan_gro_receive+0x16/0x20
[1002131.860796]  [<ffffffff816a41d1>] igb_poll+0x6f1/0xdc0
[1002131.923871]  [<ffffffff8196c0d5>] ? __schedule+0x2e5/0x810
[1002131.991071]  [<ffffffff8196e38b>] ? _raw_spin_lock_irq+0xb/0x30
[1002132.063421]  [<ffffffff8184c0c1>] net_rx_action+0xa1/0x1d0
[1002132.130619]  [<ffffffff81057449>] __do_softirq+0x99/0x130
[1002132.196803]  [<ffffffff8105759a>] run_ksoftirqd+0xba/0x170
[1002132.264000]  [<ffffffff810574e0>] ? __do_softirq+0x130/0x130
[1002132.333258]  [<ffffffff8106d306>] kthread+0x96/0xa0
[1002132.393224]  [<ffffffff8196ffe4>] kernel_thread_helper+0x4/0x10
[1002132.465580]  [<ffffffff8196f0f6>] ? int_ret_from_sys_call+0x7/0x1b
[1002132.541016]  [<ffffffff8196e8a1>] ? retint_restore_args+0x5/0x6
[1002132.613368]  [<ffffffff8196ffe0>] ? gs_change+0x13/0x13
[1002132.677466] Code: 02 f6 81 a5 01 00 00 40 48 8b 81 e0 02 00 00 89 d6 4c 0f 45 f0 48 8b 05 50 76 20 00 66 33 70 04 66 f7 c6 ff f0 0f 84 d0 00 00 00
[1002132.835500]  0f b6 46 21 3c 02 74 50 3c 03 0f 85 60 ff ff ff 48 8b 05 e1
[1002132.920864] RIP  [<ffffffff81901e17>] br_handle_frame+0x107/0x260
[1002132.995296]  RSP <ffff880062643b50>
[1002133.038735] CR2: 0000000000000021

Signed-off-by: Xiaoming Gao <newtongao@tencent.com>
---
 net/bridge/br_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f06ee39..c8b365f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -122,7 +122,8 @@ static int br_handle_local_finish(struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 
-	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+	if (p)
+		br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
 	return 0;	 /* process further */
 }
 
@@ -160,6 +161,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		return RX_HANDLER_CONSUMED;
 
 	p = br_port_get_rcu(skb->dev);
+	if (!p)
+		goto drop;
 
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
-- 
1.7.1




--------------030706040605000202080302
Content-Type: text/plain; charset=gb18030;
 name="0001-net-bridge-add-null-pointer-check.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-net-bridge-add-null-pointer-check.patch"

RnJvbSAyYjM5YzRjY2Q4MTI3MjM4OTExMTcxODRiMjk3ZjY4ODZkY2ZkOTc2IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBuZXd0b25nYW8gPG5ld3Rvbmdhb0B0ZW5jZW50LmNv
bT4KRGF0ZTogV2VkLCAxOSBKdW4gMjAxMyAxNDo1ODozMyArMDgwMApTdWJqZWN0OiBbUEFU
Q0hdIG5ldCBicmlkZ2U6IGFkZCBudWxsIHBvaW50ZXIgY2hlY2ssZml4IHBhbmljCgppbiBr
ZXJuZWwgMy4wLCBicl9wb3J0X2dldF9yY3UoKSBtYXkgcmV0dXJuIE5VTEwgd2hlbiBuZXR3
b3JrIGludGVyZmFjZSBiZSBkZWxldGluZyBmcm9tIGJyaWRnZSwKYnV0IGluIGZ1bmN0aW9u
IGJyX2hhbmRsZV9mcmFtZSBhbmQgYnJfaGFuZGxlX2xvY2FsX2ZpbmlzaCwgdGhlIHBvaW50
ZXIgZGlkbid0IGJlIGNoZWNrZWQgYmVmb3JlIHVzaW5nLApzbyBhbGwgYnJfcG9ydF9nZXRf
cmN1IGNhbGxlcnMgbXVzdCBkbyBudWxsIGNoZWNrLG9yIHRoZXJlIG9jY3VycyB0aGUgbnVs
bCBwb2ludGVyIHBhbmljLgoKa2VybmVsIDMuNCBhbHNvIGhhcyB0aGlzIGJ1ZyxpIGhhdmUg
dmVyaWZpZWQuCm1haW5saW5lIGtlcm5lbCBzdGlsbCBkaWQgbm90ICBjaGVjayBicl9wb3J0
X2dldF9yY3UoKSdzIE5VTEwgcG9pbnRlciwgYnV0IGkgaGF2ZSBub3QgdGVzdGVkIGl0IHll
dC4KCm1ldGhvZCB0byByZXByb2R1Y2UgbnVsbCBwb2ludGVyIHBhbmljOgoxLiBpbiBmdW5j
dGlvbiBkZWxfbmJwLGFtcGxpZnkgdGhlIGdhcCBiZXR3ZWVuICJkZXYtPnByaXZfZmxhZ3Mg
Jj0gfklGRl9CUklER0VfUE9SVDsiIGFuZCAibmV0ZGV2X3J4X2hhbmRsZXJfdW5yZWdpc3Rl
cihkZXYpOyIgLCBzdWNoIGFzIGFkZCBuZXcgbGluZSAid2hpbGUoMSk7Ii4KMi4gY3JlYXRl
IG5ldCBicmlkZ2UgdGVzdGJyIGFuZCBiaW5kIHNvbWUgbmV0d29yayBpbnRlcmZhY2UoZS5n
LiB0ZXN0aWYpIG9uIGl0LgozLiBzZW5kIHBhY2tldHMgdG8gdGVzdGlmIGZyZXF1ZXRseSxz
dWNoIGFzIHBpbmcgdGVzdGlmLgo0LiBicmN0bCBkZWxpZiB0ZXN0YnIgdGVzdGlmLgoKYmFj
a3RyYWNlOgpbMTAwMjEzMC40MjY0MTFdIEZTOiAgMDAwMDdmMjIzNTE1MzcwMCgwMDAwKSBH
UzpmZmZmODgwMDdiMDIwMDAwKDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAKWzEwMDIx
MzAuNTI0NjU2XSBDUzogIGUwMzMgRFM6IDAwMDAgRVM6IDAwMDAgQ1IwOiAwMDAwMDAwMDgw
MDUwMDNiClsxMDAyMTMwLjU5NDkzMV0gQ1IyOiAwMDAwMDAwMDAwMDAwMDIxIENSMzogMDAw
MDAwMDAwMWRjNzAwMCBDUjQ6IDAwMDAwMDAwMDAwMDI2NjAKWzEwMDIxMzAuNjgxNzk4XSBE
UjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIxOiAwMDAwMDAwMDAwMDAwMDAwIERSMjogMDAwMDAw
MDAwMDAwMDAwMApbMTAwMjEzMC43Njg2NTRdIERSMzogMDAwMDAwMDAwMDAwMDAwMCBEUjY6
IDAwMDAwMDAwZmZmZjBmZjAgRFI3OiAwMDAwMDAwMDAwMDAwNDAwClsxMDAyMTMwLjg1NTUy
NV0gUHJvY2VzcyBrc29mdGlycWQvMSAocGlkOiA5LCB0aHJlYWRpbmZvIGZmZmY4ODAwNjI2
NDIwMDAsIHRhc2sgZmZmZjg4MDA2MjY0MDgwMCkKWzEwMDIxMzAuOTU3ODY4XSBTdGFjazoK
WzEwMDIxMzAuOTgzNzU4XSAgMDAwMDAwMDA4MDAwMDAwMCBmZmZmODgwMDdiYzA2YTQwIGZm
ZmY4ODAwNWUzYzZjODAgZmZmZmZmZmY4MTkwMWQxMApbMTAwMjEzMS4wNzM4ODddICBmZmZm
ODgwMDVlZmMyMDAwIDAwMDAwMDAwMDAwMDAwMDEgZmZmZjg4MDA2MjY0M2JmMCBmZmZmZmZm
ZjgxODQ5N2Q5ClsxMDAyMTMxLjE2Mzk0NV0gIGZmZmY4ODAwNjE0N2UwOTAgMDAwMDAwMDAw
MDAwMDAyMCBmZmZmODgwMDdiYzA2YTQwIGZmZmY4ODAwNWUzYzZjODAKWzEwMDIxMzEuMjU0
MDIzXSBDYWxsIFRyYWNlOgpbMTAwMjEzMS4yODUwODZdICBbPGZmZmZmZmZmODE5MDFkMTA+
XSA/IGJyX2hhbmRsZV9mcmFtZV9maW5pc2grMHgyYjAvMHgyYjAKWzEwMDIxMzEuMzY0Njc3
XSAgWzxmZmZmZmZmZjgxODQ5N2Q5Pl0gX19uZXRpZl9yZWNlaXZlX3NrYisweDEwOS8weDRh
MApbMTAwMjEzMS40MzkwODFdICBbPGZmZmZmZmZmODE4NDliMTI+XSBfX25ldGlmX3JlY2Vp
dmVfc2tiKzB4NDQyLzB4NGEwClsxMDAyMTMxLjUxMzQ5M10gIFs8ZmZmZmZmZmY4MTBlM2E2
ZT5dID8gX19rbWFsbG9jX25vZGUrMHgzZS8weDUwClsxMDAyMTMxLjU4Mjc0NF0gIFs8ZmZm
ZmZmZmY4MTg0YjdkOD5dIG5ldGlmX3JlY2VpdmVfc2tiKzB4NzgvMHg4MApbMTAwMjEzMS42
NTMwNTNdICBbPGZmZmZmZmZmODE4NGI5Mjg+XSBuYXBpX3NrYl9maW5pc2grMHg0OC8weDYw
ClsxMDAyMTMxLjcyMTI2OV0gIFs8ZmZmZmZmZmY4MTg0YmYxZD5dIG5hcGlfZ3JvX3JlY2Vp
dmUrMHhmZC8weDEzMApbMTAwMjEzMS43OTE1NTFdICBbPGZmZmZmZmZmODE5MmIyZjY+XSB2
bGFuX2dyb19yZWNlaXZlKzB4MTYvMHgyMApbMTAwMjEzMS44NjA3OTZdICBbPGZmZmZmZmZm
ODE2YTQxZDE+XSBpZ2JfcG9sbCsweDZmMS8weGRjMApbMTAwMjEzMS45MjM4NzFdICBbPGZm
ZmZmZmZmODE5NmMwZDU+XSA/IF9fc2NoZWR1bGUrMHgyZTUvMHg4MTAKWzEwMDIxMzEuOTkx
MDcxXSAgWzxmZmZmZmZmZjgxOTZlMzhiPl0gPyBfcmF3X3NwaW5fbG9ja19pcnErMHhiLzB4
MzAKWzEwMDIxMzIuMDYzNDIxXSAgWzxmZmZmZmZmZjgxODRjMGMxPl0gbmV0X3J4X2FjdGlv
bisweGExLzB4MWQwClsxMDAyMTMyLjEzMDYxOV0gIFs8ZmZmZmZmZmY4MTA1NzQ0OT5dIF9f
ZG9fc29mdGlycSsweDk5LzB4MTMwClsxMDAyMTMyLjE5NjgwM10gIFs8ZmZmZmZmZmY4MTA1
NzU5YT5dIHJ1bl9rc29mdGlycWQrMHhiYS8weDE3MApbMTAwMjEzMi4yNjQwMDBdICBbPGZm
ZmZmZmZmODEwNTc0ZTA+XSA/IF9fZG9fc29mdGlycSsweDEzMC8weDEzMApbMTAwMjEzMi4z
MzMyNThdICBbPGZmZmZmZmZmODEwNmQzMDY+XSBrdGhyZWFkKzB4OTYvMHhhMApbMTAwMjEz
Mi4zOTMyMjRdICBbPGZmZmZmZmZmODE5NmZmZTQ+XSBrZXJuZWxfdGhyZWFkX2hlbHBlcisw
eDQvMHgxMApbMTAwMjEzMi40NjU1ODBdICBbPGZmZmZmZmZmODE5NmYwZjY+XSA/IGludF9y
ZXRfZnJvbV9zeXNfY2FsbCsweDcvMHgxYgpbMTAwMjEzMi41NDEwMTZdICBbPGZmZmZmZmZm
ODE5NmU4YTE+XSA/IHJldGludF9yZXN0b3JlX2FyZ3MrMHg1LzB4NgpbMTAwMjEzMi42MTMz
NjhdICBbPGZmZmZmZmZmODE5NmZmZTA+XSA/IGdzX2NoYW5nZSsweDEzLzB4MTMKWzEwMDIx
MzIuNjc3NDY2XSBDb2RlOiAwMiBmNiA4MSBhNSAwMSAwMCAwMCA0MCA0OCA4YiA4MSBlMCAw
MiAwMCAwMCA4OSBkNiA0YyAwZiA0NSBmMCA0OCA4YiAwNSA1MCA3NiAyMCAwMCA2NiAzMyA3
MCAwNCA2NiBmNyBjNiBmZiBmMCAwZiA4NCBkMCAwMCAwMCAwMApbMTAwMjEzMi44MzU1MDBd
ICAwZiBiNiA0NiAyMSAzYyAwMiA3NCA1MCAzYyAwMyAwZiA4NSA2MCBmZiBmZiBmZiA0OCA4
YiAwNSBlMQpbMTAwMjEzMi45MjA4NjRdIFJJUCAgWzxmZmZmZmZmZjgxOTAxZTE3Pl0gYnJf
aGFuZGxlX2ZyYW1lKzB4MTA3LzB4MjYwClsxMDAyMTMyLjk5NTI5Nl0gIFJTUCA8ZmZmZjg4
MDA2MjY0M2I1MD4KWzEwMDIxMzMuMDM4NzM1XSBDUjI6IDAwMDAwMDAwMDAwMDAwMjEKClNp
Z25lZC1vZmYtYnk6IFhpYW9taW5nIEdhbyA8bmV3dG9uZ2FvQHRlbmNlbnQuY29tPgotLS0K
IG5ldC9icmlkZ2UvYnJfaW5wdXQuYyB8ICAgIDUgKysrKy0KIDEgZmlsZXMgY2hhbmdlZCwg
NCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL25ldC9icmlk
Z2UvYnJfaW5wdXQuYyBiL25ldC9icmlkZ2UvYnJfaW5wdXQuYwppbmRleCBmMDZlZTM5Li5j
OGIzNjVmIDEwMDY0NAotLS0gYS9uZXQvYnJpZGdlL2JyX2lucHV0LmMKKysrIGIvbmV0L2Jy
aWRnZS9icl9pbnB1dC5jCkBAIC0xMjIsNyArMTIyLDggQEAgc3RhdGljIGludCBicl9oYW5k
bGVfbG9jYWxfZmluaXNoKHN0cnVjdCBza19idWZmICpza2IpCiB7CiAJc3RydWN0IG5ldF9i
cmlkZ2VfcG9ydCAqcCA9IGJyX3BvcnRfZ2V0X3JjdShza2ItPmRldik7CiAKLQlicl9mZGJf
dXBkYXRlKHAtPmJyLCBwLCBldGhfaGRyKHNrYiktPmhfc291cmNlKTsKKwlpZiAocCkKKwkJ
YnJfZmRiX3VwZGF0ZShwLT5iciwgcCwgZXRoX2hkcihza2IpLT5oX3NvdXJjZSk7CiAJcmV0
dXJuIDA7CSAvKiBwcm9jZXNzIGZ1cnRoZXIgKi8KIH0KIApAQCAtMTYwLDYgKzE2MSw4IEBA
IHJ4X2hhbmRsZXJfcmVzdWx0X3QgYnJfaGFuZGxlX2ZyYW1lKHN0cnVjdCBza19idWZmICoq
cHNrYikKIAkJcmV0dXJuIFJYX0hBTkRMRVJfQ09OU1VNRUQ7CiAKIAlwID0gYnJfcG9ydF9n
ZXRfcmN1KHNrYi0+ZGV2KTsKKwlpZiAoIXApCisJCWdvdG8gZHJvcDsKIAogCWlmICh1bmxp
a2VseShpc19saW5rX2xvY2FsKGRlc3QpKSkgewogCQkvKiBQYXVzZSBmcmFtZXMgc2hvdWxk
bid0IGJlIHBhc3NlZCB1cCBieSBkcml2ZXIgYW55d2F5ICovCi0tIAoxLjcuMQoK
--------------030706040605000202080302--
