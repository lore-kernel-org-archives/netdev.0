From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Memory usage for ip_conntrack
Date: 18 Jul 2003 23:28:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058563690.26030.23.camel@tux.rsn.bth.se>
References: <1058558848.2674.88.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <1058558848.2674.88.camel@mentor.gurulabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-18 at 22:07, Dax Kelson wrote:
> I'm teaching a Linux class and the book says "Using ip_conntrack will
> use much more memory".
> 
> A student asked me how much is "much".
> 
> So on a 2.4.20+  how much memory does it take to track the state of a
> connection?

This depends on which patches you've applied and if you have selected
NAT support when you compiled it or not. You can see how much memory it
uses by looking at the kernel output when ip_conntrack is initialized.
It looks like:

ip_conntrack version 2.1 (5632 buckets, 45056 max) - 304 bytes per conntrack

That's the number of bytes ip_conntrack will try to allocate for each
connection. But it isn't neccessarily the real number of bytes
allocated. You'll have to look at /proc/slabinfo for that. Look at
column 4, that's the object size. In my case it's 320 bytes.

And each bucket in the hashtable will use 8 bytes on a 32bit machine, 16
bytes on a 64bit machine.

> If I echo 102400 > /proc/sys/net/ipv4/ip_conntrack_max, what is my worst
> case memory usage?

Don't do this. This will increase the maximum number of connections it
will track, but not the number of buckets. Which means that it will be
slower due to longer collision-chains. Instead increase the number of
buckets. modprobe ip_conntrack hashsize=131072 (or any number here. If
it's a < 2.4.21 kernel 2^n sizes aren't recommended due to a poor
hashfunction. Instead you should use 2^n-1)

In my case the memory-usage for the above numbers would be:

5632 buckets * 8 bytes (32bit machine)
+
102400 * 320 bytes (object size from slabinfo)
= 45056 + 32768000 ~= 31.3 MB

Increasing the number of buckets doesn't cost much memory compared to
the actual connections and it gives you a nice performanceboost if you
are trying to handle lots of connections. (the default is based on the
amount of memory in the machine and it's normally ok for desktop
machines and small servers/routers)

ip_conntrack is a memory-hog, we are working on reducing the
memory-usage.

-- 
/Martin
