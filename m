From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Wed, 1 Jul 2009 12:00:26 +0300
Message-ID: <200907011200.26547.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907010154.27457.denys@visp.net.lb> <m1iqicyjmr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38217 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbZGAJAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 05:00:39 -0400
In-Reply-To: <m1iqicyjmr.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 July 2009 09:58:36 Eric W. Biederman wrote:
>
> What problem were you originally trying to solve?
>
> Having a proxy arp gateway reply to addresses it routes is proper
> behaviour.
>
> There are some aspects of RFC 5227 ipv4 address conflict detection that
> we could implement in a better fashion.  In particular the entirety
> of handling the pathological case of someone using one of our ip
> addresses in an arp message and replying to them to defend ourselves.
>
> Your changes seem aimed at having the linux kernel not reply to
> gratuitous arps, when according to our configuration the sender is
> misconfigured.  You seem to want linux not to defend itself in cases
> where it should.  Making us even less compliant with RFC 5227.
>
> Eric
It is still answering to gratuitous arp and handling the case!!!
But why patch was created, to NOT reply in case we have proxy_arp set, and we 
have default gateway. In this case, for example, Windows XP wont work at all 
in network where is Linux host with proxy_arp=1 installed. Because Linux will 
ALWAYS answer to arp requests.
Just only one case i miss (which is not defined in RFC by the way), that some 
software use this packet to update ARP tables on other hosts. And i sent 
patches for that. But imho they should use more legitimate ARP packets for 
that.

I did real testing even for my patch, and sure i sent patch only after that.

ip addr
.....
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:1e:8c:89:78:af brd ff:ff:ff:ff:ff:ff
    inet 10.0.1.21/29 brd 10.0.1.23 scope global eth0

I run windows vista (it sets correctly sip as 0.0.0.0)

home ipv4 # tcpdump -ni eth0
11:48:11.416790 ARP, Request who-has 10.0.1.21 tell 0.0.0.0, length 46
11:48:11.416797 ARP, Reply 10.0.1.21 is-at 00:1e:8c:89:78:af, length 28

2.6.30 vanilla (sure patch is there) handling case correctly.

The case i was trying to handle - proxy arp. Windows XP will be permanently 
disabled on reboot in case of proxy_arp enabled on Linux machine, and this 
Linux have default gateway (means answer to all proxy_arp).

This is XP (no conflict)
11:51:28.297633 ARP, Request who-has 10.0.0.5 tell 10.0.0.5, length 46
11:51:29.283672 ARP, Request who-has 10.0.0.5 tell 10.0.0.5, length 46
11:51:30.284210 ARP, Request who-has 10.0.0.5 tell 10.0.0.5, length 46

This is Linux 2.6.30 with patch applied, and Windows XP, handling correctly IP 
conflict.

11:53:10.440541 ARP, Request who-has 10.0.0.1 tell 10.0.0.1, length 46
11:53:10.440551 ARP, Reply 10.0.0.1 is-at b6:45:02:01:2b:b6, length 28
11:53:10.440796 ARP, Request who-has 10.0.0.1 tell 10.0.0.1, length 46
11:53:10.440799 ARP, Reply 10.0.0.1 is-at b6:45:02:01:2b:b6, length 28
11:53:10.466743 ARP, Request who-has 10.0.0.1 tell 10.0.0.1, length 46
11:53:10.466752 ARP, Reply 10.0.0.1 is-at b6:45:02:01:2b:b6, length 28
11:53:10.466976 ARP, Request who-has 10.0.0.1 tell 10.0.0.1, length 46
11:53:10.466979 ARP, Reply 10.0.0.1 is-at b6:45:02:01:2b:b6, length 28

So WITH patch ip conflict detection working.

And for sure it will work:

<------>if (sip == 0 || tip == sip) { // Yes, sip == tip
<------><------>if (arp->ar_op == htons(ARPOP_REQUEST) && // Yes it is request
<------><------>    inet_addr_type(net, tip) == RTN_LOCAL && // Yes this ip i 
have on my own host
<------><------>    !arp_ignore(in_dev, sip, tip)) // No i won't ignore this 
<------><------><------>arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
<------><------><------><------> dev->dev_addr, sha); // Send the host who 
sent gratuitous ip - that i am using it already.
<------><------>goto out;
<------>}

