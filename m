From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Problem with IPSEC tunnel mode
Date: Wed, 20 Apr 2005 17:37:50 +0200
Message-ID: <200504201737.51053.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

we have a problem with ipsec in tunnel mode (using kernel 2.6.11.7).

Scenario:

10.148.4.8/28 host A
    |
    |
10.148.4.1/28 router B
192.168.9.237/30
    |
  internet
    |
192.168.77.161/30 router C
10.148.15.9/30
    |
    |
10.148.15.10/30 router D
10.0.25.209/30
    |
    |
10.0.25.210/30 host E

There is an ipsec-tunnel between B and C to connect the subnet 10.148.4.0=
/28=20
with 10.0.25.210. When now A sends a packet to E (src=3D10.148.4.8,=20
dst=3D10.0.25.210), we see the following:

1. packet enters B
2. packet is tunneled to C
3. packet is received by C
4. it is decrypted, you can see the decrypted paket
   with tcpdump and it shows up in PREROUTING (mangle-table)
5. then it disappears (it is NOT dropped by iptables)
   especially it is not seen in FORWARD (mangle-table).

The route to E on C is a host route via 10.148.15.10.

The ipsec rules on C are:


src 10.148.4.0/28 dst 10.0.25.210/32
        dir in priority 2084
        tmpl    src 192.168.9.237 dst 192.168.77.161
                proto esp spi 0x00000000 reqid 16465 mode tunnel

src 10.148.4.0/28 dst 10.0.25.210/32
        dir out priority 0

src 10.148.4.0/28 dst 10.0.25.210/32
        dir fwd priority 2084
        tmpl    src 192.168.9.237 dst 192.168.77.161
                proto esp spi 0x00000000 reqid 16465 mode tunnel


If we connect 10.0.25.210 directly to C using a direct host route it does=
 not=20
work either.

If we connect 10.0.25.210 directly to C giving C 10.0.25.209/30 instead o=
f=20
10.148.15.9/30 it does not work, either (ipsec-rules are unchanged on C).

But if we further change the ipsec-rules on C to

src 10.148.4.0/28 dst 10.0.25.208/30
        dir in priority 2084
        tmpl    src 192.168.9.237 dst 192.168.77.161
                proto esp spi 0x00000000 reqid 16465 mode tunnel

src 10.148.4.0/28 dst 10.0.25.208/30
        dir out priority 0

src 10.148.4.0/28 dst 10.0.25.208/30
        dir fwd priority 2084
        tmpl    src 192.168.9.237 dst 192.168.77.161
                proto esp spi 0x00000000 reqid 16465 mode tunnel


(of course we change the corresponding rule on B, too) it works: the pack=
et is=20
not magically dropped.


Interestingly, the original scenario works fine when we use kernel 2.6.7-=
rc1=20
instead of 2.6.11.7 and setkey from ipsec-tools 0.3.3. In this case there=
 are=20
no fwd-rules at all as this old version of setkey does not create one.


Any help ist appreciated. Please CC: me as I'm not on the list.

Greetings,

Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen
