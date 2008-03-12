From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 3/8] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Wed, 12 Mar 2008 17:27:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803121711400.24534@kivilampi-30.cs.helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <Pine.LNX.4.64.0802201651580.26109@fbirervta.pbzchgretzou.qr>
 <47BC54FB.2050508@trash.net> <Pine.LNX.4.64.0802201730240.26109@fbirervta.pbzchgretzou.qr>
 <Pine.LNX.4.64.0802202135080.32171@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-652228311-1205335636=:24534"
Cc: Patrick McHardy <kaber@trash.net>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38701 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbYCLP1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 11:27:19 -0400
In-Reply-To: <Pine.LNX.4.64.0802202135080.32171@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-652228311-1205335636=:24534
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 21 Feb 2008, Ilpo Järvinen wrote:

> On Wed, 20 Feb 2008, Jan Engelhardt wrote:
> 
> > On Feb 20 2008 17:27, Patrick McHardy wrote:
> >
> > > __dev_alloc_skb() is also an inline function which performs
> > > some extra work. Which raises the question - if dev_alloc_skb()
> >
> > I'd like to see the results when {__dev_alloc_skb is externed
> > and dev_alloc_skb remains inlined}.
> 
> The results are right under your nose already... ;-)
> See from the list of the series introduction:
> 
>   http://marc.info/?l=linux-netdev&m=120351526210711&w=2
> 
> IMHO more interesting number (which I currently don't have) is the 
> _remaining_ benefits of uninlining __dev_alloc_skb after
> dev_alloc_skb was first uninlined.

I've measured this now... Without many debug CONFIGs (in v2.6.25-rc2-mm1), 
the dev_alloc_skb is much less than 23kB:

    382 funcs, 157 +, 12335 -, diff: -12178 --- dev_alloc_skb
    dev_alloc_skb                 |  +37

...and on top of that, I got only this:
    48 funcs, 111 +, 836 -, diff: -725 --- __dev_alloc_skb

Not that impressive compared with many much worse cases (wasn't a big 
surprise because there were fewer callsites for the latter).

Anyway, would I uninline it (or one some another function that has such 
two variants that are good candidates for uninlining), should I try to 
avoid deepening the call-chain by two functions? To me it seems that only 
way to fool gcc to do that for sure would be using some trick like this:
Rename __dev_alloc_skb to ___dev_alloc_skb in the header (with appropriate
don't ever call this due to bloat comment added) and both __dev_alloc_skb 
and dev_alloc_skb could then be made to call that one in .c file. 
Otherwise I'm not that sure gcc wouldn't try to be too clever if I just 
use inline in .c file.

-- 
 i.
---696243703-652228311-1205335636=:24534--
