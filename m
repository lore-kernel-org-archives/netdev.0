From: jamal <hadi@cyberus.ca>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sat, 5 Apr 2003 14:02:19 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030405134350.N68419@shell.cyberus.ca>
References: <20030405165016.GA32361@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030405165016.GA32361@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 5 Apr 2003, bert hubert wrote:

> Forwarded:
>
> ----- Forwarded message from Florian Weimer <fw@deneb.enyo.de> -----
>
> To: linux-kernel@vger.kernel.org
> Subject: Route cache performance under stress
> From: Florian Weimer <fw@deneb.enyo.de>
> Date: Sat, 05 Apr 2003 18:37:43 +0200
> X-Mailing-List: linux-kernel@vger.kernel.org
>
> Please read the following paper:
>
> <http://www.cs.rice.edu/~scrosby/tr/HashAttack.pdf>
>
> Then look at the 2.4 route cache implementation.
>
> Short summary: It is possible to freeze machines with 1 GB of RAM and
> more with a stream of 400 packets per second with carefully chosen
> source addresses.  Not good.
>

I dont think the author has done any testing actually at the rate they
claim to have to - if they did they wouldnt be wording it as "carefully
chosen source addresses".

> The route cache is a DoS bottleneck in general (that's why I started
> looking at it).

Yes it is - but not using the reasons described above.

> You have to apply rate-limits in the PREROUTING
> chain, otherwise a modest packet flood will push the machine off the
> network (even with truly random source addresses, not triggering hash
> collisions).  The route cache partially defeats the purpose of SYN
> cookies, too, because the kernel keeps (transient) state for spoofed
> connection attempts in the route cache.
>

I think two issues are being mixed here: One the dst cache and two
the SYN attacks. The TCP SYNs are more vulnerable than dst cache
and rate control of SYNs may remedy the issue.

> The following patch can be applied in an emergency, if you face the
> hash collision DoS attack.  It drastically limits the size of the
> cache (but not the bucket count), and decreases performance in some
> applications, but
>
> --- route.c	2003/04/05 12:41:51	1.1
> +++ route.c	2003/04/05 12:42:42
> @@ -2508,8 +2508,8 @@
>  		rt_hash_table[i].chain = NULL;
>  	}
>
> -	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
> -	ip_rt_max_size = (rt_hash_mask + 1) * 16;
> +	ipv4_dst_ops.gc_thresh = 512;
> +	ip_rt_max_size = 2048;
>

And why could this not have been done in /proc? Is this supposed
to cure something?

>
> I wonder why the route cache is needed at all for hosts which don't
> forward any IP packets, and why it has to include the source addresses
> and TOS (for policy-based routing, probably).  Most hosts simply don't
> face such complex routing decisions to make the cache a win.
>
> If you don't believe me, hook a Linux box to a packet generator
> (generating packets with random source addresses) and use iptables to
> drop the packets, in a first test run in the INPUT chain (after route
> cache), and in a second one in the PREROUTING chain (before route
> cache).  I've observed an incredible difference (not in laboratory
> tests, but during actual DoS attacks).
>
> Netfilter ip_conntrack support might have similar issues, but you
> can't use it in a uncooperative environment anyway, at least in my
> experience.  (Note that there appears to be no way to disable
> connection tracking while the code is in the kernel.)

There are issues with dst cache no doubt. contracking on the
other hand is appaling. In any case i think it is extremely dangerous to
read some academic paper and start waving hands around about how it
applies here. Do some tests and come up with data of where things need to
be improved. Just pointing a finger at hashing is insufficient
(infact i dont think hashing is the primary issue based on some
experiments foo and i did)

cheers,
jamal
