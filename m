From: Peter Bieringer <pb@bieringer.de>
Subject: IPv4 tunneled over IPv6-IPsec?
Date: Sat, 26 Mar 2005 21:22:22 +0100
Message-ID: <DD992FDA2A9E3512996A18A9@[192.168.17.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: dev@openswan.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I retry to play tunneling IPv4 over IPv6-IPsec. Afair it is still not 
working (support is missing in 2.6.x kernel), but for startup, I have 
already a patch for ipsec.conf parsing (pluto already has an option to do 
this):

--- /usr/lib/ipsec/_confread.2.3.0      2005-03-26 19:23:13.715148147 +0100
+++ /usr/lib/ipsec/_confread    2005-03-26 20:26:46.002583265 +0100
@@ -131,7 +131,7 @@
        }

        good = "also alsoflip type auto authby _plutodevel"
-       good = good " connaddrfamily forceencaps"
+       good = good " connaddrfamily forceencaps tunneladdrfamily"
        good = good " modecfgpull"
        left = " left leftsubnet leftnexthop leftupdown"
        akey = " keyexchange auth pfs keylife rekey rekeymargin rekeyfuzz"
--- /usr/libexec/ipsec/auto.2.3.0       2005-03-26 20:27:17.677451842 +0100
+++ /usr/libexec/ipsec/auto     2005-03-26 20:29:52.165532980 +0100
@@ -482,6 +482,14 @@
                 } else if (s["connaddrfamily"] != "ipv4") {
                         fail("unknown connaddrfamily value " 
s["connaddrfamily"
])
                 }
+                default("tunneladdrfamily", "ipv4")
+                if (s["tunneladdrfamily"] == "ipv4") {
+                        settings = settings " --tunnelipv4"
+                } else if (s["tunneladdrfamily"] == "ipv6") {
+                        settings = settings " --tunnelipv6"
+                } else {
+                        fail("unknown tunneladdrfamily value " 
s["tunneladdrfamily"])
+                }
                 # END IPv6

                if (s["ike"] != "")


With upper patch it's possible to use following config:

conn ipv6-muc-pbg-net
        connaddrfamily=ipv6
        tunneladdrfamily=ipv4
        left=3ffe:ffff:1:0::2
        leftsubnet=192.168.1.0/24
        right=3ffe:ffff:2:0::2
        rightsubnet=192.168.2.0/24
	...

setkey -P -D already shows something like that:

192.168.1.0/24[any] 192.168.2.0/24[any] any
        out prio high + 1073739480 ipsec
        esp/tunnel/1.2.3.4-1.2.3.4/unique#16389
        created: Mar 26 20:35:11 2005  lastused:
        lifetime: 0(s) validtime: 0(s)
        spid=217 seq=25 pid=10039
        refcnt=1

Note that here occurs the first problem, at least setkey doesn't understand 
that the IPv4 networks are tunneled via IPv6-IPsec.
"ip -6 xfrm policy" has the same problem

As a second problem, no packets will be encrypted proper, they are lost in 
the networking stack somewhere...

Kernel version I've used for tests: 2.6.10-1.770_FC3 (Fedora Core 3).

Is there any status available when or ever IPv4 over IPv6-IPsec will be 
supported or is it already supported and something is going wrong here?

Regards,
        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
