From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 01:27:18 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609082718.GG20613@netnation.com>
References: <20030609071330.GD20613@netnation.com> <000401c32e5e$a707b6d0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@redhat.com>, hadi@shell.cyberus.ca,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: CIT/Paul <xerox@foonet.net>
Content-Disposition: inline
In-Reply-To: <000401c32e5e$a707b6d0$4a00000a@badass>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 04:10:55AM -0400, CIT/Paul wrote:

> I've got juno-z.101f.c to send 500,000 pps at 300+mbit on our dual p3
> 1.26 ghz routers.. I can't even send 50mbit of this though one of my
> routers
> Without it using 100% of both cpus because of the route cache.. It goes
> up to 500,000 entries if I let it and it adds 80,000 new entries per
> second and they are all cache misses.. I'd be glad to show you the setup
> sometime :) I showed it to jamal and we tested some stuff.

Hmm.. We're running on single 1800MP Athlons here.  Have you had a chance
to profile it? 

- add "profile=1" to the kernel command line
- reboot
- run juno-z.101f.c from remote box
- run "readprofile -r" on the router
- twiddle fingers for a while
- run "readprofile -n -m your_System.map > foo"
- stop juno :)
- run "sort -n +2 < foo > readprofile.time_sorted"

I'm interested to see if your profile results line up to what I'm seeing
here on UP (though I have the kernel compiled SMP...Oops).

Wait a second... 500,000 entries in the route cache?  WTF?  What is your
max_size set to?  That will massively overfill the hash bucket and
definitely take up way too much CPU.  It shouldn't be able to get there
at all unless you have raised max_size.  Here I have:

echo 4 > gc_elasticity          # Higher is weaker, 0 will nuke all [dfl: 8]
echo 1 > gc_interval            # Garbage collection interval (seconds) [dfl: 60]
echo 1 > gc_min_interval        # Garbage collection min interval (seconds) [dfl: 5]
echo 90 > gc_timeout            # Entry lifetime (seconds) [dfl: 300]

[sroot@r1:/proc/sys/net/ipv4/route]# grep . *
...
gc_elasticity:4
gc_interval:1
gc_min_interval:1
gc_thresh:4096
gc_timeout:90
max_delay:10
max_size:65536

Simon-
