From: Bart De Schuymer <bdschuym@pandora.be>
Subject: the change from spinlock to rcu_read_lock in the bridge code
Date: Mon, 19 May 2003 21:46:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305192146.35133.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

The 2.5 bridge code now uses (as you ofcourse know) rcu_read_lock to protect a 
function's local data.
The use of a bridge r/w spinlock had the advantage that all netfilter modules 
registered on a bridge hook were guaranteed that the bridge ports wouldn't 
vanish while the code was executed.
If I understand things correctly, the del_nbp() function can now put the 
br_port member of a net_device on NULL any time while another processor is 
bridging a frame. If so, then all bridge netfilter modules will have to check 
on NULL and use smp_read_barrier_depends() when they want to read the struct 
net_bridge_port. For example, br_netfilter.c will need extra code to deal 
with this.

Also, what about this hypothetical situation: the user removes eth0 from br0 
and adds eth0 as a port of br1. If this is done fast enough, the same skb can 
have a different input bridge device on different times.

Is using rcu really that much faster in the bridge case, considering extra 
checking code will have to be added?

-- 
cheers,
Bart
