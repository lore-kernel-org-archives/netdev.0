From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH v2] Fix AF_PACKET ABI breakage in 4.2
Date: Wed, 23 Sep 2015 19:45:08 +0100
Message-ID: <1443033908.74600.21.camel@infradead.org>
References: <1443019470.74600.6.camel@infradead.org>
	 <20150923.110926.1369752430685358746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-SdJev/AcFENEZ6GQhmPS"
Cc: netdev@vger.kernel.org, gkurz@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, mst@redhat.com, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20150923.110926.1369752430685358746.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SdJev/AcFENEZ6GQhmPS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Commit 7d82410950aa ("virtio: add explicit big-endian support to memory
accessors") accidentally changed the virtio_net header used by
AF_PACKET with PACKET_VNET_HDR from host-endian to big-endian.

Since virtio_legacy_is_little_endian() is a very long identifier,
define a VIO_LE macro and use that throughout the code instead of the
hard-coded 'false' for little-endian.

This restores the ABI to match 4.1 and earlier kernels, and makes my
test program work again.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
On Wed, 2015-09-23 at 11:09 -0700, David Miller wrote:
> > +#define VIO_LE virtio_legacy_is_little_endian()
>=20
> When you define a shorthand macro, the defines to a function call,
> make the macro have parenthesis too.

In which case I suppose it also wants to be lower-case. Although
"function call" is a bit strong since it's effectively just a constant.
I'm still wondering if it'd be nicer just to use (__force u16) instead.

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 7b8e39a..aa4b15c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -230,6 +230,8 @@ struct packet_skb_cb {
 	} sa;
 };
=20
+#define vio_le() virtio_legacy_is_little_endian()
+
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
=20
 #define GET_PBDQC_FROM_RB(x)	((struct tpacket_kbdq_core *)(&(x)->prb_bdqc)=
)
@@ -2680,15 +2682,15 @@ static int packet_snd(struct socket *sock, struct m=
sghdr *msg, size_t len)
 			goto out_unlock;
=20
 		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
-		    (__virtio16_to_cpu(false, vnet_hdr.csum_start) +
-		     __virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2 >
-		      __virtio16_to_cpu(false, vnet_hdr.hdr_len)))
-			vnet_hdr.hdr_len =3D __cpu_to_virtio16(false,
-				 __virtio16_to_cpu(false, vnet_hdr.csum_start) +
-				__virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2);
+		    (__virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
+		     __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2 >
+		      __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len)))
+			vnet_hdr.hdr_len =3D __cpu_to_virtio16(vio_le(),
+				 __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
+				__virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2);
=20
 		err =3D -EINVAL;
-		if (__virtio16_to_cpu(false, vnet_hdr.hdr_len) > len)
+		if (__virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len) > len)
 			goto out_unlock;
=20
 		if (vnet_hdr.gso_type !=3D VIRTIO_NET_HDR_GSO_NONE) {
@@ -2731,7 +2733,7 @@ static int packet_snd(struct socket *sock, struct msg=
hdr *msg, size_t len)
 	hlen =3D LL_RESERVED_SPACE(dev);
 	tlen =3D dev->needed_tailroom;
 	skb =3D packet_alloc_skb(sk, hlen + tlen, hlen, len,
-			       __virtio16_to_cpu(false, vnet_hdr.hdr_len),
+			       __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
 			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb =3D=3D NULL)
 		goto out_unlock;
@@ -2778,8 +2780,8 @@ static int packet_snd(struct socket *sock, struct msg=
hdr *msg, size_t len)
=20
 	if (po->has_vnet_hdr) {
 		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-			u16 s =3D __virtio16_to_cpu(false, vnet_hdr.csum_start);
-			u16 o =3D __virtio16_to_cpu(false, vnet_hdr.csum_offset);
+			u16 s =3D __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start);
+			u16 o =3D __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset);
 			if (!skb_partial_csum_set(skb, s, o)) {
 				err =3D -EINVAL;
 				goto out_free;
@@ -2787,7 +2789,7 @@ static int packet_snd(struct socket *sock, struct msg=
hdr *msg, size_t len)
 		}
=20
 		skb_shinfo(skb)->gso_size =3D
-			__virtio16_to_cpu(false, vnet_hdr.gso_size);
+			__virtio16_to_cpu(vio_le(), vnet_hdr.gso_size);
 		skb_shinfo(skb)->gso_type =3D gso_type;
=20
 		/* Header must be checked, and gso_segs computed. */
@@ -3161,9 +3163,9 @@ static int packet_recvmsg(struct socket *sock, struct=
 msghdr *msg, size_t len,
=20
 			/* This is a hint as to how much should be linear. */
 			vnet_hdr.hdr_len =3D
-				__cpu_to_virtio16(false, skb_headlen(skb));
+				__cpu_to_virtio16(vio_le(), skb_headlen(skb));
 			vnet_hdr.gso_size =3D
-				__cpu_to_virtio16(false, sinfo->gso_size);
+				__cpu_to_virtio16(vio_le(), sinfo->gso_size);
 			if (sinfo->gso_type & SKB_GSO_TCPV4)
 				vnet_hdr.gso_type =3D VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
@@ -3181,9 +3183,9 @@ static int packet_recvmsg(struct socket *sock, struct=
 msghdr *msg, size_t len,
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 			vnet_hdr.flags =3D VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			vnet_hdr.csum_start =3D __cpu_to_virtio16(false,
+			vnet_hdr.csum_start =3D __cpu_to_virtio16(vio_le(),
 					  skb_checksum_start_offset(skb));
-			vnet_hdr.csum_offset =3D __cpu_to_virtio16(false,
+			vnet_hdr.csum_offset =3D __cpu_to_virtio16(vio_le(),
 							 skb->csum_offset);
 		} else if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY) {
 			vnet_hdr.flags =3D VIRTIO_NET_HDR_F_DATA_VALID;

--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


--=-SdJev/AcFENEZ6GQhmPS
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUwOTIzMTg0NTA4WjAjBgkqhkiG9w0BCQQxFgQUuAu6v3NdwTYMzW4D1BqW9qTQ0mYw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQCj1WWvxdtU8WHOdzaMpzxZe4XwI86P1x6hhCsSi8OgLy2t44bNK4rmtILk
doxwQpmfS7uYdMoboVPY/jzOEj91zxYt22yTj655qfzw33658a+YYUk+XfjocKfmKh7230odeJ74
izg0y5KjYwvxGWhMT9yQoCeFaG8QGuIWrKm4y9G6uCKXMSFAJd25Zl6spwaF5Z2BgI94FaY+zN8V
ipyskXnU2t3Pc4lV5NA7QUX+LgwiTw3QLJ3cye+Yh1rC44l45iKGw01NJWs18ZhOZNm24g22OgGG
5gOtBBYAABPiZlUlQCFYmdlbkBJgS+6tWwtq2y2afL9/zZqR8BOzrKKnAAAAAAAA


--=-SdJev/AcFENEZ6GQhmPS--

