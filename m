From: bert hubert <ahu@ds9a.nl>
Subject: ip6sec MTU/fragmentation issue / Was: Re: [PATCH] Fix ip6_build_xmit bug
Date: Sat, 22 Mar 2003 20:26:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030322192604.GA3011@outpost.ds9a.nl>
References: <3E7BAC7E.AEC59251@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Grimm <jgrimm2@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <3E7BAC7E.AEC59251@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 21, 2003 at 06:21:18PM -0600, Jon Grimm wrote:
> Wanting to play a bit with v6 fragmentation I started using ping6 to
> send various message sizes.  Noticed that messages of sizes just under
> where fragmentation would kick in, segfaulted in ip6_build_xmit().

Thanks, this fixes an observed issue here with segfaults in ping6, as you
described. I run 2.5.65.

There is another problem with ip6sec however where fragmentation fails.
Setting up an ip6sec connection and then sending bulk data freezes up a
connection. 

ping6 -s 1500 deef.ds9a.nl -n leads to:

20:16:18.125073 2001:888:1036:0:2a0:ccff:fec8:f25c >
2001:888:1036:0:2e0:18ff:fe23:cece: AH(spi=0x00003d54,sumlen=16,seq=0xbe):
ESP(spi=0x00003d55,seq=0xbe) (len 1504, hlim 64)

20:16:18.125129 2001:888:1036:0:2a0:ccff:fec8:f25c >
2001:888:1036:0:2e0:18ff:fe23:cece: AH(spi=0x00003d54,sumlen=16,seq=0xbf):
ESP(spi=0x00003d55,seq=0xbf) (len 112, hlim 64)

and a reply:

20:16:18.125474 2001:888:1036:0:2e0:18ff:fe23:cece >
2001:888:1036:0:2a0:ccff:fec8:f25c: AH(spi=0x00005fb4,sumlen=16,seq=0x82):
ESP(spi=0x00005fb5,seq=0x82) [hlim 0] (len 160)

The reply appears to be a bit short and is possibly an ICMP error. When I
configure ip6sec only in one way, I get this reply to fragmented ICMP echo
requests:

20:22:24.445157 2001:888:1036:0:2e0:18ff:fe23:cece >
2001:888:1036:0:2a0:ccff:fec8:f25c: icmp6: parameter problem next header -
octet 6 (len 116, hlim 64)

This is probably the same packet as we see encrypted above.

Working ping6, -s 1400, looks like this:

20:18:56.820699 2001:888:1036:0:2a0:ccff:fec8:f25c >
2001:888:1036:0:2e0:18ff:fe23:cece: AH(spi=0x00003d54,sumlen=16,seq=0x142):
ESP(spi=0x00003d55,seq=0x142) (len 1456, hlim 64)

20:18:56.821912 2001:888:1036:0:2e0:18ff:fe23:cece >
2001:888:1036:0:2a0:ccff:fec8:f25c: AH(spi=0x00005fb4,sumlen=16,seq=0xce):
ESP(spi=0x00005fb5,seq=0xce) [hlim 0] (len 1456)

Both of these hosts have your patch applied. So it seems that ip6sec
fragmentation has some issues.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
