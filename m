From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 06 Mar 2005 12:01:50 -0500
Message-ID: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
References: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <20050306095642.GA1352@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Martin Mares <mj@ucw.cz>
In-Reply-To: <20050306095642.GA1352@ucw.cz>
References: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 10:56 AM 3/6/05 +0100, Martin Mares wrote:
>Hello!
>
>> Unfortunately, this does not work with the Linux stack, because the
>> 127 net is treated (for good reasons I suppose) as a special net.
>
>Is it really?

Well, at least it looks that way to me:

    svfx:~# netstat -rn
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags   MSS Window
irtt Iface
    192.168.13.0    0.0.0.0         255.255.255.0   U         0 0
0 eth0
    0.0.0.0         192.168.13.254  0.0.0.0         UG        0 0
0 eth0
    svfx:~# 

Hmmm, I don't seem to have the loopback interface...
This table implies that 127.0.0.1 should go out via eth0
to a gateway 192.168.13.264.  That's hard to believe.

    svfx:~# ping -c 1 127.0.0.1
    PING 127.0.0.1 (127.0.0.1): 56 data bytes
    64 bytes from 127.0.0.1: icmp_seq=0 ttl=255 time=0.2 ms

    --- 127.0.0.1 ping statistics ---
    1 packets transmitted, 1 packets received, 0% packet loss
    round-trip min/avg/max = 0.2/0.2/0.2 ms

Looks like I do have the loopback interface after all. It just
seems to be hidden, i.e., it actually is treated in a special way
by one of the entities I am perusing.
Let's see if I can delete the route anyway.

    svfx:~# route del -net 127.0.0.0 netmask 255.0.0.0 dev lo
    SIOCDELRT: No such process
    svfx:~# 

Looks like I can't, maybe it's not there?

>I've just tried
>
>	ip addr del 127.0.0.1/8 dev lo
>	ip addr add 127.0.0.1/24 dev lo
>
>and `ping 127.1.2.3' is then happily sent along the default route.
>

I don't have iproute around, so I will install it now.
...
and try your method:

    svfx:~# ip addr del 127.0.0.1/8 dev lo
    Cannot send dump request: Connection refused
    svfx:~# 

That actually looks like some compatibility issue if I had to guess.
I never used the iproute tools, so I'll ignore that for now.
[Anyone knows what this means?]

Something just crossed my mind - maybe the 127 processing
and/or the netstat/route/iproute tools are in flux, i.e., being
changed in a major way to the point that I really need to pay
attention to what kernel I am running.  I have done the above tests
on my "stable" machine, which runs 2.2.20 (common Debian stable
release). I'll go and retest everything on my embedded target
which is running the 2.4.25 kernel.

Can someone comment on the stability of the tools in question
or any implementation changes in this area that would explain
the above behavior?

But point well taken, perhaps I just need a bit more imagination
when I'm testing these things.  It may very well work, it just may
look like it does not.  Thanks for the suggestions!

Regards,
-Zdenek
