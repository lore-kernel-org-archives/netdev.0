From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 23:25:37 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.232537.102562046.davem@redhat.com>
References: <001001c32e19$81bc7ea0$4a00000a@badass>
	<20030608230300.X33412@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030608230300.X33412@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Sun, 8 Jun 2003 23:15:46 -0400 (EDT)
   
   The more i think about it the more i think CEF is a lame escape
   from route caches.

It is one perspective :-)

   What we need is multi-tries at the slow path and
   perhaps a binary tree on hash collisions buckets of the dst cache
   (instead of a linked list).

I do not believe that slow path is slow.  In fact after I fixed
hash table growth in fib_hash.c Simon showed us clearly how DoS
performance was _NOT_ tied to the number of routes loaded into
the kernel.

What is slow are things like fib_validate_source() on SMP and the GC
(and some other things, I need to study Simon's profiles more deeply).
The GC is aparently really badly behaved now during DoS like traffic.

My main current quick idea is to make rt_intern_hash() attempt
to flush out entries in the same hash chain instead of allocating
new entries.

I also question the setting of ip_rt_max_size in relation to the
number of hash chains (it's set to n_hashchains * 16 currently,
that sounds wrong, maybe something more like n_hashchains * 2 or
even n_hashchains * 3).

I'll try to cook up a patch to test.  We might even be able to
kill of route cache GC entriely if this scheme works well.
