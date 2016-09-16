From: John Crispin <john@phrozen.org>
Subject: Re: MDB offloading of local ipv4 multicast groups
Date: Fri, 16 Sep 2016 08:22:51 +0200
Message-ID: <59895da9-341d-d428-af9a-5805aba26ba1@phrozen.org>
References: <ebb1092f-4fab-c490-0553-b108feb5e8d4@phrozen.org>
 <20160915204218.GA21035@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Elad Raz <eladr@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:35930 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751414AbcIPGXB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 02:23:01 -0400
In-Reply-To: <20160915204218.GA21035@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15/09/2016 22:42, Ido Schimmel wrote:
> On Thu, Sep 15, 2016 at 08:58:50PM +0200, John Crispin wrote:
>> Hi,
>>
>> While adding MDB support to the qca8k dsa driver I found that ipv4 mcast
>> groups don't always get propagated to the dsa driver. In my setup there
>> are 2 clients connected to the switch, both running a mdns client. The
>> .port_mdb_add() callback is properly called for 33:33:00:00:00:FB but
>> 01:00:5E:00:00:FB never got propagated to the dsa driver.
>>
>> The reason is that the call to ipv4_is_local_multicast() here [1] will
>> return true and the notifier is never called. Is this intentional or is
>> there something missing in the code ?
> 
> I believe this is based on RFC 4541:
> 
> "Packets with a destination IP (DIP) address in the 224.0.0.X range
> which are not IGMP must be forwarded on all ports."
> https://tools.ietf.org/html/rfc4541
> 
> But, we are missing the offloading of router ports, which is needed for
> the device to correctly flood unregistered multicast packets. That's
> also according to the mentioned RFC:
> 
> "If a switch receives an unregistered packet, it must forward that
> packet on all ports to which an IGMP router is attached."
> 
> Implemented at br_flood_multicast()
> 
> However, the marking is done per-port and not per-{port, VID}. We need
> that in case vlan filtering is enabled. I think Nik is working on that,
> but he can correct me if I'm wrong :). The switchdev bits can be added
> soon after.
> 

thanks for the explanation. i was not aware the the local groups should
always be flooded to all ports.

	John
