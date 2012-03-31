From: Djalal Harouni <tixxdz@opendz.org>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Sat, 31 Mar 2012 15:25:39 +0100
Message-ID: <20120331142539.GC29626@dztty>
References: <20120326222359.GB28123@dztty>
 <m1mx73rn7t.fsf@fess.ebiederm.org>
 <20120326232123.GB29626@dztty>
 <m1sjgtmozu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numidia.opendz.org ([98.142.220.152]:45773 "EHLO
	numidia.opendz.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757472Ab2CaOWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 10:22:11 -0400
Content-Disposition: inline
In-Reply-To: <m1sjgtmozu.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 07:35:33PM -0700, Eric W. Biederman wrote:
> Djalal Harouni <tixxdz@opendz.org> writes:
> 
> > On Mon, Mar 26, 2012 at 03:50:30PM -0700, Eric W. Biederman wrote:
[...]
> > Anyway they seem false positive ones, since keeping a reference to
> > sysctl_header as in my previous (ugly) patch will quiet the last two
> > ones.
> 
> Ok thanks. If that is what it is.  Then clean way to quite this will
> ultimately be converting these table to be compatible with my brand
> new register_sysctl() and using that to register them.
> 
> In fact I am pretty certain we can just do:
> register_sysctl("net/ipv4/route", ipv4_route_table);
> register_sysctl("net/ipv4/neigh", empty);
Thanks, I've tested this and it works, however it seems that there are still
memleaks, please see below.

> instead of:
> register_sysctl_paths(ipv4_path, ipv4_skeleton);
> 
> And kill ipv4_skeleton and ipv4_path as they are now unused.
Right, and use the path directly from the .data section.

> There was a tremendous cleanup and speed up that came with not allowing
> sysctl tables to support .child entries in the core, and the older
> registration routines break apart the tables and return a compatilibty
> sysctl_table_header if we do that, and I believe we are just
> leaking that compatibility sysctl_table_header.
Thanks for the explanation, however I don't understand all of this since
I'm not familiar with the old/new code, but I want to report some notes
(I'm not sure if they are correct).


1) memleaks:
After testing your proposed change:

register_sysctl("net/ipv4/route", ipv4_route_table);

for ipv4_route_table it is ok, no memleak is reported since the returned
ctl_table_header is referenced by the ctl_node nodes. This will silence
the memleak report.

for:
register_sysctl("net/ipv4/neigh", empty);

Here we'll still have the memleak, I don't know if this is the "leaking
that compatibility sysctl_table_header" you are referring to. But here the
returned ctl_table_header will not be referenced by the ctl_node nodes
since we have an empty ctl_table. see init_header()


So is there real memleaks that got hidden by the false positive ones ?
or perhaps these are real memleaks that were never spotted ?


2) From the __register_sysctl_table(), if the ctl_table is empty then
nr_entries == 0.

later we have:
header = kzalloc(sizeof(struct ctl_table_header) +
                 sizeof(struct ctl_node)*nr_entries, GFP_KERNEL);
...
node = (struct ctl_node *)(header + 1);
init_header(header, root, set, node, table);
...

node points to somewhere, but its use in this situations seems restricted.


3) Why we always alloc ctl_table_header in __register_sysctl_table() at
the beginning ? if I'm right, the current design is:
"each directory should have its ctl_table_header", so if some ctl_tables
share the same directory then they should also share the same
ctl_table_header ?

In this case the code can be improved, check if it's a new dir, then alloc
a new ctl_table_header, otherwise just return the old one and increment
the counter and insert ctl_table entries there.

I say this since currently doing:
register_sysctl("net/ipv4/neigh", empty);
register_sysctl("net/ipv4/neigh", empty);
register_sysctl("net/ipv4/neigh", empty);

Will allocate three ctl_table_header however at the second call the code
successfully detects that this is _not_ a new dir, but it will return the
ctl_table_header that was allocated at the beginning of
__register_sysctl_table().


Is this also related to the "leaking that compatibility sysctl_table_header" ?


4) Is the order of sysctl locking inside insert_links() correct ?


If I'm missing something, please just point-me to an http-link and I'll try
to take a closer look when time permits, otherwise someone who knows this
should just take a look at it.


Sorry for the delay (just got some free time).

Thanks.

-- 
tixxdz
http://opendz.org
