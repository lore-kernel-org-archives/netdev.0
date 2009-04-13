From: Alex Sidorenko <asid@hp.com>
Subject: An inconsistency/bug in ingress netem timestamps
Date: Mon, 13 Apr 2009 15:50:37 -0400
Message-ID: <200904131550.37208.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:42532 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbZDMTui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 15:50:38 -0400
Received: from g5t0034.atlanta.hp.com (l3107tux.atl.hp.com [15.195.192.24])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id EA492380D3
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 19:50:37 +0000 (UTC)
Received: from [16.212.6.13] (unknown [16.212.6.13])
	by g5t0034.atlanta.hp.com (Postfix) with ESMTP id 8E9925412F
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 19:50:37 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

while experimenting with 'netem' we have found some strange behaviour. It 
seemed that ingress delay as measured by 'ping' command shows up on some 
hosts but not on others.

After some investigation I have found that the problem is that skbuff->tstamp 
field value depends on whether there are any packet sniffers enabled. That 
is:

- if any ptype_all handler is registered, the tstamp field is as expected
- if there are no ptype_all handlers, the tstamp field does not show the delay

I was able to see the problem on RHEL5 (2.6.18 kernel) and Ubuntu/Jaunty 
(2.6.28 kernel).

Duplication
-----------

1. Enable ingress delay, e.g. 100ms

# modprobe ifb
# ip link set dev ifb0 up
# tc qdisc add dev eth0 ingress
# tc filter add dev eth0 parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
   redirect dev ifb0
# tc qdisc add dev ifb0 root netem delay 100ms

2. Check that there are no ptype_all handlers registered (stop DHCP, tcpdump, 
vmware etc.)

3. ping any other host on the LAN, e.g.
{asid 14:54:24} ping cats
PING cats (192.168.0.33) 56(84) bytes of data.
64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=0.258 ms
                                                     ^^^^^^^^^^^^^
Now start tcpdump on any interface (not necessarily eth0)

{asid 15:25:45} ping cats
PING cats (192.168.0.33) 56(84) bytes of data.
64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=100 ms
                                                     ^^^^^^^^^^^

The ingress packets are really delayed as can be seen from 'ping -U', even 
without tcpdump running:

{asid 15:26:12} ping -U cats
PING cats (192.168.0.33) 56(84) bytes of data.
64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=100 ms
                                                     ^^^^^^^^^^^

The problem is that modern 'ping' uses SO_TIMESTAMP facility and for some 
reason skb->tstamp is not updated. I was able to verify this with stap script 
(printing skb->tstamp.tv64 in several places).

The strange thing is that as soon as there is any ptype_all handler installed, 
skb->tstamp is updated properly. Unfortunately, my knowledge of TC internals 
is not good enough to find how exactly this happens. There are some comments 
in handle_ing()

	if (*pt_prev) {
		*ret = deliver_skb(skb, *pt_prev, orig_dev);
		*pt_prev = NULL;
	} else {
		/* Huh? Why does turning on AF_PACKET affect this? */
		skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
	}

but looking at all the places where OK2MUNGE bit is used I don't see how this 
could change the behaviour.

Even though it's a minor issue (after all, the packets are delayed 
and 'ping -U' shows it), it would be nice to have a consistent behaviour 
between cases when there are ptype_all handlers and when there are none.

Regards,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux			Hewlett-Packard (Canada)
------------------------------------------------------------------
