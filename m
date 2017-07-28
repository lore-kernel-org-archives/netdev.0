From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Fri, 28 Jul 2017 10:07:57 +0200
Message-ID: <1501229277.2597.1.camel@redhat.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
         <1500905950.2458.6.camel@redhat.com>
         <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751045AbdG1IH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 04:07:59 -0400
In-Reply-To: <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2017-07-28 at 08:26 +0200, Marc Haber wrote:
> On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> > Once that a system enter the buggy status, do the packets reach the
> > relevant socket's queue?
> > 
> > ss -u
> > nstat |grep -e Udp -e Ip
> > 
> > will help checking that.
> 
> I now have the issue on one machine, a Xen guest acting as authoritative
> nameserver for my domains. Here are the outputs during normal use, with
> artificial queries coming in on eth0:
> 
> [9/1075]mh@impetus:~ $ ss -u
> Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> 0      0                                              127.0.0.1:56547                                                        127.0.0.1:domain               
> 0      0                                         216.231.132.60:27667                                                       198.41.0.4:domain               
> 0      0                                         216.231.132.60:44121                                                          8.8.8.8:domain               
> 0      0                                         216.231.132.60:29814                                                       198.41.0.4:domain               
> [10/1076]mh@impetus:~ $ ss -u
> Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> [11/1076]mh@impetus:~ $ ss -u
> Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> [12/1076]mh@impetus:~ $ ss -u
> Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> [13/1076]mh@impetus:~ $ ss -u
> Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> [14/1076]mh@impetus:~ $ nstat  | grep -e Udp -e Ip
> IpInReceives                    400688             0.0
> IpInAddrErrors                  18567              0.0
> IpInUnknownProtos               3                  0.0
> IpInDelivers                    330634             0.0
> IpOutRequests                   283637             0.0
> UdpInDatagrams                  145860             0.0
> UdpNoPorts                      1313               0.0
> UdpInErrors                     9356               0.0

Thanks for the info. This is compatible with what reported on:

https://bugzilla.kernel.org/show_bug.cgi?id=196469

and should be fixed by this patch:

http://marc.info/?l=linux-netdev&m=150115960024825&w=2

(approval pending)

Ad a workaround you can disable UDP early demux:

echo 0 > /proc/sys/net/ipv4/udp_early_demux

(will affect both ipv4 and ipv6).

and (if the system  is already into the bad state) increase the udp
accounted memory limit, writing in /proc/sys/net/ipv4/udp_mem greater
values than the current ones (the actual values depends on the system
total memory).

Feel free to test the above patch on your systems.

Cheers,

Paolo
