From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 08:00:33 -0700
Message-ID: <m1y6asld2m.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m1bp7oq1u8.fsf@fess.ebiederm.org> <4C9B162E.7040201@parallels.com>
	<1285240797.5036.5.camel@bigi> <4C9B3B06.900@parallels.com>
	<1285242055.5036.9.camel@bigi> <4C9B3F9C.8080506@parallels.com>
	<1285243881.5036.22.camel@bigi> <4C9B495D.70200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C9B495D.70200@parallels.com> (Pavel Emelyanov's message of
	"Thu, 23 Sep 2010 16:34:37 +0400")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

> On 09/23/2010 04:11 PM, jamal wrote:
>> On Thu, 2010-09-23 at 15:53 +0400, Pavel Emelyanov wrote:
>> 
>>> Why does it matter? You told, that the usage scenario was to
>>> add routes to container. If I do 2 syscalls instead of 1, is
>>> it THAT worse?
>>>
>> 
>> Anything to do with socket IO that requires namespace awareness
>> applies for usage; it could be tcp/udp/etc socket. If it doesnt
>> make any difference performance wise using one scheme vs other
>> to write/read heavy messages then i dont see an issue and socketat
>> is redundant.
>
> That's what my point is about - unless we know why would we need it
> we don't need it.
>
> Eric, please clarify, what is the need in creating a socket in foreign
> net namespace?

Strictly speaking with setns() you can implement this functionality
with setns().  aka

int socketat(int nsfd, int domain, int type, int protocol)
{
        int sk;

        setns(0, nsfd);
        sk = socket(domain, type, protocol);
        setns(0, default_nsfd);

        return sk;
}

The major difference is that socketat in userspace suffers
from races, with signals etc.

The use case are applications are the handful of networking applications
that find that it makes sense to listen to sockets from multiple network
namespaces at once.  Say a home machine that has a vpn into your office
network and the vpn into the office network runs in a different network
namespace so you don't have to worry about address conflicts between
the two networks, the chance of accidentally bridging between them,
and so you can use different dns resolvers for the different networks.

In that scenario it would be nice if I could run some services on both
networks.  Starting two+ copies of the daemons just so the can have live
in all of the networks is ok, but in the fullness of time I expect that
there will be daemons that want to optimize things and have sockets in
all of the network namespaces you are connected to.

In a multiple network namespace aware application when it goes to open
a socket it will want to specify which network namespace the socket is
in.  If it is a general listener it will probably listening to events
in /proc/mounts waiting for extra namespaces to be mounted under a
standard location say: /var/run/netns/<netnsname>/ns.

Once the application receives the event for a new network namespace
showing up it can will want to create a new socket listening for
connections in the new network namespace.

In that scenario none of those network namespaces are foreign, but one
network namespace will be the default and the rest will be non-default
network namespaces.

To support a multiple network namespace aware daemon I need to implement
sockeat() somewhere.  So I figured I would see if anyone minded a
trivial in kernel race free implementation.  To me it is a wart in the
API and I am busily removing warts in the API.

I don't know of any scenarios with other namespaces where there would be
applications that would be native in multiple namespaces.  So I haven't
haven't done any work in that direction.

Eric
