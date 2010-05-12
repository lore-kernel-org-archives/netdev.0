From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Wed, 12 May 2010 11:17:06 -0700
Message-ID: <20100512111706.616dc7cf@nehalam>
References: <20100511172412.76aff184@nehalam>
	<1273684674.16074.0.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58994 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab0ELSRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 14:17:09 -0400
In-Reply-To: <1273684674.16074.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 May 2010 13:17:54 -0400
jamal <hadi@cyberus.ca> wrote:

> On Tue, 2010-05-11 at 17:24 -0700, Stephen Hemminger wrote:
> > If the user has a bad classification configuration, and gets a packet
> > that goes through too many steps.
> 
> Can you pass me the setup which caused this to be hit?
> 
> cheers,
> jamal


The Vyatta syntax is:

 traffic-limiter test-traffic-limit {
     class 2048 {
         bandwidth 1mbit
         burst 500kbit
         match onebox {
             ip {
                 destination {
                     address 192.168.100.99/32
                 }
             }
         }
     }
 }

Which generates these TC commands.

root@VC6:~# tc qdisc show dev eth0
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc ingress ffff: parent ffff:fff1 ---------------- 

root@VC6:~# tc filter show dev eth0 parent ffff:
filter protocol all pref 20 u32 
filter protocol all pref 20 u32 fh 800: ht divisor 1 
filter protocol all pref 20 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid ffff:800 
  match c0a86463/ffffffff at 16
 police 0x3 rate 1000Kbit burst 63999b mtu 2Kb action reclassify overhead 0b 
ref 1 bind 1


I think the bad part is the huge burst size.
