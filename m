From: Steve Hill <steve@navaho.co.uk>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Mon, 15 Dec 2003 13:15:44 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312151304350.8670-200000@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-874190902-1071494144=:8670"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--8323328-874190902-1071494144=:8670
Content-Type: TEXT/PLAIN; charset=US-ASCII


With both conntrack and bridging turned on in the 2.6.0test11 kernel, 
sending fragmented packets over the bridge reveals a memory leak 
(specifically, forwarding packets from any interface to a bridge).  The 
memory that is leaking seems to be being allocated on line 299 on 
net/bridge/br_netfilter.c:

        if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
                return NF_DROP;

Only the first fragment gets freed later on.

The patch attached fixes the problem by freeing nf_bridge when the 
packets are defragmented, however I am sure this is not the right place 
to do this.  Where would the skb's for the fragments usually get freed?

Bart De Schuymer suggested that they should be freed in 
skbuff.c::skb_release_data(), but having looked at this it seems to do 
this already.  skb_release_data() calls skb_drop_fraglist(), which does 
kfree_skb() on each fragment, and kfree_skb calls nf_bridge_put correctly 
so this isn't the problem.

-- 

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...


--8323328-874190902-1071494144=:8670
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="bridge-memleak.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0312151315440.8670@sorbus2.navaho>
Content-Description: 
Content-Disposition: attachment; filename="bridge-memleak.patch"

ZGlmZiAtdXJOIGxpbnV4LTIuNi4wLXRlc3QxMS52YW5pbGxhL25ldC9pcHY0
L2lwX2ZyYWdtZW50LmMgbGludXgtMi42LjAtdGVzdDExL25ldC9pcHY0L2lw
X2ZyYWdtZW50LmMNCi0tLSBsaW51eC0yLjYuMC10ZXN0MTEudmFuaWxsYS9u
ZXQvaXB2NC9pcF9mcmFnbWVudC5jCTIwMDMtMTItMTIgMTk6Mjc6MDcuMDAw
MDAwMDAwICswMDAwDQorKysgbGludXgtMi42LjAtdGVzdDExL25ldC9pcHY0
L2lwX2ZyYWdtZW50LmMJMjAwMy0xMi0xNSAwODo0OTowMS4wMDAwMDAwMDAg
KzAwMDANCkBAIC01OTIsNiArNTkyLDkgQEANCiAJYXRvbWljX3N1YihoZWFk
LT50cnVlc2l6ZSwgJmlwX2ZyYWdfbWVtKTsNCiANCiAJZm9yIChmcD1oZWFk
LT5uZXh0OyBmcDsgZnAgPSBmcC0+bmV4dCkgew0KKyNpZmRlZiBDT05GSUdf
QlJJREdFX05FVEZJTFRFUg0KKwkJbmZfYnJpZGdlX3B1dChmcC0+bmZfYnJp
ZGdlKTsNCisjZW5kaWYNCiAJCWhlYWQtPmRhdGFfbGVuICs9IGZwLT5sZW47
DQogCQloZWFkLT5sZW4gKz0gZnAtPmxlbjsNCiAJCWlmIChoZWFkLT5pcF9z
dW1tZWQgIT0gZnAtPmlwX3N1bW1lZCkNCg==
--8323328-874190902-1071494144=:8670--
