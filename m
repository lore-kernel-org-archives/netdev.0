From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: unintended ipv4 broadcast policy change
Date: Thu, 23 Jun 2011 17:01:37 -0400
Message-ID: <20110623170137.69054c83@s6510.ftrdhcpuser.net>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
	<20110623081614.213a432f@nehalam.ftrdhcpuser.net>
	<20110623.134504.1261579649197526589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53658 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759822Ab1FWVBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 17:01:31 -0400
In-Reply-To: <20110623.134504.1261579649197526589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 13:45:04 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 23 Jun 2011 08:16:14 -0700
> 
> > On Wed, 22 Jun 2011 16:39:35 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> But debian definitely still has this bug.  On debian, as a result,
> >> every packet received gets parsed.
> > 
> > Are you saying the DHCP client ends up parsing every packet?
> > This doesn't appear to be true.
> > 
> > I checked and the dhclient spends its life waiting on select for DHCP port.
> 
> Which dhcp client do you have installed?  There are about 6 or 7 of
> them available in debian.
> 
> Unless it closes the AF_PACKET socket after it gets a lease, it's
> going to get every packet.  Because it uses a type argument of
> "SOCK_PACKET" to the socket() call, the AF_PACKET layer will not use
> the packet filter it installs during receive processing.
> 
> Check the source if you don't believe me, maybe whatever repo you're
> using has different code in this area.

Standard Debian stable (Squeeze) installation.
$ dpkg -S /sbin/dhclient
isc-dhcp-client: /sbin/dhclient

$ dpkg -l isc-dhcp-client
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name           Version        Description
+++-==============-==============-============================================
ii  isc-dhcp-clien 4.1.1-P1-15+sq ISC DHCP client

If it did get every packet, I would see client wake up with strace and
doing work, that is not what it shows...

Maybe there is something else blocking it.

# lsof -p $(pgrep dhclient)
COMMAND   PID USER   FD   TYPE             DEVICE SIZE/OFF    NODE NAME
dhclient 1785 root  cwd    DIR                8,1     4096       2 /
dhclient 1785 root  rtd    DIR                8,1     4096       2 /
dhclient 1785 root  txt    REG                8,1   487696 3407973 /sbin/dhclient
dhclient 1785 root  mem    REG                8,1    47616  917512 /lib/libnss_files-2.11.2.so
dhclient 1785 root  mem    REG                8,1  1432968  917515 /lib/libc-2.11.2.so
dhclient 1785 root  mem    REG                8,1   128744  917527 /lib/ld-2.11.2.so
dhclient 1785 root    0u   CHR                1,3      0t0    2150 /dev/null
dhclient 1785 root    1u   CHR                1,3      0t0    2150 /dev/null
dhclient 1785 root    2u   CHR                1,3      0t0    2150 /dev/null
dhclient 1785 root    3u  unix 0xffff880129b4cf00      0t0    5308 socket
dhclient 1785 root    4r   REG                8,1     1569  536722 /var/lib/dhcp/dhclient-de7b6036-9282-4cec-83ea-ef32117a0c0d-eth0.lease
dhclient 1785 root    5w  pack               6212      0t0     ALL type=SOCK_PACKET
dhclient 1785 root    6u  IPv4               6214      0t0     UDP *:bootpc
