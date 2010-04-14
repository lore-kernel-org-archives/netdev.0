From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Wed, 14 Apr 2010 23:45:10 +0200
Message-ID: <4BC63766.5080104@gmail.com>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>	 <4BBE4BB4.1060209@gmail.com>	 <i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>	 <20100409212657.GA3560@del.dom.local> <p2q298f5c051004140322hc54f5315taa5c7d85cb74f06@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:34637 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757000Ab0DNVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 17:45:17 -0400
Received: by fg-out-1718.google.com with SMTP id 22so232920fge.1
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 14:45:15 -0700 (PDT)
In-Reply-To: <p2q298f5c051004140322hc54f5315taa5c7d85cb74f06@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Antonio Almeida wrote, On 04/14/2010 12:22 PM:

> What do you mean with "1:2 has grandchildren with overflown rate tables"?
> I couldn't understand your idea. Is there any mistake in the
> configuration I sent?
> How would you set rates for this particular example?


class htb 1:1 root rate 1000Mbit ceil 1000Mbit
class htb 1:2 parent 1:1 rate 4096Kbit ceil 4096Kbit
class htb 1:10 parent 1:2 rate 1024Kbit ceil 4096Kbit
class htb 1:11 parent 1:2 rate 1024Kbit ceil 4096Kbit
class htb 1:101 parent 1:10 prio 3 rate 8bit ceil 4096Kbit
class htb 1:111 parent 1:11 prio 3 rate 8bit ceil 4096Kbit

Classes 1:101 and 1:111 have too low rates, which causes wrong (overflowed!)
values in their rate tables, so their rates could be practically
uncontrollable. They are limited by their ceils instead, so something like:

class htb 1:101 parent 1:10 leaf 101: prio 3 rate 4096Kbit ceil 4096Kbit
class htb 1:111 parent 1:11 leaf 111: prio 3 rate 4096Kbit ceil 4096Kbit

But then their guaranteed rates are higher than their parents, and the
sum is higher than grandparent's rate, which means the config is wrong.
(You have to control these sums - HTB doesn't.)

As I wrote before, the minimal (overflow safe) rate depends on max
packet size, and for 1500 byte it would be something around:
1500b/2min, so if your clients can wait so long, try this:

class htb 1:101 parent 1:10 leaf 101: prio 3 rate 100bit ceil 4096Kbit
class htb 1:111 parent 1:11 leaf 111: prio 3 rate 100bit ceil 4096Kbit

Regards,
Jarek P.
