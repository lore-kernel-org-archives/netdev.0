From: Jeffrey Merkey <jeffmerkey@gmail.com>
Subject: Re: 2.6.34 Crash in dmaengine_put()
Date: Tue, 22 Jun 2010 10:36:28 -0600
Message-ID: <AANLkTikIzdbNH83SkIxCxEL2NMZmfErq7s6WgAGPtbwi@mail.gmail.com>
References: <AANLkTilCW2iqsNaWM9NYIomy8OxGC9jG40KpLcKMYTqL@mail.gmail.com>
	<20100621202854.de928e0a.akpm@linux-foundation.org>
	<AANLkTimsDSrEL8vT877pLYSa4A338p4Y8w0Ya6Xm7BFJ@mail.gmail.com>
	<1277217804.3057.428.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277217804.3057.428.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>> OK. =A0This bug occurs if you OR in the IFF_UP flag while creating
>> virtual interfaces without going through the normal ifup/ifdown
>> scripts. =A0Looks like a hole. =A0I will post the trace shortly. =A0=
It's
>> easy to reproduce, take the dummy net driver, OR in the IFF_UP flag =
in
>> dummy_setup, and watch the kernel crash.
>>
>
> Then dont do that ?
>
> No need to send us a trace, unless you use a pristine kernel.
>
> IFF_UP changes rules are very strict, dont try to avoid them and clai=
m
> there is a hole or something wrong.
>
> Check __dev_open() , __dev_close() and __dev_change_flags() were OR/A=
ND
> IFF_UP is done by core network.
>
> Net drivers are not allowed to change IFF_UP themselves.
>
> (DE-600 & DE-620 being the exceptions to confirm this rule, of course=
)
>

Gee.  OK, its a bug.  I see the crash when unregister_netdev is
called.  Changing a flag in a driver should not cause the kernel to
crash.  You should check the code.  The dmaengine registration should
have nothing to do with registering a netdev -- period.  I have coded
arounnd it but its damn convenient to create virtual drivers on the
fly and mark them as UP without needing to configure a bunch of text
scripts to bring one up or down.

The code itself is busted because it has a check if the dmaengine ref
count goes negative.  If you are going to have a registration layer
the rest of the OS should not have to wonder about its disconnected
state.  The busted code is right at the top of dmaengine_put where it
decrements the ref count then immediately jumps to a bug.  Need a
better way here I think to prevent needless crashes.  Someone could
just alter this flag remotely and crash a server -- HOLE - :)

Jeff
