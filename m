From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 17 Jun 2003 11:26:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF606435F1.792217CD-ON86256D48.00563525-86256D48.005A5AE4@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   I have a better suggestion for fix:

   1) Delete the "x->u.rt.fl = *fl;" line completely.

   2) Fix the test in __xfrm6_find_bundle() to do a proper
      prefix-mask based address comparison.

      rt6->rt6i_{dst,src} are masked addresses, so direct
      comparison is wrong.

   Can someone code this up?

It doesn't look like anyone worked on this yet, so now that I'm back I'm
starting to look at it.  In prep for coding this up I deleted the
"x->u.rt.fl = *fl;" line and then I noticed that (at least in my
configuration) that the rt6->rt6i_src address and prefix length in the
xfrm_dst structure are always zero.  It's hard to tell if this is what the
actual value should be or if it is just not getting initialized.  Doing a
ping from Machine 1 to Machine 3 and based on my configuration I would
expect to see a source address/prefix length of fec0::/64.  The
rt6->rt6i_dst address and prefix length are correct with fec0:0:0:2::/64.
Any ideas?  My IPSec configuration looks like this:

  Machine 1           Machine 2           Machine 3
  fec0:0:0:1::10
  fec0::1 ----------- fec0::2
                      fec0:0:0:2::10 ---- fec0:0:0:2::11

  Machine 1:
  spdadd fec0:0:0:0::/64 fec0:0:0:2::/64 -P out ipsec
         esp/tunnel/fec0::1-fec0::2/require;
  spdadd fec0:0:0:2::/64 fec0:0:0:0::/64 -P in  ipsec
         esp/tunnel/fec0::2-fec0::1/require;

  add fec0::1 fec0::2 ... (spi, algorithms and keys)
  add fec0::2 fec0::1 ... (spi, algorithms and keys)

  Machine 2:
  spdadd fec0:0:0:0::/64 fec0:0:0:2::/64 -P in  ipsec
         esp/tunnel/fec0::1-fec0::2/require;
  spdadd fec0:0:0:2::/64 fec0:0:0:0::/64 -P out ipsec
         esp/tunnel/fec0::2-fec0::1/require;

  add fec0::1 fec0::2 ... (spi, algorithms and keys)
  add fec0::2 fec0::1 ... (spi, algorithms and keys)

A netstat -rn --inet6 on Machine 1 yields:

Kernel IPv6 routing table
Destination                   Next Hop  Flags Metric Ref    Use Iface
::1/128                       ::        U     0      0        0 lo
fe80::/128                    ::        U     0      0        0 lo
fe80::201:3ff:fe33:5355/128   ::        U     0      0        0 lo
fe80::202:55ff:fe7c:79b6/128  ::        U     0      0        0 lo
fe80::202:55ff:fee4:5bb6/128  ::        U     0      0        0 lo
fe80::/64                     ::        UA    256    0        0 eth0
fe80::/64                     ::        UA    256    0        0 eth1
fe80::/64                     ::        UA    256    0        0 eth2
fec0::/128                    ::        U     0      0        0 lo
fec0::1/128                   ::        U     0      38       0 lo
fec0::2/128                   fec0::2   UAC   0      2055    2049 eth1
fec0::/64                     ::        UA    256    1        0 eth1
fec0:0:0:1::/128              ::        U     0      0        0 lo
fec0:0:0:1::10/128            ::        U     0      0        0 lo
fec0:0:0:1::/64               ::        UA    256    0        0 eth2
fec0:0:0:2::/64               fec0::2   UG    1      15       0 eth1
ff00::/8                      ::        UA    256    0        0 eth0
ff00::/8                      ::        UA    256    0        0 eth1
ff00::/8                      ::        UA    256    0        0 eth2

Thanks,
Tom
