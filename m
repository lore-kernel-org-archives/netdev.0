From: David Brownell <david-b@pacbell.net>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 01 Apr 2002 12:31:43 -0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <080d01c1d9bc$3d4510a0$6800000a@brownell.org>
References: <Pine.GSO.4.30.0203310941120.9704-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>, Stefan Rompf <srompf@isg.de>
List-Id: netdev.vger.kernel.org

Two comments on this stuff:

(A) I skimmed the 3.1.13 descriptions in RFC 2863.
If RUNNING is to correspond to ifAdminStatus,
and NO_CARRIER is inverted up/down ifOperStatus,
this starts to make sense.  For example, it defines
the set/set state in Jamal's table as a fault condition.

That doesn't quite seem like a complete match though,
and not only because one can't map N-ary ifOperStatus
(up, down, unknown, testing, dormant, notPresent, and
maybe more) to single bits like NO_CARRIER.


(B) In Jamal's table I'm thinking about how IP-over-USB
stacks would work.  Those tend to be point-to-point
links with Ethernet framing (easier to bridge :).

The devices themselves are all hotplugged, so their
interface names won't exist unless there's hardware
(maybe it's in the process of being unplugged).  But
that means there are three meaningful modes:

    - Only "my" end connected ... nobody on the
      other end (treated as NO_CARRIER) so
      IFF_RUNNING can't _ever_ usefully be set

    - Both ends connected (!NO_CARRIER)
      so IFF_RUNNING could be set or not.

    - "Indeterminate" ... some cables might not be
      able to report whether someone's on the other
      end.  Driver would necessarily treat as if both
      ends were always connected.

So eventually some linkwatch patch could be solving
a problem there:  no network hotplug events appear
for "carrier on" and "carrier off", which are the only
events that really matter here (not "register device" 
and "unregister device") for ifup/ifdown/... calls.

- Dave


> NO_CARRIER | IFF_RUNNING | meaning
> -----------|-------------|------------------------------------
> !set       | !set        | There is carrier, but no cable
>            |             | no sense for ethernet; but may be useful
>            |             | for PPP (for example line protocol is not up)
> -----------|-------------|----------------------------------------
> !set       | set         | operational up
>            |             |
>            |             |
> -----------|-------------|--------------------------------------
> set        | !set        | operational down
>            |             |
>            |             |
> -----------|-------------|--------------------------------------
> set        | set         | carrier off, cable on; not sure what this
>            |             | means (may make sense for host scope)
>            |             |
> -----------|-------------|--------------------------------------
