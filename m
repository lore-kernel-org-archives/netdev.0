From: Dax Kelson <dax@gurulabs.com>
Subject: Memory usage/tuning for ip_conntrack
Date: 18 Jul 2003 18:12:21 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058573540.6491.18.camel@mentor.gurulabs.com>
References: <1058558848.2674.88.camel@mentor.gurulabs.com>
	 <1058563690.26030.23.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1058563690.26030.23.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-18 at 15:28, Martin Josefsson wrote:

> Increasing the number of buckets doesn't cost much memory compared to
> the actual connections and it gives you a nice performanceboost if you
> are trying to handle lots of connections. (the default is based on the
> amount of memory in the machine and it's normally ok for desktop
> machines and small servers/routers)

I just wanted to followup publicly for archival purposes.

OK, so getting more into the realm of "best practices", by default the
maximum number of connections tracked will be 8x the number of buckets.

The number of buckets is determined at boot time based on amount of ram
(this in turns determines max connections that can be tracked -- (8 *
buckets see above)).

This is fine for desktop, small routers, etc.

However, both numbers can be tuned independently of each other.

On a box with lots of connections flowing through it (ie, a dedicated
high volume NAT/firewall/router), you can get better performance if your
max connections per bucket ratio is 2:1 instead of the default 8:1.

On Red Hat Linux, to do this tuning, figure out how many maximum
connections you want to track, divide this number in half (make sure it
isn't a 2^n number on kernels < 2.4.21).  This is how many buckets you
should have.  To configure your system with this many buckets, add the
following lines to your /etc/modules.conf file:

(The 44000 used below is just an example, estimate your worst case
scenario and add 10% to it).

# I want to have a 2:1 bucket to connection ratio for good performance
# Since I want to have a maximum of 44000 connections tracked, I
# set the number of buckets to 1/2 that value for a 2:1 ratio. 
options ip_conntrack hashsize=22000

Now by default you'll have 8 * 22000 this number of maximum connections
which is much higher than the  To readjust this down to the good 2:1
ratio add the following line to your /etc/sysctl.conf file:

net.ipv4.ip_conntrack_max = 44000

Now to figure out maximum possible memory consumption, do the following:

(memory used per buckets * number of buckets) + (memory used per tracked
connection * maximum number of tracked connections)

Memory used per bucket is 8 bytes on 32bit hardware, 16 bytes on 64bit
hardware.

To determine "memory used per tracked connection", run this command:

grep ip_conntrack /proc/slabinfo  | tr -s " " | cut -d " " -f 4

Did I miss anything or do you have anything to add Martin?

Dax Kelson
Guru Labs
