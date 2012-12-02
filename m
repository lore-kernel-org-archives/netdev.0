From: David Woodhouse <dwmw2@infradead.org>
Subject: Checking struct size against sizeof(skb->cb) (was Re: [PATCH 00/17]
 ATM fixes for pppoatm/br2684)
Date: Sun, 02 Dec 2012 21:29:41 +0000
Message-ID: <1354483781.24281.16.camel@shinybook.infradead.org>
References: <20121201.114440.331740099591161757.davem@davemloft.net>
	 <1354383226.21562.351.camel@shinybook.infradead.org>
	 <1354408847.21562.365.camel@shinybook.infradead.org>
	 <20121201.204906.1703696018528746748.davem@davemloft.net>
	 <1354436040.21562.386.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-q+vNcgrniY8ErKG3SUGT"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58338 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070Ab2LBV3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 16:29:49 -0500
In-Reply-To: <1354436040.21562.386.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q+vNcgrniY8ErKG3SUGT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-12-02 at 08:14 +0000, David Woodhouse wrote:
> On Sat, 2012-12-01 at 20:49 -0500, David Miller wrote:
> >=20
> > I actually prefer what we do now, which is do the BUILD_BUG_ON()
> > once in the subsystem specific code, usually the initializer.
> >=20
> > It's part of creating a new SKB cb, adding that assertion somewhere.
>=20
> Where it's *subsystem* code that's great...

Hmm... or maybe not. A quick check suggests that about two-thirds of
users even in net/ aren't actually doing the check. My brief
investigation gives a score of 30 to 14 (or thereabouts; there may be
some that *do* check, but I failed to spot it. And I used a Fedora
config, not allyesconfig).

If you don't want an automatic check/cast macro (which is only adding a
compile-time check; no runtime overhead), then is it worth doing a
bombing run on the offenders listed below and adding the manual checks?
And I'll look at *drivers* next... which I suspect will be worse.

I concede there are probably no actual *bugs* being hidden here =E2=80=94 I
don't think any of them actually *do* overflow. But since the check is
free at run-time, we *ought* to be doing it. Even if a given struct is
tiny and there's no *chance* of it overflowing, people might still add
to it. After all, the solos_skb_cb struct was tiny too until I stupidly
added a completion to it.

(Actually, I'm not entirely sure about 'no bugs'. The L2TP thing with
starting its own struct at &skb->cb[sizeof(struct inet_skb_parm)]
doesn't make it overflow, but what the hell is l2tp_xmit_skb() doing
poking at IPCB(skb) anyway... is it even guaranteed to be Legacy IP? Can
it not be IPv6? And why would anything else *trust* the contents of ->cb
on a skb that just got handed to it?)


My list:

Size not checked against sizeof(skb->cb):

struct napi_gro_cb (include/linux/netdevice.h)
struct ip6_mtuinfo (include/linux/ipv6.h)
struct sctp_ulpevent (include/net/sctp/ulpevent.h)
struct bt_skb_cb (include/net/bluetooth/bluetooth.h)
struct atm_skb_data (include/linux/atmdev.h)
struct br_input_skb_cb (net/bridge/br_private.h)
struct hci_cb (include/net/bluetooth/hci_core.h)
struct sock_exterr_skb (include/linux/errqueue.h)
struct udp_skb_cb (include/net/udp.h)
struct ipx_cb (include/net/ipx.h)
struct neighbour_cb (include/net/neighbour.h)
struct ip6frag_skb_cb (net/ipv6/reassembly.c)
struct dev_gso_cb (net/core/dev.c)
struct irda_skb_cb (include/net/irda/irda_device.h)
struct cmtp_skb (net/bluetooth/cmtp/cmtp.h)
struct ipfrag_skb_cb (net/ipv6/ip_fragment.c)
struct xfrm_skb_cb (include/net/xfrm.h)
struct xfrm_mode_skb_cb (include/net/xfrm.h)
struct xfrm_spi_skb_cb (include/net/xfrm.h)
struct in_pktinfo (include/uapi/linux/in.h)
struct nf_ct_frag6_skb_cb (net/ipv6/netfilter/nf_conntrack_reasm.c)
struct l2tp_skb_cb (net/l2tp/l2tp_core.c) (less than full cb)
struct ah_skb_cb (net/ipv4/ah4.c)
struct ah_skb_cb (net/ipv6/ah6.c)
struct esp_skb_cb (net/ipv4/esp4.c)
struct esp_skb_cb (net/ipv6/esp6.c)
struct skb_eosp_msg_data (net/mac80211/ieee80211_i.h)
struct mISDNhead (include/linux/mISDNif.h)
struct ieee80211_ra_tid (net/mac80211/iface.c)
struct sctp_input_cb (net/sctp/input.c)

Checked:

struct unix_skb_parms (include/net/af_unix.h)
struct packet_skb_cb (net/packet/af_packet.c)
struct ovs_skb_cb (net/openvswitch/datapath.h)
struct ieee80211_tx_info (include/net/mac80211.h)
struct ieee80211_rx_status (include/net/mac80211.h)
struct tcp_skb_cb (include/net/tcp.h)
struct ieee802154_mac_cb (include/net/ieee802154_netdev.h)
struct netlink_cb_parms (include/linux/netlink.h)
struct inet6_skb_parm (include/linux/ipv6.h)
struct inet_skb_parm (include/net/ip.h)
struct tcp_skb_cb (include/net/tcp.h)
struct garp_skb_cb (include/net/garp.h)
struct dccp_skb_cb (net/dccp/dccp.h)
struct qdisc_skb_cb (include/net/sch_generic.h)

--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation




--=-q+vNcgrniY8ErKG3SUGT
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
MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTIxMjAyMjEyOTQxWjAjBgkqhkiG9w0BCQQx
FgQUYz5ePzG89PBH6mwjiQOCkCizvZUwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMC
SUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRp
ZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1l
ZGlhdGUgQ2xpZW50IENBAgMEJnowgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJ
TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlm
aWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVk
aWF0ZSBDbGllbnQgQ0ECAwQmejANBgkqhkiG9w0BAQEFAASCAQBWMxbbKdqNtwzsW3wclYGP8SDG
M8nmvQtdOICx76tNBSOzJBi5XhfWxbg6/Nx3aK/dJ4iim3NapSuhE83/KhQLduftQL17xBHLVA4U
5fnDcBweP+7Iivd9/xurYPfVzHHUviYoyphrZxDR+Y39vjvoPznrIGx4TjyPvHG24Q/FNr+R2Kxl
T2Giv94Lrl58EYDko+pDD/KOQDnNHw9ApPDLTWtUtNtfCD6qbBiOq1eNKg2XbWTyxcQxnlW2H101
yN1nKDcRheANL2HdllGubJRlmBAP1p2BFcrih3hM+EpnR+AKei+5OZ3pfcjIoiUa5ynFr5MPc+10
n55YapvNMu3dAAAAAAAA


--=-q+vNcgrniY8ErKG3SUGT--
