From: "Gerd v. Egidy" <lists@egidy.de>
Subject: xfrm by MARK: tcp problems when mark for in and
	out differ
Date: Wed, 13 Oct 2010 15:57:06 +0200
Message-ID: <201010131557.06588.lists@egidy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@lists.strongswan.org
To: jamal <hadi@cyberus.ca>
Return-path: <dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.strongswan.org>
List-Help: <mailto:dev-request@lists.strongswan.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=subscribe>
Sender: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
Errors-To: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
List-Id: netdev.vger.kernel.org

Hi,

I use current strongswan git to set up ipsec connections with the xfrm by MARK 
feature. When I configure xfrm policies with different marks for incoming and 
outgoing packets, incoming tcp connections can't be established anymore. The 
SYN-ACK packet is never sent through the tunnel.

An example policy looks like this:

src 192.168.5.0/24 dst 192.168.1.0/24
        dir out priority 1760
        mark 5/0xffffffff
        tmpl src 172.16.1.131 dst 172.16.1.130
                proto esp reqid 16384 mode tunnel
src 192.168.1.0/24 dst 192.168.5.0/24
        dir fwd priority 1760
        tmpl src 172.16.1.130 dst 172.16.1.131
                proto esp reqid 16384 mode tunnel
src 192.168.1.0/24 dst 192.168.5.0/24
        dir in priority 1760
        tmpl src 172.16.1.130 dst 172.16.1.131
                proto esp reqid 16384 mode tunnel

-> incoming packets are without mark, outgoing packets are marked with 5

I traced the packet in the xfrm code and found out that the problem is in the 
flow data. When the SYN-ACK hits __xfrm_lookup, the value in fl->mark is 0 
(more precisely: the mark value used in the incoming packet). This means that 
xfrm_policy_match will not match on the correct policy because the mark values 
differ.

I'm not too familiar with the kernel networking code. But I guess that the 
flow for the SYN-ACK is set up based on the data used for the SYN and is not 
updated when my iptables rule changes the mark of the packet:

iptables -t raw -A OUTPUT -s 192.168.5.0/255.255.255.0 -d 
192.168.1.0/255.255.255.0 -j MARK --set-mark 5

I guess that the flow data should be updated somewhere. But I don't know what 
the correct place for that code would be.

Can somebody more familiar with the network stack help me with this please?

Thank you very much.

Kind regards,

Gerd


-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
