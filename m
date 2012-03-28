From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Tue, 27 Mar 2012 19:35:33 -0700
Message-ID: <m1sjgtmozu.fsf@fess.ebiederm.org>
References: <20120326222359.GB28123@dztty> <m1mx73rn7t.fsf@fess.ebiederm.org>
	<20120326232123.GB29626@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org
To: Djalal Harouni <tixxdz@opendz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out07.mta.xmission.com ([166.70.13.237]:53735 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757250Ab2C1Cb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:31:57 -0400
In-Reply-To: <20120326232123.GB29626@dztty> (Djalal Harouni's message of "Tue,
	27 Mar 2012 00:21:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Djalal Harouni <tixxdz@opendz.org> writes:

> On Mon, Mar 26, 2012 at 03:50:30PM -0700, Eric W. Biederman wrote:
>> Djalal Harouni <tixxdz@opendz.org> writes:
>> 
>> > I've been analysing some kmemleak reports of an internal module, and
>> > found that there are false positive reports of unreferenced objects.
>> >
>> > The following patch is just a clean up for one of those false positives,
>> > this is for the /proc/sys/net/ipv4 sysctl table.
>> > As I've said there are other reports but don't know if it is worth to
>> > write patches for them.
>> 
>> So the problem here is that you register a sysctl and don't keep a
>> pointer to the returned sysctl_header?  So kmemleak complains?
> Right.
>
>> I would expect the other sysctl data structures to have such a pointer,
>> so I don't know why kmemleak would complain.
>> 
>> Does my recent sysctl rewrite affect when this kmemleak is reported?
> Actually yes, after a recent pull (which includes your recent sysctl work),
> some of these false positive reports started to appear.
>
>
> Anyway they seem false positive ones, since keeping a reference to
> sysctl_header as in my previous (ugly) patch will quiet the last two
> ones.

Ok thanks. If that is what it is.  Then clean way to quite this will
ultimately be converting these table to be compatible with my brand
new register_sysctl() and using that to register them.

In fact I am pretty certain we can just do:
register_sysctl("net/ipv4/route", ipv4_route_table);
register_sysctl("net/ipv4/neigh", empty);

instead of:
register_sysctl_paths(ipv4_path, ipv4_skeleton);

And kill ipv4_skeleton and ipv4_path as they are now unused.

There was a tremendous cleanup and speed up that came with not allowing
sysctl tables to support .child entries in the core, and the older
registration routines break apart the tables and return a compatilibty
sysctl_table_header if we do that, and I believe we are just
leaking that compatibility sysctl_table_header.

Eric
