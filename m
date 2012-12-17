From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH v3] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945
 IP phones
Date: Mon, 17 Dec 2012 00:17:21 +0000
Message-ID: <1355703441.18919.6.camel@shinybook.infradead.org>
References: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
	 <1290412334.2756.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-PV7gEsFjThx9qJ3RzYlW"
Cc: Kevin Cernekee <cernekee@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290412334.2756.141.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-PV7gEsFjThx9qJ3RzYlW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-11-22 at 08:52 +0100, Eric Dumazet wrote:
> Le dimanche 21 novembre 2010 =C3=A0 18:40 -0800, Kevin Cernekee a =C3=A9c=
rit :
> > [v3:
> >   Only activate the new forced_dport logic if the IP matches, but the
> >   port does not. ]
> >=20
> > Most SIP devices use a source port of 5060/udp on SIP requests, so the
> > response automatically comes back to port 5060:
> >=20
> > phone_ip:5060 -> proxy_ip:5060   REGISTER
> > proxy_ip:5060 -> phone_ip:5060   100 Trying
> >=20
> > The newer Cisco IP phones, however, use a randomly chosen high source
> > port for the SIP request but expect the response on port 5060:
> >=20
> > phone_ip:49173 -> proxy_ip:5060  REGISTER
> > proxy_ip:5060 -> phone_ip:5060   100 Trying
> >=20
> > Standard Linux NAT, with or without nf_nat_sip, will send the reply bac=
k
> > to port 49173, not 5060:
> >=20
> > phone_ip:49173 -> proxy_ip:5060  REGISTER
> > proxy_ip:5060 -> phone_ip:49173  100 Trying
> >=20
> > But the phone is not listening on 49173, so it will never see the reply=
.
> >=20
> > This patch modifies nf_*_sip to work around this quirk by extracting
> > the SIP response port from the Via: header, iff the source IP in the
> > packet header matches the source IP in the SIP request.
> >=20
> > Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
> > ---
>=20
> Thanks for doing this work Keven !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

What happened to this? OpenWRT is still carrying it, and it broke in
3.7. Here's a completely untested update...

 +              if (!skb_make_writable(skb, skb->len))
 +                      return NF_DROP;
 +
-+              uh =3D (struct udphdr *)(skb->data + ip_hdrlen(skb));
++              uh =3D (void *)skb->data + protoff;
 +              uh->dest =3D ct_sip_info->forced_dport;
 +
-+              if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, 0, 0, NULL, =
0))
++              if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, protoff, 0, =
0, NU
 +                      return NF_DROP;
 +      }
 +
        return NF_ACCEPT;
  }
 =20


diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/net=
filter/nf_conntrack_sip.h
index 387bdd0..ba7f571 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -4,12 +4,15 @@
=20
 #include <net/netfilter/nf_conntrack_expect.h>
=20
+#include <linux/types.h>
+
 #define SIP_PORT	5060
 #define SIP_TIMEOUT	3600
=20
 struct nf_ct_sip_master {
 	unsigned int	register_cseq;
 	unsigned int	invite_cseq;
+	__be16		forced_dport;
 };
=20
 enum sip_expectation_classes {
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_=
sip.c
index df8f4f2..72a67bb 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1440,8 +1440,25 @@ static int process_sip_request(struct sk_buff *skb, =
unsigned int protoff,
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
+	struct nf_ct_sip_master *ct_sip_info =3D nfct_help_data(ct);
+	enum ip_conntrack_dir dir =3D CTINFO2DIR(ctinfo);
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
+	union nf_inet_addr addr;
+	__be16 port;
+
+	/* Many Cisco IP phones use a high source port for SIP requests, but
+	 * listen for the response on port 5060.  If we are the local
+	 * router for one of these phones, save the port number from the
+	 * Via: header so that nf_nat_sip can redirect the responses to
+	 * the correct port.
+	 */
+	if (ct_sip_parse_header_uri(ct, *dptr, NULL, *datalen,
+				    SIP_HDR_VIA_UDP, NULL, &matchoff,
+				    &matchlen, &addr, &port) > 0 &&
+	    port !=3D ct->tuplehash[dir].tuple.src.u.udp.port &&
+	    nf_inet_addr_cmp(&addr, &ct->tuplehash[dir].tuple.src.u3))
+		ct_sip_info->forced_dport =3D port;
=20
 	for (i =3D 0; i < ARRAY_SIZE(sip_handlers); i++) {
 		const struct sip_handler *handler;
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index 16303c7..552e270 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -95,6 +95,7 @@ static int map_addr(struct sk_buff *skb, unsigned int pro=
toff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir =3D CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info =3D nfct_help_data(ct);
 	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
 	unsigned int buflen;
 	union nf_inet_addr newaddr;
@@ -107,7 +108,8 @@ static int map_addr(struct sk_buff *skb, unsigned int p=
rotoff,
 	} else if (nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3, addr) &&
 		   ct->tuplehash[dir].tuple.dst.u.udp.port =3D=3D port) {
 		newaddr =3D ct->tuplehash[!dir].tuple.src.u3;
-		newport =3D ct->tuplehash[!dir].tuple.src.u.udp.port;
+		newport =3D ct_sip_info->forced_dport ? ct_sip_info->forced_dport :
+			  ct->tuplehash[!dir].tuple.src.u.udp.port;
 	} else
 		return 1;
=20
@@ -144,6 +146,7 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, uns=
igned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir =3D CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info =3D nfct_help_data(ct);
 	unsigned int coff, matchoff, matchlen;
 	enum sip_header_types hdr;
 	union nf_inet_addr addr;
@@ -258,6 +261,20 @@ next:
 	    !map_sip_addr(skb, protoff, dataoff, dptr, datalen, SIP_HDR_TO))
 		return NF_DROP;
=20
+	/* Mangle destination port for Cisco phones, then fix up checksums */
+	if (dir =3D=3D IP_CT_DIR_REPLY && ct_sip_info->forced_dport) {
+		struct udphdr *uh;
+
+		if (!skb_make_writable(skb, skb->len))
+			return NF_DROP;
+
+		uh =3D (void *)skb->data + protoff;
+		uh->dest =3D ct_sip_info->forced_dport;
+
+		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo, protoff, 0, 0, NULL, 0))
+			return NF_DROP;
+	}
+
 	return NF_ACCEPT;
 }
=20
@@ -311,8 +328,10 @@ static unsigned int nf_nat_sip_expect(struct sk_buff *=
skb, unsigned int protoff,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
 	enum ip_conntrack_dir dir =3D CTINFO2DIR(ctinfo);
+	struct nf_ct_sip_master *ct_sip_info =3D nfct_help_data(ct);
 	union nf_inet_addr newaddr;
 	u_int16_t port;
+	__be16 srcport;
 	char buffer[INET6_ADDRSTRLEN + sizeof("[]:nnnnn")];
 	unsigned int buflen;
=20
@@ -326,8 +345,9 @@ static unsigned int nf_nat_sip_expect(struct sk_buff *s=
kb, unsigned int protoff,
 	/* If the signalling port matches the connection's source port in the
 	 * original direction, try to use the destination port in the opposite
 	 * direction. */
-	if (exp->tuple.dst.u.udp.port =3D=3D
-	    ct->tuplehash[dir].tuple.src.u.udp.port)
+	srcport =3D ct_sip_info->forced_dport ? ct_sip_info->forced_dport :
+		  ct->tuplehash[dir].tuple.src.u.udp.port;
+	if (exp->tuple.dst.u.udp.port =3D=3D srcport)
 		port =3D ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port);
 	else
 		port =3D ntohs(exp->tuple.dst.u.udp.port);

--=20
dwmw2


--=-PV7gEsFjThx9qJ3RzYlW
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIUbjCCBjQw
ggQcoAMCAQICAR4wDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoX
DTE3MTAyNDIxMDE1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcJg8zOLdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK
75xCGhR8ToREoqe7zM9/UnC6TS2y9UKTpT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC
+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirMcNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxD
z2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSDkOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr
/+N2JLKutIxMYqQOJebr/f/h5t95m4JgrM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFc
fH6WNU7y1LhRgjAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywG
XLhjjF6uHLkjd02hcdh9hrw+VUsv+q1eeQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXlt
UfO4n4bGGdKo3awPWp61tjAFgraLJgDk+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+R
HxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJFws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktv
sv6hxHTLhiMKX893gxdT3XLS9OKmCv87vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+s
sS5XMEoznzpihEP0PLc4dCBYjbvSD7kxgDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq
+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGT
zWLpXDSfLSplbY2LL9C9U0ptvjcDjefLTvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGq
Up/pNy8ZuPGQmHwFi2/14+xeSUDG2bwnsYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb1
9mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMIIHFzCCBf+g
AwIBAgIDBCZ6MA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYG
A1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcN
MTIwNTAxMTI1ODI3WhcNMTMwNTAzMTEzNzIwWjBdMRkwFwYDVQQNExA4Y1VOSzUzMTc0ODRYRjk3
MRwwGgYDVQQDDBNkd213MkBpbmZyYWRlYWQub3JnMSIwIAYJKoZIhvcNAQkBFhNkd213MkBpbmZy
YWRlYWQub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyYe7wo6MrtrB4uIGGbrY
4IifY/Xsq22pSv605yganL0+uyUdd8rCjrYlH6Q/ra5TVJCQFTgzaepkuqPQc79DC/Cxmzm6Qo+s
wLZy868oFsccsVokL2bPAWIPaRXfNPJKkYR1FTWQfZpWJVQmT+sPf1XFUullVBAK+d9RztopyacI
xWoZ/W/Cmv7mseQbttYTtGKJa0btX73nsQRWl6SgErWXo59zg9friCLTy1GXMXJYB8H+PtnuwX0w
MrAvWDdX1ABgIlA17W3FraCn0eW15ZM46eyu0/amGzJZNtemCWF73P7BAijzeV1jNmiJFXdZ0DT0
w+hmtMO9PxdDUyt78QIDAQABo4IDrjCCA6owCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0l
BBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMB0GA1UdDgQWBBTkfe5UOr3PcirsjApibyyUEfsyRzAf
BgNVHSMEGDAWgBRTcu2SnODaywFcfH6WNU7y1LhRgjAeBgNVHREEFzAVgRNkd213MkBpbmZyYWRl
YWQub3JnMIICIQYDVR0gBIICGDCCAhQwggIQBgsrBgEEAYG1NwECAjCCAf8wLgYIKwYBBQUHAgEW
Imh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93
d3cuc3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0YXJ0
Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdhcyBp
c3N1ZWQgYWNjb3JkaW5nIHRvIHRoZSBDbGFzcyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRzIG9m
IHRoZSBTdGFydENvbSBDQSBwb2xpY3ksIHJlbGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRlZCBw
dXJwb3NlIGluIGNvbXBsaWFuY2Ugb2YgdGhlIHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMuMIGc
BggrBgEFBQcCAjCBjzAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgECGmRM
aWFiaWxpdHkgYW5kIHdhcnJhbnRpZXMgYXJlIGxpbWl0ZWQhIFNlZSBzZWN0aW9uICJMZWdhbCBh
bmQgTGltaXRhdGlvbnMiIG9mIHRoZSBTdGFydENvbSBDQSBwb2xpY3kuMDYGA1UdHwQvMC0wK6Ap
oCeGJWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUFBwEBBIGB
MH8wOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3MxL2NsaWVu
dC9jYTBCBggrBgEFBQcwAoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3ViLmNsYXNz
MS5jbGllbnQuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29tLzANBgkq
hkiG9w0BAQUFAAOCAQEAqDU1FKifNtCFJbLnvOi1BLRfk7mut55PMtPSZLJ4/AnG7AjmJnbBI4U5
DELwvVq3mIpwUpGqZUkqkZMEfBPIbfq517UZB3h4iANtqif+ULfTLhg5XgcK5eF8/T6EtX2c3epq
ylARdleCbj/0FwiUDvPlTsA6PIN4SCekjRLgjKERrL3heFz+Hteq1rtMAvMkNuyL0/0ijyyg2y45
NASAl2Afl9SLes/fnoh9nBwzfNQfb6qDYUFpnglfpGrq/0b1NtaOUb2z1SR+H1tKlb8bVJJIdvpu
mEi27kSRIhzk3h30uTfKkKetgy++ouyldxZ7KZ0PuoLQrBy465EoQLosETCCBxcwggX/oAMCAQIC
AwQmejANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBMB4XDTEyMDUw
MTEyNTgyN1oXDTEzMDUwMzExMzcyMFowXTEZMBcGA1UEDRMQOGNVTks1MzE3NDg0WEY5NzEcMBoG
A1UEAwwTZHdtdzJAaW5mcmFkZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFk
Lm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMmHu8KOjK7aweLiBhm62OCIn2P1
7KttqUr+tOcoGpy9PrslHXfKwo62JR+kP62uU1SQkBU4M2nqZLqj0HO/QwvwsZs5ukKPrMC2cvOv
KBbHHLFaJC9mzwFiD2kV3zTySpGEdRU1kH2aViVUJk/rD39VxVLpZVQQCvnfUc7aKcmnCMVqGf1v
wpr+5rHkG7bWE7RiiWtG7V+957EEVpekoBK1l6Ofc4PX64gi08tRlzFyWAfB/j7Z7sF9MDKwL1g3
V9QAYCJQNe1txa2gp9HlteWTOOnsrtP2phsyWTbXpglhe9z+wQIo83ldYzZoiRV3WdA09MPoZrTD
vT8XQ1Mre/ECAwEAAaOCA64wggOqMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQG
CCsGAQUFBwMCBggrBgEFBQcDBDAdBgNVHQ4EFgQU5H3uVDq9z3Iq7IwKYm8slBH7MkcwHwYDVR0j
BBgwFoAUU3Ltkpzg2ssBXHx+ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9y
ZzCCAiEGA1UdIASCAhgwggIUMIICEAYLKwYBBAGBtTcBAgIwggH/MC4GCCsGAQUFBwIBFiJodHRw
Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRwOi8vd3d3LnN0
YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBD
ZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVk
IGFjY29yZGluZyB0byB0aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUg
U3RhcnRDb20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9z
ZSBpbiBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjCBnAYIKwYB
BQUHAgIwgY8wJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBAhpkTGlhYmls
aXR5IGFuZCB3YXJyYW50aWVzIGFyZSBsaW1pdGVkISBTZWUgc2VjdGlvbiAiTGVnYWwgYW5kIExp
bWl0YXRpb25zIiBvZiB0aGUgU3RhcnRDb20gQ0EgcG9saWN5LjA2BgNVHR8ELzAtMCugKaAnhiVo
dHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkG
CCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2Ew
QgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xp
ZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcN
AQEFBQADggEBAKg1NRSonzbQhSWy57zotQS0X5O5rreeTzLT0mSyePwJxuwI5iZ2wSOFOQxC8L1a
t5iKcFKRqmVJKpGTBHwTyG36ude1GQd4eIgDbaon/lC30y4YOV4HCuXhfP0+hLV9nN3qaspQEXZX
gm4/9BcIlA7z5U7AOjyDeEgnpI0S4IyhEay94Xhc/h7Xqta7TALzJDbsi9P9Io8soNsuOTQEgJdg
H5fUi3rP356IfZwcM3zUH2+qg2FBaZ4JX6Rq6v9G9TbWjlG9s9Ukfh9bSpW/G1SSSHb6bphItu5E
kSIc5N4d9Lk3ypCnrYMvvqLspXcWeymdD7qC0KwcuOuRKEC6LBExggNvMIIDawIBATCBlDCBjDEL
MAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdp
dGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFy
eSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMEJnowCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkD
MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTIxMjE3MDAxNzIxWjAjBgkqhkiG9w0BCQQx
FgQUIw8CSK+8MbssborY11QlJWkVNVswgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMC
SUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRp
ZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1l
ZGlhdGUgQ2xpZW50IENBAgMEJnowgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJ
TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlm
aWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVk
aWF0ZSBDbGllbnQgQ0ECAwQmejANBgkqhkiG9w0BAQEFAASCAQAPjAIel7VnfhZZh1HzI1GyUqkP
i3owShcXS2uGr/g3e5Qi21D3MYnI2lBIz6mFozF5of1re/aCgfZz2lc9YKSB0a7wALRtNjCWxXI8
3vHKatM9Rxudb8A7VolqIDYbAxsUOvfFbw/jJ3EZ637KJmpQU7egIk6HpmfoPScny2BZ24DFAHrx
dMxKRB440XwyQwaHvC7rH4upnMcK0uFIlssRKIWOMvN3NlkS73NEWySfKG3wMHx2/p2hhH/LqopU
/DfcH8RRYPSy2Xijef+DHjYbx/4pWkAQf/kNfeS87fjWgFVAZhtYXw99BX98lQwq71WoG7H2fPJO
4nTetNdXZ2x8AAAAAAAA


--=-PV7gEsFjThx9qJ3RzYlW--

