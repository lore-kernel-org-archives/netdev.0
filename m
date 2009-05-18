From: Koteswar - Pandu <koti.kelam@gmail.com>
Subject: proxy arp using "pub" flag
Date: Mon, 18 May 2009 12:11:22 +0530
Message-ID: <e4855a0905172341j1a1a5f7dw698d5eec56ae0056@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:49128 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbZERGlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 02:41:21 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1550052rvb.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2009 23:41:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
I am using linux-2.6.24 kernel. And I am trying to test proxy arp in
my linux box. My linux box is having 3 interfaces with ip addresses
192.168.100.254(eth0), 192.168.10.254(eth1), 192.168.20.254(eth3).
I added arp proxy entry on eth0 as

#arp -Ds 192.168.10.1 eth0 -i eth0 pub

so if i arping 192.168.10.1, eth0 will respond with it's MAC address.
But if I add an ip address which is in the same subnet of the same
interface then arping fails.

#arp -Ds 192.168.100.10 eth0 -i eth0 pub

then if I do arping 192.168.100.10, eth0 is NOT responding with its MAC.

But this is my requirement that interface should respond with arp
reply to any IP configured with "pub" flag. In kernel code
/linux-2.6.24/net/ipv4/arp.c I added following code at line 814 in
arp_process() unction.

if(arp->ar_op == htons(ARPOP_REQUEST))
    {
        n = pneigh_lookup(&arp_tbl, &tip, dev, 0);
        if(n){
            printk(KERN_DEBUG "n->flags::%x\n",n->flags);
            n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
            printk(KERN_ERR "Neighbour\n");
            if (n)
                neigh_release(n);
            printk(KERN_DEBUG "Neighbour release\n");
            arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
            printk(KERN_DEBUG "Arp sent\n");
            goto out;
        }
    }
So that it will check whether it ARP request and any entry is there in
the arp neibour table which maintains only published entries. Then
only send the ARP reply.
By this I can avoid checking route table for route entry for proxy arp
ip and checking input and output interfaces are same or not because
these are preventing sending arp reply for IPs which are in the subnet
of same interface and IPs which are not in the subnet of any
interface.
Is this correct way?? Does it effect any other functionality of networking??

Regards
Koteswar
