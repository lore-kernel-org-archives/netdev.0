From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Subject: Inconsistency in packet drop due to MTU (eth vs veth)
Date: Thu, 19 Jan 2017 17:41:23 +0100
Message-ID: <159b79aa979.e23be6a5186096.2767722456700391441@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Evan Jones" <ej@evanjones.ca>,
        "David S. Miller" <davem@davemloft.net>,
        "Cong Wang" <cwang@twopensource.com>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        "Vijay Pandurangan" <vijayp@vijayp.ca>,
        "linux-kernel" <linux-kernel@vger.kernel.org>
To: "netdev" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've noticed an inconsistency between how physical ethernet and veth handles mtu.

If I setup two physical interfaces (directly connected) with different mtu:s, only the size of the outgoing packets are limited by the mtu. But with veth a packet is dropped if the mtu of the receiving interface is smaller then the packet size. 

This seems inconsistent to me, but maybe there is a reason for it ? 

Can someone confirm if it's a deliberate inconsistency or just a side effect of using dev_forward_skb() ?

Example:

Using physical interfaces
=================
client> ip link set dev eth0 mtu 500
server> ip link set dev eth2 mtu 1500
server> ping -qc 2 -s 600 client
PING 135.15.35.74 (135.15.35.74) 1100(1128) bytes of data.
--- 135.15.35.74 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.818/0.864/0.910/0.046 ms

Using veth
=============
server> ip netns add clientns
server> ip link add name serverif  type veth peer name clientif
server> ip addr add 10.0.0.1/24 dev serverif
server> ip link set serverif mtu 1500 up
server> ip link set clientif up netns clientns
server> ip netns exec clientns ip link set clientif mtu 500
server> ip netns exec clientns ip addr add 10.0.0.74/24 dev clientif
server> ping -qc 2 -s 600 10.0.0.74
PING 10.0.0.74 (10.0.0.74) 600(628) bytes of data.
--- 10.0.0.74 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1008ms

/F
