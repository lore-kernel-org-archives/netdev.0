From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "xfrm: Fix the gc threshold value for ipv4" broke my IPSec
 connections
Date: Tue, 15 Oct 2013 14:02:37 -0700
Message-ID: <1381870957.2045.73.camel@edumazet-glaptop.roam.corp.google.com>
References: <525DA855.1010905@daper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Damian Pietras <damianp@daper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43528 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759601Ab3JOVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 17:02:39 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so9323085pbb.19
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 14:02:39 -0700 (PDT)
In-Reply-To: <525DA855.1010905@daper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-15 at 22:40 +0200, Damian Pietras wrote:
> I've recently upgraded from 3.4.x to 3.10.x and this broke my IPSec
> setup in transport mode. The simplest test case is to setup few such
> connections with few boxes like this:
> 
> spdadd 192.168.1.100 192.168.2.100 any -P out ipsec
>            esp/transport//require
>            ah/transport//require;
> 
> spdadd 192.168.2.100 192.168.1.100 any -P in ipsec
>            esp/transport//require
>            ah/transport//require;
> 
> Then set up an HTTP server on one box and run ab on the other box to
> create come TCP connections:
> 
> ab -n 10000 -c 50 http://192.168.1.100/
> 
> Then the connect() call will very quickly start returning ENOBUFS. I
> haven't seen anything wrong with my simple setup (just copy of
> ipsec-howto.org in transport mode and pre shared keys) and started
> bisecting. That way I found this commit to break my case:
> 
> 703fb94ec58e0e8769380c2877a8a34aeb5b6c97
> xfrm: Fix the gc threshold value for ipv4
> 
> Reverting it on 3.10.15 fixes my issue. This seems to be there from 3.7
> and I don't really believe such simple case stayed broken for so long.
> Em I missing something or there is really a bug?
> 
> If smeone is interested in details of this configuration and commands
> I'm running, just let me know. This was reproduced with few VMs under XEN.
> 

It looks like you need to tune /proc/sys/net/ipv4/xfrm4_gc_thresh to a
sensible value given your workload.

try :

echo 65536 >/proc/sys/net/ipv4/xfrm4_gc_thresh

Presumably the 1024 default is really too small...
