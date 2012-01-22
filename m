From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: tc q_choke.c bug?
Date: Sun, 22 Jan 2012 14:53:18 -0800
Message-ID: <20120122145318.37f1aa43@nehalam.linuxnetplumber.net>
References: <20120121165951.GA13144@marmot>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38243 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306Ab2AVWxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 17:53:21 -0500
In-Reply-To: <20120121165951.GA13144@marmot>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Jan 2012 16:59:51 +0000
Alexander Clouter <alex@digriz.org.uk> wrote:

> Hi,
> 
> Sorry for contacting you directly, I'm not a member of the netdev 
> mailing list or anything.
> 
> Whilst trying to play with CHOKE I stumbled on a problem where I kept 
> getting "CHOKE: failed to calculate EWMA constant".
> 
> I kept looking at the numbers, manually evaluating tc_red_eval_ewma() 
> and found everything was fine with what I was trying to do.  The real 
> hint was that just using the same values for 
> 
> works:
> tc qdisc add dev ppp0 parent 200:38 handle 1038: red   limit 613496 min 25562 max 76687 avpkt 1500 burst 28 bandwidth 1227 probability 0.04 ecn
> 
> does not work:
> tc qdisc add dev ppp0 parent 200:38 handle 1038: choke limit 613496 min 25562 max 76687 avpkt 1500 burst 28 bandwidth 1227 probability 0.04 ecn
> 
> So I looked at how tc_red_eval_ewma() was being called and found the 
> problem:
> 
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob;f=tc/q_red.c;hb=HEAD#l128
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob;f=tc/q_choke.c;hb=HEAD#l132
> 
> For some reason qmin is passed in as actually qmin*avpkt for CHOKE.  
> This seems to have been a bug from when support for CHOKE was initially 
> committed.
> 
> Am I missing something?  The manpage implies I should be able to use 
> these schedulers interchangeably parameter wise?

The core of choke and RED are supposed to be similar, but RED computes
values by bytes, and choke counts packets.

The values you pass to choke are supposed to be packet (not byte counts).

Probably need man page update on this.
