From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 kills IPMI on 82541GI (Dell PE1425SC) + small 2.6.27
 regression
Date: Fri, 31 Oct 2008 10:09:28 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A0D2A5710@orsmsx507.amr.corp.intel.com>
References: <alpine.LNX.1.10.0810311012160.12764@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=SHA1;
	protocol="application/x-pkcs7-signature";
	boundary="----=_NextPart_000_0004_01C93B40.C2424B00"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Graham, David" <david.graham@intel.com>
To: Krzysztof Oledzki <ole@ans.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46674 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbYJaRJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 13:09:55 -0400
In-Reply-To: <alpine.LNX.1.10.0810311012160.12764@bizon.gios.gov.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0004_01C93B40.C2424B00
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

<modified the mail list a bit>

Krzysztof Oledzki wrote:
> I have started implementing IPMI on my servers and there is some
> inconvenience with e1000+82541GI (Dell PE1425SC).

ugh, sorry to hear about that.
 
> With older kernels IPMI works if there are no vlans attached to
> primary interface. Adding vlans breaks it as e1000 driver enables
> VLAN filter and it somehow interferences with IPMI.
> 
> (no vlans):
> # ethtool -d eth0|grep -i vlan
>        VLAN mode:                         disabled
>        VLAN filter:                       disabled
> 
> (vlans):
> # ethtool -d eth0|grep -i vlan
>        VLAN mode:                         enabled
>        VLAN filter:                       enabled

vlan enable does a couple of things, it mostly just allows the device to

strip the vlan tag (that matches our vlan table in hardware) from
incoming 
packets and put it in the rx descriptor. This modifies the original 
packet as the vlan is stripped.  
 
> However, I found that using a workaround by adding the IPMI vlan to
> the OS restores the functionality. Very ugly but works.

interesting, this is whith the older <= 2.6.26 kernel right?
 
> So, it is OK with no-vlan-enabled hosts and with vlan-enabled with the
> above workaround, but still - it is a ugly workaround: IPMI is
> non-functional until OS *properly* initializes network configuration,
> which may never happen.

yeah that's pretty ugly, and not acceptable if you're trying to use
IPMI.
 
> Everything becomes much more complicated with more recent kernels
> (2.6.27 for example), where vlan filter is now enabled
> unconditionally and I have to add the dummy IPMI vlan also on
> no-vlan-enabled hosts to make it working. That makes it really
> confusing. 

yeah, that's a not so good regression due to unconditionally turning on
VLAN hardware offload.
 
> So, is it possible to fix this? For example to change the driver to
> read IPMI vlan id and add it to vlan filter regardless of current OS
> configuration? Or maybe it is possible to prevent IPMI from
> interferencing with the current driver's state?

It might be possible to fix this.  The hardware doesn't *have* to 
support VLAN offload in hardware.  This would essentially leave all
packets
unmodified as they arrive.  We will definitely look

So, do you intend that IPMI traffic should be on its own vlan?  Would
this kind of configuration work?  What if the IPMI traffic was *not* on
a vlan
but you had vlans enabled in your network?

Let me summarize, please correct me if I'm wrong:
0) you want to run IPMI traffic on its own VLAN
1) 2.6.26 kernel with vlan enabled IPMI breaks doesn't work until driver
is loaded?
2) 2.6.27 kernel (which enables vlan stripping) breaks IPMI vlan traffic
until "dummy"
   vlan is added with driver (on non-vlan hosts)

I'm feeling a bit confused at this point, can you please describe what
you want to do
with both the host and the ipmi config?

I'll have our lab see if they can reproduce this, I'm not even sure how
many others have
tried IPMI over VLAN.

------=_NextPart_000_0004_01C93B40.C2424B00
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIXMTCCAyAw
ggKJoAMCAQICBDXe9M8wDQYJKoZIhvcNAQEFBQAwTjELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0Vx
dWlmYXgxLTArBgNVBAsTJEVxdWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw05
ODA4MjIxNjQxNTFaFw0xODA4MjIxNjQxNTFaME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVp
ZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMFdsVhnCGLuoJotHwhtkRRomAoe/toEbxOEYiHD0XzOnwXg
uAHwTjTs4oqVBGSs8WtTXwWzy2eAv0ICjv7dAQns4QAUT/z78AzdQ7pbK+EfgHCZFVeTFvEPl2q3
wmgjHMxNWTCsUR47ryvW7mNFe8XZX1DS41APOojnvxT94Me5AgMBAAGjggEJMIIBBTBwBgNVHR8E
aTBnMGWgY6BhpF8wXTELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0VxdWlmYXgxLTArBgNVBAsTJEVx
dWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTENMAsGA1UEAxMEQ1JMMTAaBgNVHRAE
EzARgQ8yMDE4MDgyMjE2NDE1MVowCwYDVR0PBAQDAgEGMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fY
IyAQTzOYkJ/UMB0GA1UdDgQWBBRI5mj5K9KylddH2CMgEE8zmJCf1DAMBgNVHRMEBTADAQH/MBoG
CSqGSIb2fQdBAAQNMAsbBVYzLjBjAwIGwDANBgkqhkiG9w0BAQUFAAOBgQBYzinq/Pfetc4CuRe1
hdG54+CVzCUxDQCmkm5/tpJjnlCV0Zpv5BHeY4VumO6o/1rI01WyZnFX3sAh6z0qpyNJAQSGQnv8
7n+iFlK1Z2fTQNs7JliyKHc9rhR3Ydb6KmYnoA36p3Nc6nDxlCFlRF/6/O8paKmih3nvee9PrAd3
ODCCAz0wggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UE
ChMHRXF1aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
MB4XDTA2MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kg
Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATD
IsV2xDyt30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUj
ZzTZFq2N4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZv
uSQ0E11yYL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4
lz36wOdNZn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+
iC1HawJdAgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0
Vgaj7TdUDDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3Nl
Y3VyZWNhLmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69
tOkIP4SgDJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3j
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFYzCCBEugAwIBAgIKYSyUiQAA
AAAABTANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wNjAzMjIy
MjIyNDJaFw0xMjAzMjIyMjMyNDJaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKvXqH/ah10uJc7YzQUh+XEDNqS6IsXOyqCtizr9
x6F+v6iRAbvddRRJRWixfV78qarSN9WMymJ90M8c9/Dfr1yzFuq95RgCAF3vdve3wKi7kJv6lkMJ
wyyB+uIYcWtljYx2LDqbb9S6Z6He3q8W/aGKvu23I9ksNx+cmZcDNZwGdXVIEHpEMyA4bp0RvYtf
p8BsGAyn6YuK63HugeyYdeFL+4+Wz2tGUqw9OWhob6oV1oDH3zboLhHJiQ2oIj3jAJ3/LrIkzcWP
2R20UIliDAPAAl6MNWJPdsNK5EEeuxEuUSpdFsMj5rBmPHH4U8i8rUmi6GEOcX5rwAw64AzS3gEC
AwEAAaOCAjUwggIxMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAlpgTN7BnOPI0wKA9/3FoER
ghMFMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
AEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGs
oIGphk5odHRwOi8vd3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBQb2xpY3klMjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29t
L3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNy
bDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUy
MENBLmNydDBsBggrBgEFBQcwAoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3Np
dG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0Eu
Y3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCuNCnecJ+vDpXzsHOzMEyz4KgTNDbJROHag8H/ZVga7soc
oJyC+HKqDfQgxifVorbTbSajCBEAxqg6bbNWBJ6qKOFHneBrXkENf5WdD50eCTCFWRV3EIsHEOQ1
kP0eNYV5Ed4hp9y6wASV6z2z86O4+qouLJiow4AIhoCKD8rEyD7ODgTvjvLCKpsVyPlG1jOVSsOS
IF2VUmueAmK3RFU4np83zerK/j0G37owhniEDT6ZhwkUd0XL45nt1m7yApMEbnXUTHNaXnE+P98k
k3nDXdW25sB+5xWcYR3GpgMdQiZgP/f0KZ+yZKNE7gcp3I/O4pXqUNWIsLSYTi3soAR2MIIFizCC
BHOgAwIBAgIKTys7CwAAAAAWqTANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UE
ChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vp
bmcgQ0EgM0EwHhcNMDcwODA3MDAyMzE2WhcNMTAwODA2MDAyMzE2WjBHMRowGAYDVQQDExFCcmFu
ZGVidXJnLCBKZXNzZTEpMCcGCSqGSIb3DQEJARYaamVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20w
gZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALVYgP1o+Y7nwm5Lr6GerkzP9QweQWF7Ban1beaZ
Etba5ALpVHObkA/1pXF8sE/iJnu4CxUAxAmVArSVNHWFJDdS/rR43JOvekwVIKEo4a9JABCXF+rt
K/1ImEN+RDLfl/0Wd73CRfOvRtTSlg+pUqVyCtL9B3X1bzY+OPxicYahAgMBAAGjggLsMIIC6DAL
BgNVHQ8EBAMCB4AwHQYDVR0OBBYEFKqZruraVjeOWvjg3XEwVS5Kkvn0MDwGCSsGAQQBgjcVBwQv
MC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQMwHwYDVR0jBBgw
FoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCBtYZUaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNz
dWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9yZXBvc2l0
b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQS5jcmww
ge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3LmludGVsLmNvbS9yZXBv
c2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3
FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwUQYDVR0RBEowSKAqBgorBgEEAYI3FAID
oBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVidXJnQGludGVsLmNv
bTANBgkqhkiG9w0BAQUFAAOCAQEAJL8raLZYyz2imhvIrmSaQNhCOEzTwIXqxhlMbnPpeZUKlUym
6Tg7VaGXsqSyNQRe2eOK3gv2Et1O1ZsJwRGLC9mzKug8xeE5doO7HbbO04C8bR4B7jID2xByDJsT
f99mrprSwng4brFaW9JiSbCQyxmmApPoVXEff3lUqphiotdebDeV8y8a+s/yJCviLUinLbs4Uowf
/SXu6k+b27ue/I/QmWq01CF9wT/QMPyyAkIR+62XCGjGAZJIfsoZzCtab9/ujU7B0d7wV1Tq/koX
L21E3rOyAZ6I+7jpV0HDqY9KjPdLQu2tQ7I1u6iPORDH29STos5g/xv48jMK+RemBTCCBdIwggS6
oAMCAQICCk82OTAAAAAAFqowDQYJKoZIhvcNAQEFBQAwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5n
IENBIDNBMB4XDTA3MDgwNzAwMzUxM1oXDTEwMDgwNjAwMzUxM1owRzEaMBgGA1UEAxMRQnJhbmRl
YnVyZywgSmVzc2UxKTAnBgkqhkiG9w0BCQEWGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tMIGf
MA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDi2zY1Qs4T/t3n7P8HqwPt42qNN+oSkatx6IEcMpQ3
F0gPolrDmw2NqF4cC77He10MCA5vCd4dyL0wPDKguH0wcntGCaYVf4EitdnTl+TGPkuAoRaUZAhc
NjmPrL2pH8HtJf/ANHQPtVuCUnPbUl12c9HPOqvVWSdXniNBUVCM9QIDAQABo4IDMzCCAy8wCwYD
VR0PBAQDAgQwMEQGCSqGSIb3DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIA
gDAHBgUrDgMCBzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQUvdfuEHaw1+wbTNraFaClPaDVErUwPQYJ
KwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlnhLnZQYeE/04CAWQC
AQcwHwYDVR0jBBgwFoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCB
tYZUaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUy
MEJhc2ljJTIwSXNzdWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVs
LmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcmwwge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMl
MjBJc3N1aW5nJTIwQ0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMu
aW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNp
YyUyMElzc3VpbmclMjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoD
BDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwQwUQYDVR0RBEowSKAq
BgorBgEEAYI3FAIDoBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVi
dXJnQGludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAWZ7lU8JqwDbBes8ezVkGWmY91zVg87Bi
0Qxh0u9J5fIF+8KZ6tt7GX3Q8GRj0bZnX4hzFk6+wxT+25hXUb7c0ZmEIMbr8LYvOWXHghvjQja1
mkIC2eArcr42E8Bwy3BcwF+0K38UsqAkmlBzDOEf/lleIjgEamarv94UvjwFNsK6/sRCVSgOIU1T
8QeeCx0Y7Roaqjwt+66CwpIT6upnfJdSfplPXeYqatHfvAb+6evOB2EG37ejQmWEN5co8dfXD+1L
kkqlNn2YZfj4SGJeYHq0s/EmDPHzyrZohSoPgZJape03LRR7JUUtesB9nNtBuCnzMfWQw/tfL3of
ae/0MDGCAsAwggK8AgEBMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0
aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPKzsLAAAA
ABapMAkGBSsOAwIaBQCgggGyMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTA4MTAzMTE3MDkyN1owIwYJKoZIhvcNAQkEMRYEFPdibYLqgl4M/gNHAt4aIifnZj2JMGcG
CSqGSIb3DQEJDzFaMFgwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMAcGBSsOAwIaMAoGCCqGSIb3DQIFMHMGCSsGAQQBgjcQ
BDFmMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQD
EyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPNjkwAAAAABaqMHUGCyqGSIb3
DQEJEAILMWagZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECCk82OTAAAAAAFqowDQYJ
KoZIhvcNAQEBBQAEgYCwPqnlJZwmgckE2IV2EVi2hOZa3UCTTs7GlXN7XGP4/Gjsz641plRbBe7V
4HoV+Z72HoaD4hl5Fh/3vgDVpGnhCsMc36HDT0tywau9ARoHtm3cZJ1vsOlqZgbsXZeMeS55PZid
T8hG9ys+1t8F/Lp0q+i/XxW1jl0uAbtnk+4bAgAAAAAAAA==

------=_NextPart_000_0004_01C93B40.C2424B00--
