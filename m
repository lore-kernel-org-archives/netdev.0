From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH v16 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Mon, 11 Jul 2016 14:54:59 +0000
Message-ID: <CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0CO2PR03MB2182namp_"
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	Dave Scott <dave.scott@docker.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0CO2PR03MB2182namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

FYI: you can also get the patch by (commit 5dde7975):
https://github.com/dcui/linux/tree/decui/hv_sock/net-next/20160711_v16

The delta changes between v15 and v16 are in the attached patch
delta_v15_vs_v16.patch.

------------------------------------------

Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
mechanism between the host and the guest. It's somewhat like TCP over
VMBus, but the transportation layer (VMBus) is much simpler than IP.

With Hyper-V Sockets, applications between the host and the guest can talk
to each other directly by the traditional BSD-style socket APIs.

Hyper-V Sockets is only available on new Windows hosts, like Windows Server
2016. More info is in this article "Make your own integration services":
https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/develop/m=
ake_mgmt_service

The patch implements the necessary support in the guest side by
introducing a new socket address family AF_HYPERV.

Note: the VMBus driver side's supporting patches have been in the mainline
tree.

I know the kernel has already had a VM Sockets driver (AF_VSOCK) based
on VMware VMCI (net/vmw_vsock/, drivers/misc/vmw_vmci), and KVM is
proposing AF_VSOCK of virtio version:
http://marc.info/?l=3Dlinux-netdev&m=3D145952064004765&w=3D2

However, though Hyper-V Sockets may seem conceptually similar to
AF_VOSCK, there are differences in the transportation layer, and IMO these
make the direct code reusing impractical:

1. In AF_VSOCK, the endpoint type is: <u32 ContextID, u32 Port>, but in
AF_HYPERV, the endpoint type is: <GUID VM_ID, GUID ServiceID>. Here GUID
is 128-bit.

2. AF_VSOCK supports SOCK_DGRAM, while AF_HYPERV doesn't.

3. AF_VSOCK supports some special sock opts, like SO_VM_SOCKETS_BUFFER_SIZE=
,
SO_VM_SOCKETS_BUFFER_MIN/MAX_SIZE and SO_VM_SOCKETS_CONNECT_TIMEOUT.
These are meaningless to AF_HYPERV.

4. Some AF_VSOCK's VMCI transportation ops are meanless to AF_HYPERV/VMBus,
like .notify_recv_init
.notify_recv_pre_block
.notify_recv_pre_dequeue
.notify_recv_post_dequeue
.notify_send_init
.notify_send_pre_block
.notify_send_pre_enqueue
.notify_send_post_enqueue
etc.

So I think we'd better introduce a new address family: AF_HYPERV.

Please review the patch.

Looking forward to your comments, especially comments from David. :-)

Changes since v1:
- updated "[PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature"
- added __init and __exit for the module init/exit functions
- net/hv_sock/Kconfig: "default m" -> "default m if HYPERV"
- MODULE_LICENSE: "Dual MIT/GPL" -> "Dual BSD/GPL"

Changes since v2:
- fixed various coding issue pointed out by David Miller
- fixed indentation issues
- removed pr_debug in net/hv_sock/af_hvsock.c
- used reverse-Chrismas-tree style for local variables.
- EXPORT_SYMBOL -> EXPORT_SYMBOL_GPL

Changes since v3:
- fixed a few coding issue pointed by Vitaly Kuznetsov and Dan Carpenter
- fixed the ret value in vmbus_recvpacket_hvsock on error
- fixed the style of multi-line comment: vmbus_get_hvsock_rw_status()

Changes since v4 (https://lkml.org/lkml/2015/7/28/404):
- addressed all the comments about V4.
- treat the hvsock offers/channels as special VMBus devices
- add a mechanism to pass hvsock events to the hvsock driver
- fixed some corner cases with proper locking when a connection is closed
- rebased to the latest Greg's tree

Changes since v5 (https://lkml.org/lkml/2015/12/24/103):
- addressed the coding style issues (Vitaly Kuznetsov & David Miller, thank=
s!)
- used a better coding for the per-channel rescind callback (Thank Vitaly!)
- avoided the introduction of new VMBUS driver APIs vmbus_sendpacket_hvsock=
()
and vmbus_recvpacket_hvsock() and used vmbus_sendpacket()/vmbus_recvpacket(=
)
in the higher level (i.e., the vmsock driver). Thank Vitaly!

Changes since v6 (http://lkml.iu.edu/hypermail/linux/kernel/1601.3/01813.ht=
ml)
- only a few minor changes of coding style and comments

Changes since v7
- a few minor changes of coding style: thanks, Joe Perches!
- added some lines of comments about GUID/UUID before the struct sockaddr_h=
v.

Changes since v8
- removed the unnecessary __packed for some definitions: thanks, David!
- hvsock_open_connection:  use offer.u.pipe.user_def[0] to know the connect=
ion
and reorganized the function
direction=20
- reorganized the code according to suggestions from Cathy Avery: split big
functions into small ones, set .setsockopt and getsockopt to
sock_no_setsockopt/sock_no_getsockopt
- inline'd some small list helper functions

Changes since v9
- minimized struct hvsock_sock by making the send/recv buffers pointers.
   the buffers are allocated by kmalloc() in __hvsock_create() now.
- minimized the sizes of the send/recv buffers and the vmbus ringbuffers.

Changes since v10

1) add module params: send_ring_page, recv_ring_page. They can be used to
enlarge the ringbuffer size to get better performance, e.g.,
# modprobe hv_sock  recv_ring_page=3D16 send_ring_page=3D16
By default, recv_ring_page is 3 and send_ring_page is 2.

2) add module param max_socket_number (the default is 1024).
A user can enlarge the number to create more than 1024 hv_sock sockets.
By default, 1024 sockets take about 1024 * (3+2+1+1) * 4KB =3D 28M bytes.
(Here 1+1 means 1 page for send/recv buffers per connection, respectively.)

3) implement the TODO in hvsock_shutdown().

4) fix a bug in hvsock_close_connection():
   I remove "sk->sk_socket->state =3D SS_UNCONNECTED;" -- actually this lin=
e
is not really useful. For a connection triggered by a host app's connect(),
sk->sk_socket remains NULL before the connection is accepted by the server
app (in Linux VM): see hvsock_accept() -> hvsock_accept_wait() ->
sock_graft(connected, newsock). If the host app exits before the server
app's accept() returns, the host can send a rescind-message to close the
connection and later in the Linux VM's message handler=20
i.e. vmbus_onoffer_rescind()), Linux will get a NULL de-referencing crash.=
=20

5) fix a bug in hvsock_open_connection()
  I move the vmbus_set_chn_rescind_callback() to a later place, because
when vmbus_open() fails, hvsock_close_connection() can do nothing and we
count on vmbus_onoffer_rescind() -> vmbus_device_unregister() to clean up
the device.

6) some stylistic modificiation.


Changes since v11:
1) remove the module params as David suggested.

2) use 5 exact pages for VMBus send/recv rings, respectively.
The host side's design of the feature requires 5 exact pages for recv/send
rings respectively -- this is suboptimal considering memory consumption,
however unluckily we have to live with it, before the host comes up with
a new design in the future. :-(

3) remove the per-connection static send/recv buffers
Instead, we allocate and free the buffers dynamically only when we recv/sen=
d
data. This means: when a connection is idle, no memory is consumed as
recv/send buffers at all.
Dexuan Cui (1):
  hv_sock: introduce Hyper-V Sockets

Changes since v12:
return ENOMEM on buffer alllocation failure

   Actually "man read/write" says "Other errors may occur, depending on the
object connected to fd". "man send/recv" indeed lists ENOMEM.
   Considering AF_HYPERV is a new socket type, ENOMEM seems OK here.
   In the long run, I think we should add a new API in the VMBus driver,
allowing data copy from VMBus ringbuffer into user mode buffer directly.
This way, we can even eliminate this temporary buffer.

Changes since v13:
fix some coding style issues pointed out by David.

Changes since v14:
Just some stylistic changes addressing comments from Joe Perches and
Olaf Hering -- thank you!
- add a GPL blurb.
- define a new macro PAGE_SIZE_4K and use it to replace PAGE_SIZE
- change sk_to_hvsock/hvsock_to_sk() from macros to inline functions
- remove a not-very-useful pr_err()
- fix some typos in comment and coding style issues.

Changes since v15:
Made stylistic changes addressing comments from Vitaly Kuznetsov.
Thank you very much for the detailed comments, Vitaly!=20

Dexuan Cui (1):
  hv_sock: introduce Hyper-V Sockets

 MAINTAINERS                 |    2 +
 include/linux/hyperv.h      |   13 +
 include/linux/socket.h      |    4 +-
 include/net/af_hvsock.h     |   78 +++
 include/uapi/linux/hyperv.h |   23 +
 net/Kconfig                 |    1 +
 net/Makefile                |    1 +
 net/hv_sock/Kconfig         |   10 +
 net/hv_sock/Makefile        |    3 +
 net/hv_sock/af_hvsock.c     | 1509 +++++++++++++++++++++++++++++++++++++++=
++++
 10 files changed, 1643 insertions(+), 1 deletion(-)
 create mode 100644 include/net/af_hvsock.h
 create mode 100644 net/hv_sock/Kconfig
 create mode 100644 net/hv_sock/Makefile
 create mode 100644 net/hv_sock/af_hvsock.c

--=20
2.1.0

--_002_CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0CO2PR03MB2182namp_
Content-Type: application/octet-stream; name="delta_v15_vs_v16.patch"
Content-Description: delta_v15_vs_v16.patch
Content-Disposition: attachment; filename="delta_v15_vs_v16.patch"; size=7849;
	creation-date="Mon, 11 Jul 2016 14:51:08 GMT";
	modification-date="Mon, 11 Jul 2016 14:51:08 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvdWFwaS9saW51eC9oeXBlcnYuaCBiL2luY2x1ZGUvdWFwaS9s
aW51eC9oeXBlcnYuaAppbmRleCBkOTQyOTk2Li5lYjNlNDRiIDEwMDY0NAotLS0gYS9pbmNsdWRl
L3VhcGkvbGludXgvaHlwZXJ2LmgKKysrIGIvaW5jbHVkZS91YXBpL2xpbnV4L2h5cGVydi5oCkBA
IC00MDUsMTIgKzQwNSwxMSBAQCBzdHJ1Y3QgaHZfa3ZwX2lwX21zZyB7CiAgKiB0aGUgZmlyc3Qg
MyBmaWVsZHMuIFJlZmVyIHRvOgogICogaHR0cHM6Ly9lbi53aWtpcGVkaWEub3JnL3dpa2kvR2xv
YmFsbHlfdW5pcXVlX2lkZW50aWZpZXIKICAqLwotI2RlZmluZSBndWlkX3QgdXVpZF9sZQogc3Ry
dWN0IHNvY2thZGRyX2h2IHsKIAlfX2tlcm5lbF9zYV9mYW1pbHlfdAlzaHZfZmFtaWx5OyAgLyog
QWRkcmVzcyBmYW1pbHkJCSovCiAJdTE2CQlyZXNlcnZlZDsJICAgICAvKiBNdXN0IGJlIFplcm8J
CSovCi0JZ3VpZF90CQlzaHZfdm1faWQ7CSAgICAgLyogVk0gSUQJCQkqLwotCWd1aWRfdAkJc2h2
X3NlcnZpY2VfaWQ7CSAgICAgLyogU2VydmljZSBJRAkJKi8KKwl1dWlkX2xlCQlzaHZfdm1fZ3Vp
ZDsJICAgICAvKiBWTSBJRAkJCSovCisJdXVpZF9sZQkJc2h2X3NlcnZpY2VfZ3VpZDsgICAgLyog
U2VydmljZSBJRAkJKi8KIH07CiAKICNkZWZpbmUgU0hWX1ZNSURfR1VFU1QJTlVMTF9VVUlEX0xF
CmRpZmYgLS1naXQgYS9uZXQvaHZfc29jay9LY29uZmlnIGIvbmV0L2h2X3NvY2svS2NvbmZpZwpp
bmRleCAxZjQxODQ4Li5mZjg0ODc1IDEwMDY0NAotLS0gYS9uZXQvaHZfc29jay9LY29uZmlnCisr
KyBiL25ldC9odl9zb2NrL0tjb25maWcKQEAgLTMsOCArMyw4IEBAIGNvbmZpZyBIWVBFUlZfU09D
SwogCWRlcGVuZHMgb24gSFlQRVJWCiAJZGVmYXVsdCBtIGlmIEhZUEVSVgogCWhlbHAKLQkgIEh5
cGVyLVYgU29ja2V0cyBpcyBzb21ld2hhdCBsaWtlIFRDUCBvdmVyIFZNQnVzLCBhbGxvd2luZwot
CSAgY29tbXVuaWNhdGlvbiBiZXR3ZWVuIExpbnV4IGd1ZXN0IGFuZCBIeXBlci1WIGhvc3Qgd2l0
aG91dCBUQ1AvSVAuCisJICBIeXBlci1WIFNvY2tldHMgaXMgYSBzb2NrZXQgaW50ZXJmYWNlIGZv
ciBoaWdoIHNwZWVkCisJICBjb21tdW5pY2F0aW9uIGJldHdlZW4gTGludXggZ3Vlc3QgYW5kIEh5
cGVyLVYgaG9zdCBvdmVyIFZNQnVzLgogCiAJICBUbyBjb21waWxlIHRoaXMgZHJpdmVyIGFzIGEg
bW9kdWxlLCBjaG9vc2UgTSBoZXJlOiB0aGUgbW9kdWxlCiAJICB3aWxsIGJlIGNhbGxlZCBodl9z
b2NrLgpkaWZmIC0tZ2l0IGEvbmV0L2h2X3NvY2svYWZfaHZzb2NrLmMgYi9uZXQvaHZfc29jay9h
Zl9odnNvY2suYwppbmRleCBmMzM5ZjM4Li5kODZiODc5IDEwMDY0NAotLS0gYS9uZXQvaHZfc29j
ay9hZl9odnNvY2suYworKysgYi9uZXQvaHZfc29jay9hZl9odnNvY2suYwpAQCAtNTAsMjIgKzUw
LDIyIEBAIHN0YXRpYyBzdHJ1Y3QgcHJvdG8gaHZzb2NrX3Byb3RvID0gewogCiAjZGVmaW5lIFNT
X0xJU1RFTiAyNTUKIAorI2RlZmluZSBIVlNPQ0tfQ09OTkVDVF9USU1FT1VUICgzMCAqIEhaKQor
CisvKiBUaGlzIGlzIGFuIGFydGlmaWNpYWwgbGltaXQgKi8KKyNkZWZpbmUgSFZTT0NLX01BWF9C
QUNLTE9HCTEyOAorCiBzdGF0aWMgTElTVF9IRUFEKGh2c29ja19ib3VuZF9saXN0KTsKIHN0YXRp
YyBMSVNUX0hFQUQoaHZzb2NrX2Nvbm5lY3RlZF9saXN0KTsKIHN0YXRpYyBERUZJTkVfTVVURVgo
aHZzb2NrX211dGV4KTsKIAotc3RhdGljIGJvb2wgdXVpZF9lcXVhbHModXVpZF9sZSB1MSwgdXVp
ZF9sZSB1MikKLXsKLQlyZXR1cm4gIXV1aWRfbGVfY21wKHUxLCB1Mik7Ci19Ci0KIHN0YXRpYyBz
dHJ1Y3Qgc29jayAqaHZzb2NrX2ZpbmRfYm91bmRfc29ja2V0KGNvbnN0IHN0cnVjdCBzb2NrYWRk
cl9odiAqYWRkcikKIHsKIAlzdHJ1Y3QgaHZzb2NrX3NvY2sgKmh2c2s7CiAKIAlsaXN0X2Zvcl9l
YWNoX2VudHJ5KGh2c2ssICZodnNvY2tfYm91bmRfbGlzdCwgYm91bmRfbGlzdCkgewotCQlpZiAo
dXVpZF9lcXVhbHMoYWRkci0+c2h2X3NlcnZpY2VfaWQsCi0JCQkJaHZzay0+bG9jYWxfYWRkci5z
aHZfc2VydmljZV9pZCkpCisJCWlmICghdXVpZF9sZV9jbXAoYWRkci0+c2h2X3NlcnZpY2VfZ3Vp
ZCwKKwkJCQkgaHZzay0+bG9jYWxfYWRkci5zaHZfc2VydmljZV9ndWlkKSkKIAkJCXJldHVybiBo
dnNvY2tfdG9fc2soaHZzayk7CiAJfQogCXJldHVybiBOVUxMOwpAQCAtMTQ3LDcgKzE0Nyw3IEBA
IHN0YXRpYyB2b2lkIGh2c29ja19hZGRyX2luaXQoc3RydWN0IHNvY2thZGRyX2h2ICphZGRyLCB1
dWlkX2xlIHNlcnZpY2VfaWQpCiB7CiAJbWVtc2V0KGFkZHIsIDAsIHNpemVvZigqYWRkcikpOwog
CWFkZHItPnNodl9mYW1pbHkgPSBBRl9IWVBFUlY7Ci0JYWRkci0+c2h2X3NlcnZpY2VfaWQgPSBz
ZXJ2aWNlX2lkOworCWFkZHItPnNodl9zZXJ2aWNlX2d1aWQgPSBzZXJ2aWNlX2lkOwogfQogCiBz
dGF0aWMgaW50IGh2c29ja19hZGRyX3ZhbGlkYXRlKGNvbnN0IHN0cnVjdCBzb2NrYWRkcl9odiAq
YWRkcikKQEAgLTE2Niw3ICsxNjYsNyBAQCBzdGF0aWMgaW50IGh2c29ja19hZGRyX3ZhbGlkYXRl
KGNvbnN0IHN0cnVjdCBzb2NrYWRkcl9odiAqYWRkcikKIAogc3RhdGljIGJvb2wgaHZzb2NrX2Fk
ZHJfYm91bmQoY29uc3Qgc3RydWN0IHNvY2thZGRyX2h2ICphZGRyKQogewotCXJldHVybiAhdXVp
ZF9lcXVhbHMoYWRkci0+c2h2X3NlcnZpY2VfaWQsIFNIVl9TRVJWSUNFX0lEX0FOWSk7CisJcmV0
dXJuICEhdXVpZF9sZV9jbXAoYWRkci0+c2h2X3NlcnZpY2VfZ3VpZCwgU0hWX1NFUlZJQ0VfSURf
QU5ZKTsKIH0KIAogc3RhdGljIGludCBodnNvY2tfYWRkcl9jYXN0KGNvbnN0IHN0cnVjdCBzb2Nr
YWRkciAqYWRkciwgc2l6ZV90IGxlbiwKQEAgLTE4NSwxMyArMTg1LDEzIEBAIHN0YXRpYyBpbnQg
X19odnNvY2tfZG9fYmluZChzdHJ1Y3QgaHZzb2NrX3NvY2sgKmh2c2ssCiAJc3RydWN0IHNvY2th
ZGRyX2h2IGh2X2FkZHI7CiAJaW50IHJldCA9IDA7CiAKLQlodnNvY2tfYWRkcl9pbml0KCZodl9h
ZGRyLCBhZGRyLT5zaHZfc2VydmljZV9pZCk7CisJaHZzb2NrX2FkZHJfaW5pdCgmaHZfYWRkciwg
YWRkci0+c2h2X3NlcnZpY2VfZ3VpZCk7CiAKIAltdXRleF9sb2NrKCZodnNvY2tfbXV0ZXgpOwog
Ci0JaWYgKHV1aWRfZXF1YWxzKGFkZHItPnNodl9zZXJ2aWNlX2lkLCBTSFZfU0VSVklDRV9JRF9B
TlkpKSB7CisJaWYgKCF1dWlkX2xlX2NtcChhZGRyLT5zaHZfc2VydmljZV9ndWlkLCBTSFZfU0VS
VklDRV9JRF9BTlkpKSB7CiAJCWRvIHsKLQkJCXV1aWRfbGVfZ2VuKCZodl9hZGRyLnNodl9zZXJ2
aWNlX2lkKTsKKwkJCXV1aWRfbGVfZ2VuKCZodl9hZGRyLnNodl9zZXJ2aWNlX2d1aWQpOwogCQl9
IHdoaWxlIChodnNvY2tfZmluZF9ib3VuZF9zb2NrZXQoJmh2X2FkZHIpKTsKIAl9IGVsc2Ugewog
CQlpZiAoaHZzb2NrX2ZpbmRfYm91bmRfc29ja2V0KCZodl9hZGRyKSkgewpAQCAtMjAwLDcgKzIw
MCw3IEBAIHN0YXRpYyBpbnQgX19odnNvY2tfZG9fYmluZChzdHJ1Y3QgaHZzb2NrX3NvY2sgKmh2
c2ssCiAJCX0KIAl9CiAKLQlodnNvY2tfYWRkcl9pbml0KCZodnNrLT5sb2NhbF9hZGRyLCBodl9h
ZGRyLnNodl9zZXJ2aWNlX2lkKTsKKwlodnNvY2tfYWRkcl9pbml0KCZodnNrLT5sb2NhbF9hZGRy
LCBodl9hZGRyLnNodl9zZXJ2aWNlX2d1aWQpOwogCiAJc29ja19ob2xkKCZodnNrLT5zayk7CiAJ
bGlzdF9hZGQoJmh2c2stPmJvdW5kX2xpc3QsICZodnNvY2tfYm91bmRfbGlzdCk7CkBAIC0zNjYs
NyArMzY2LDcgQEAgc3RhdGljIGludCBodnNvY2tfYmluZChzdHJ1Y3Qgc29ja2V0ICpzb2NrLCBz
dHJ1Y3Qgc29ja2FkZHIgKmFkZHIsCiAJaWYgKGh2c29ja19hZGRyX2Nhc3QoYWRkciwgYWRkcl9s
ZW4sICZodl9hZGRyKSAhPSAwKQogCQlyZXR1cm4gLUVJTlZBTDsKIAotCWlmICghdXVpZF9lcXVh
bHMoaHZfYWRkci0+c2h2X3ZtX2lkLCBOVUxMX1VVSURfTEUpKQorCWlmICh1dWlkX2xlX2NtcCho
dl9hZGRyLT5zaHZfdm1fZ3VpZCwgTlVMTF9VVUlEX0xFKSkKIAkJcmV0dXJuIC1FSU5WQUw7CiAK
IAlsb2NrX3NvY2soc2spOwpAQCAtNjA5LDcgKzYwOSw2IEBAIHN0YXRpYyB1bnNpZ25lZCBpbnQg
aHZzb2NrX3BvbGwoc3RydWN0IGZpbGUgKmZpbGUsIHN0cnVjdCBzb2NrZXQgKnNvY2ssCiAJCWlm
ICghKHNrLT5za19zaHV0ZG93biAmIFJDVl9TSFVURE9XTikgJiYgY2FuX3JlYWQpCiAJCQltYXNr
IHw9IFBPTExJTiB8IFBPTExSRE5PUk07CiAJfSBlbHNlIHsKLQkJY2FuX3JlYWQgPSBmYWxzZTsK
IAkJY2FuX3dyaXRlID0gZmFsc2U7CiAJfQogCkBAIC02NTQsMTAgKzY1Myw3IEBAIHN0YXRpYyB2
b2lkIGh2c29ja19vbl9jaGFubmVsX2NiKHZvaWQgKmN0eCkKIAogCWh2c2sgPSBza190b19odnNv
Y2soc2spOwogCWNoYW5uZWwgPSBodnNrLT5jaGFubmVsOwotCWlmICghY2hhbm5lbCkgewotCQlX
QVJOX09OQ0UoMSwgIk5VTEwgY2hhbm5lbCEgVGhlcmUgaXMgYSBwcm9ncmFtbWluZyBidWcuXG4i
KTsKLQkJcmV0dXJuOwotCX0KKwlCVUdfT04oIWNoYW5uZWwpOwogCiAJZ2V0X3JpbmdidWZmZXJf
cndfc3RhdHVzKGNoYW5uZWwsICZjYW5fcmVhZCwgJmNhbl93cml0ZSk7CiAKQEAgLTcyMCw3ICs3
MTYsNyBAQCBzdGF0aWMgaW50IGh2c29ja19vcGVuX2Nvbm5lY3Rpb24oc3RydWN0IHZtYnVzX2No
YW5uZWwgKmNoYW5uZWwpCiAKIAlpZiAoY29ubl9mcm9tX2hvc3QpIHsKIAkJaWYgKHNrLT5za19h
Y2tfYmFja2xvZyA+PSBzay0+c2tfbWF4X2Fja19iYWNrbG9nKSB7Ci0JCQlyZXQgPSAtRU1GSUxF
OworCQkJcmV0ID0gLUVDT05OUkVGVVNFRDsKIAkJCWdvdG8gb3V0OwogCQl9CiAKQEAgLTgxMSw3
ICs4MDcsNyBAQCBzdGF0aWMgaW50IGh2c29ja19jb25uZWN0X3dhaXQoc3RydWN0IHNvY2tldCAq
c29jaywKIAlsb25nIHRpbWVvdXQ7CiAKIAlodnNrID0gc2tfdG9faHZzb2NrKHNrKTsKLQl0aW1l
b3V0ID0gMzAgKiBIWjsKKwl0aW1lb3V0ID0gSFZTT0NLX0NPTk5FQ1RfVElNRU9VVDsKIAlwcmVw
YXJlX3RvX3dhaXQoc2tfc2xlZXAoc2spLCAmd2FpdCwgVEFTS19JTlRFUlJVUFRJQkxFKTsKIAog
CXdoaWxlIChzay0+c2tfc3RhdGUgIT0gU1NfQ09OTkVDVEVEICYmIHNrLT5za19lcnIgPT0gMCkg
ewpAQCAtOTA1LDggKzkwMSw4IEBAIHN0YXRpYyBpbnQgaHZzb2NrX2Nvbm5lY3Qoc3RydWN0IHNv
Y2tldCAqc29jaywgc3RydWN0IHNvY2thZGRyICphZGRyLAogCQlzay0+c2tfc3RhdGUgPSBTU19D
T05ORUNUSU5HOwogCiAJCXJldCA9IHZtYnVzX3NlbmRfdGxfY29ubmVjdF9yZXF1ZXN0KAotCQkJ
CQkmaHZzay0+bG9jYWxfYWRkci5zaHZfc2VydmljZV9pZCwKLQkJCQkJJmh2c2stPnJlbW90ZV9h
ZGRyLnNodl9zZXJ2aWNlX2lkKTsKKwkJCQkJJmh2c2stPmxvY2FsX2FkZHIuc2h2X3NlcnZpY2Vf
Z3VpZCwKKwkJCQkJJmh2c2stPnJlbW90ZV9hZGRyLnNodl9zZXJ2aWNlX2d1aWQpOwogCQlpZiAo
cmV0IDwgMCkKIAkJCWdvdG8gb3V0OwogCkBAIC05NjQsMTUgKzk2MCwxMiBAQCBzdGF0aWMgaW50
IGh2c29ja19hY2NlcHRfd2FpdChzdHJ1Y3Qgc29jayAqbGlzdGVuZXIsCiAJCWxvY2tfc29jayhj
b25uZWN0ZWQpOwogCQlodmNvbm5lY3RlZCA9IHNrX3RvX2h2c29jayhjb25uZWN0ZWQpOwogCi0J
CWlmIChyZXQpIHsKLQkJCXJlbGVhc2Vfc29jayhjb25uZWN0ZWQpOwotCQkJc29ja19wdXQoY29u
bmVjdGVkKTsKLQkJfSBlbHNlIHsKKwkJaWYgKCFyZXQpIHsKIAkJCW5ld3NvY2stPnN0YXRlID0g
U1NfQ09OTkVDVEVEOwogCQkJc29ja19ncmFmdChjb25uZWN0ZWQsIG5ld3NvY2spOwotCQkJcmVs
ZWFzZV9zb2NrKGNvbm5lY3RlZCk7Ci0JCQlzb2NrX3B1dChjb25uZWN0ZWQpOwogCQl9CisJCXJl
bGVhc2Vfc29jayhjb25uZWN0ZWQpOworCQlzb2NrX3B1dChjb25uZWN0ZWQpOwogCX0KIAogb3V0
X3dhaXQ6CkBAIC0xMDI5LDkgKzEwMjIsOCBAQCBzdGF0aWMgaW50IGh2c29ja19saXN0ZW4oc3Ry
dWN0IHNvY2tldCAqc29jaywgaW50IGJhY2tsb2cpCiAJCXJldCA9IC1FSU5WQUw7CiAJCWdvdG8g
b3V0OwogCX0KLQkvKiBUaGlzIGlzIGFuIGFydGlmaWNpYWwgbGltaXQgKi8KLQlpZiAoYmFja2xv
ZyA+IDEyOCkKLQkJYmFja2xvZyA9IDEyODsKKwlpZiAoYmFja2xvZyA+IEhWU09DS19NQVhfQkFD
S0xPRykKKwkJYmFja2xvZyA9IEhWU09DS19NQVhfQkFDS0xPRzsKIAogCWh2c2sgPSBza190b19o
dnNvY2soc2spOwogCWlmICghaHZzb2NrX2FkZHJfYm91bmQoJmh2c2stPmxvY2FsX2FkZHIpKSB7
CkBAIC0xMDU3LDcgKzEwNDksNyBAQCBzdGF0aWMgaW50IGh2c29ja19zZW5kbXNnX3dhaXQoc3Ry
dWN0IHNvY2sgKnNrLCBzdHJ1Y3QgbXNnaGRyICptc2csCiAJREVGSU5FX1dBSVQod2FpdCk7CiAJ
Ym9vbCBjYW5fd3JpdGU7CiAJbG9uZyB0aW1lb3V0OwotCWludCByZXQgPSAwOworCWludCByZXQ7
CiAKIAl0aW1lb3V0ID0gc29ja19zbmR0aW1lbyhzaywgbXNnLT5tc2dfZmxhZ3MgJiBNU0dfRE9O
VFdBSVQpOwogCXByZXBhcmVfdG9fd2FpdChza19zbGVlcChzayksICZ3YWl0LCBUQVNLX0lOVEVS
UlVQVElCTEUpOwpAQCAtMTE2MiwxMSArMTE1NCw4IEBAIHN0YXRpYyBpbnQgaHZzb2NrX3NlbmRt
c2coc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbXNnLAogCWlmIChsZW4gPT0g
MCkKIAkJcmV0dXJuIC1FSU5WQUw7CiAKLQlpZiAobXNnLT5tc2dfZmxhZ3MgJiB+TVNHX0RPTlRX
QUlUKSB7Ci0JCXByX2VycigiJXM6IHVuc3VwcG9ydGVkIGZsYWdzPTB4JXhcbiIsIF9fZnVuY19f
LAotCQkgICAgICAgbXNnLT5tc2dfZmxhZ3MpOworCWlmIChtc2ctPm1zZ19mbGFncyAmIH5NU0df
RE9OVFdBSVQpCiAJCXJldHVybiAtRU9QTk9UU1VQUDsKLQl9CiAKIAlzayA9IHNvY2stPnNrOwog
CWh2c2sgPSBza190b19odnNvY2soc2spOwpAQCAtMTIwMSwxMSArMTE5MCwxMCBAQCBzdGF0aWMg
aW50IGh2c29ja19zZW5kbXNnKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBtc2doZHIgKm1z
ZywKIG91dDoKIAlyZWxlYXNlX3NvY2soc2spOwogCi0JLyogcmV0IGlzIGEgYmlnZ2VyLXRoYW4t
MCB0b3RhbF93cml0dGVuIG9yIGEgbmVnYXRpdmUgZXJyIGNvZGUuICovCi0JaWYgKHJldCA9PSAw
KSB7Ci0JCVdBUk4oMSwgInVuZXhwZWN0ZWQgcmV0dXJuIHZhbHVlIG9mIDBcbiIpOwotCQlyZXQg
PSAtRUlPOwotCX0KKwkvKiByZXQgc2hvdWxkIGJlIGEgYmlnZ2VyLXRoYW4tMCB0b3RhbF93cml0
dGVuIG9yIGEgbmVnYXRpdmUgZXJyCisJICogY29kZS4KKwkgKi8KKwlCVUdfT04ocmV0ID09IDAp
OwogCiAJcmV0dXJuIHJldDsKIH0KQEAgLTEzNTgsNyArMTM0Niw2IEBAIHN0YXRpYyBpbnQgaHZz
b2NrX3JlY3Ztc2coc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbXNnLAogCiAJ
LyogV2UgaWdub3JlIG1zZy0+YWRkcl9uYW1lL2xlbi4gKi8KIAlpZiAoZmxhZ3MgJiB+TVNHX0RP
TlRXQUlUKSB7Ci0JCXByX2VycigiJXM6IHVuc3VwcG9ydGVkIGZsYWdzPTB4JXhcbiIsIF9fZnVu
Y19fLCBmbGFncyk7CiAJCXJldCA9IC1FT1BOT1RTVVBQOwogCQlnb3RvIG91dDsKIAl9CkBAIC0x
NDc4LDggKzE0NjUsNyBAQCBzdGF0aWMgaW50IF9faW5pdCBodnNvY2tfaW5pdCh2b2lkKQogewog
CWludCByZXQ7CiAKLQkvKiBIeXBlci1WIFNvY2tldHMgcmVxdWlyZXMgYXQgbGVhc3QgVk1CdXMg
NC4wICovCi0JaWYgKCh2bWJ1c19wcm90b192ZXJzaW9uID4+IDE2KSA8IDQpCisJaWYgKHZtYnVz
X3Byb3RvX3ZlcnNpb24gPCBWRVJTSU9OX1dJTjEwKQogCQlyZXR1cm4gLUVOT0RFVjsKIAogCXJl
dCA9IHZtYnVzX2RyaXZlcl9yZWdpc3RlcigmaHZzb2NrX2Rydik7Cg==

--_002_CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0CO2PR03MB2182namp_--
