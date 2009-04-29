From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 16:15:51 +0300
Message-ID: <1241010951.6554.355.camel@blade.ines.ro>
References: <20090423082052.GA4243@ff.dom.local>
	 <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
	 <1241000494.6554.307.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
	 <1241003006.6554.322.camel@blade.ines.ro>
	 <20090429122312.GA2759@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>,
	Calin Velea <calin.velea@gemenii.ro>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:42248 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760805AbZD2NQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 09:16:05 -0400
In-Reply-To: <20090429122312.GA2759@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 14:23 +0200, Jarek Poplawski wrote:
> According to the author's(?) comment with hysteresis "The speed gain
> is about 1/6", so not very much here considering htb_dequeue time.

Thought so :)

> Radu, since not only your worst case, but also the real case u32
> lookups are very big I think you should mainly have a look at Calin's
> u32 hash generator or at least his method, and only after optimizing
> it try these other tricks. Btw. I hope Calin made this nice program
> known to networking/admins lists too.

I've just had a look at Calin's approach to optimizing u32 lookups. It
does indeed make a very nice use of u32 hash capabilities, resulting in
a maximum of 4 lookups. The algorithm he uses takes advantage of the
fact that only a (small) subset of the whole ipv4 address space is
actually used in an ISP's network.

Unfortunately his approach makes it a bit difficult to dynamically
adjust the configuration, since the controller (program/application)
must remember the exact hash tables, filters etc in order to be able to
add/remove CIDRs without rewriting the entire configuration. Unused hash
tables also need to be "garbage collected" and reused, otherwise the
hash table id space could be exhausted.

Since I only use IP lookups (and u32 is very generic) I'm starting to
ask myself if a different kind of data structures and classifier were
more appropriate.

For instance, I think a binary search tree that is matched against the
bits in the ip address would result in pretty nice performance. It would
take at most 32 iterations (descending through the tree) with less
overhead than the (complex) u32 rule match.

> Btw. #2: I think you wrote you didn't use iptables...
No, I don't use iptables.

Btw, the e1000e driver seems to have no way to disable NAPI. Am I
missing something (like a global kernel config option that disables NAPI
completely)?

Thanks,

Radu


