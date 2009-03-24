From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Tue, 24 Mar 2009 09:22:24 +0100
Message-ID: <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:48998 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755432AbZCXIWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 04:22:30 -0400
In-Reply-To: <49C7CB9B.1040409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 18:49:15:
> 
> Joakim Tjernlund wrote:
> > Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:29:33:
> >
> > 
> >>> There is no /proc/net/netfilter/nf_conntrack. There is a
> >>> /proc/net/nf_conntrack though and it is empty. If I telnet
> >>> to the board I see:
> >>> 
> >> That means that something is leaking conntrack references, most 
likely
> >> by leaking skbs. Since I haven't seen any other reports, my guess 
would
> >> be the ucc_geth driver.
> >> 
> >
> > Mucking around with the ucc_geth driver I found that if I:
> >  - Move TX from IRQ to NAPI context
> >  - double the weight.
> >  - after booting up, wait a few mins until the JFFS2 GC kernel thread 
has 
> > stopped
> >    scanning the FS 
> >
> > Then the "nf_conntrack: table full, dropping packet." msgs stops.
> > Does this seem right to you guys?
> 
> No. As I said, something seems to be leaking packets. You should be
> able to confirm that by checking the sk_buff slabs in /proc/slabinfo.
> If that *doesn't* show any signs of a leak, please run "conntrack -E"
> to capture the conntrack events before the "table full" message
> appears and post the output.

skbuff does not differ much, but others do

Before ping:
  skbuff_fclone_cache    0      0    352   11    1 : tunables   54   27 0 
: slabdata      0      0      0
  skbuff_head_cache     20     20    192   20    1 : tunables  120   60 0 
: slabdata      1      1      0
  size-64              731    767     64   59    1 : tunables  120   60 0 
: slabdata     13     13      0
  nf_conntrack          10     19    208   19    1 : tunables  120   60 0 
: slabdata      1      1      0

During ping: 
  skbuff_fclone_cache    0      0    352   11    1 : tunables   54   27 0 
: slabdata      0      0      0
  skbuff_head_cache     40     40    192   20    1 : tunables  120   60 0 
: slabdata      2      2      0
  size-64             8909   8909     64   59    1 : tunables  120   60 0 
: slabdata    151    151      0
  nf_conntrack        5111   5111    208   19    1 : tunables  120   60 0 
: slabdata    269    269      0

This feels more like the freeing of conntrack objects are delayed and 
builds up when ping flooding.

Don't have "conntrack -E" for my embedded board so that will have to wait 
a bit longer.

 Jocke
