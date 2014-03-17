From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 16:00:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DF5DA@AcuExch.aculab.com>
References: <20140314132834.GS21124@linux.vnet.ibm.com>
 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140314153810.GX21124@linux.vnet.ibm.com>
 <20140314185005.GA17041@linux.vnet.ibm.com>
 <20140314185917.GA18933@linux.vnet.ibm.com>
 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140317135101.GA8956@casper.infradead.org>
 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140317152852.GB8956@casper.infradead.org>
 <20140317155024.GD8956@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Thomas Graf' <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49743 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754459AbaCQQB0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 12:01:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24998-07 for <netdev@vger.kernel.org>;
 Mon, 17 Mar 2014 16:01:22 +0000 (GMT)
In-Reply-To: <20140317155024.GD8956@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf
> On 03/17/14 at 03:28pm, Thomas Graf wrote:
> > On 03/17/14 at 07:13am, Eric Dumazet wrote:
> > > On Mon, 2014-03-17 at 13:51 +0000, Thomas Graf wrote:
> > > > On 03/16/14 at 09:06am, Eric Dumazet wrote:
> > > > > From: Eric Dumazet <edumazet@google.com>
> > > > >
> > > > > In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
> > > > > classifier") Patrick added an u32 field in fw_head, making it slightly
> > > > > bigger than one page.
> > > > >
> > > > > Change the layout of this structure and let compiler emit a reciprocal
> > > > > divide for fw_hash(), as this makes the core more readable and
> > > > > more efficient those days.
> > > >
> > > > I think you  need to educate me a bit on this. objdump
> > > > spits out the following:
> > > >
> > > > static u32 fw_hash(u32 handle)
> > > > {
> > > >         return handle % HTSIZE;
> > > >   1d:   bf ff 01 00 00          mov    edi,0x1ff
> > > >   22:   89 f0                   mov    eax,esi
> > > >   24:   31 d2                   xor    edx,edx
> > > >   26:   f7 f7                   div    edi
> > > >
> > > > Doesn't look like a reciprocal div to me. Where did I
> > > > screw up or why doesn't gcc optimize it properly?
> > > > --
> > >
> > > Thats because on your cpu, gcc knows the divide is cheaper than anything
> > > else (a multiply followed by a shift)
> >
> > OK.
> 
> [0] lists 7-17 cycles for DIV r32 on Nehalem or 17-28 in terms of
> latency. Benefit of the data fitting into a single page clearly
> outweights this slight increase in instructions.

Actually the -Os forces the divide.
With -O3 the generated code I get for amd64 is a multiply by reciprocal
to get the quotient followed by an open coded multiply by 0x1ff and
then a subtract. 13 instructions, only a few of which are register renames
or are non-dependant.

	David
