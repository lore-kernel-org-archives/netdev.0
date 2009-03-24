From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Allow group ownership of TUN/TAP devices.
Date: Tue, 24 Mar 2009 21:10:54 +0300
Message-ID: <49C9222E.7090100@msgid.tls.msk.ru>
References: <498700CD.2030403@msgid.tls.msk.ru> <20090205105456.GA26440@bogon.ms20.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux-kernel <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Guido_G=FCnther?= <agx@sigxcpu.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760377AbZCXSEu@vger.kernel.org>
In-Reply-To: <20090205105456.GA26440@bogon.ms20.nix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Again, resurrecting an old thread...
  lkml added -- this is a policy issue, so to say]

Guido G=FCnther wrote at Thu, 5 Feb 2009 11:54:57 +0100:
> On Mon, Feb 02, 2009 at 05:18:53PM +0300, Michael Tokarev wrote:
> [..snip..]=20
>> My first attempt - pretty obvious when I saw -g option of tunctl - i=
s
>> to add group ownership for the tun device and add a supplementary gr=
oup
>> to each user (their primary group should be different).  But that fa=
ils,
>> since kernel only checks for egid, not any other group ids.

It's a bit worse than that.  I.e., there's exactly 2 problems here.

=46irst, currently tun driver only checks primary gid and not any
supplementary gids (this is what my one-line patch addressed).

And second, if both gid and uid is specified for the given tun
device, BOTH should match.  I.e, I can be "owner"(*) of the device
in question, but if my current gid does not match, I still can't
use it.  This one is interesting: currently, one can grant a tun
device to a given "incarnation" of an uid, that is, suppose we've
two processes running under the same uid but with different gids -
this way, I can grant the device to only one of them.  But here,
why to grant to uid anyway, just use that gid.. I think ;)

(*) note the quotes around "owner" here because, unlike with, say,
files, I can't do anything I want with the network device, I only
have very limited set of operations.

> Since others tripped on this it might make sense to change it to also
> check supplementary groups. However I don't think changing the existi=
ng
> syscall is an option since it might allow users to access tun/tap
> devices on existing systems that weren't allowed to do so before (whi=
ch
> might be a security problem).

And this is the question which's the reason why I added Cc LKML.

My point of view is that it's a bug in original design, it was done
not so long ago (around mid-2007, well, 2+ years isn't that short
anymore, right?), this feature isn't used much currently (because
it's less known than, say, user ownership and because of this very
bug), and because fixing it by introducing another mechanism nearby
is even more ugly (IMHO anyway).

The lack of (wide) usage (or anyway, I think that this feature is
not widely used) -- currently, due to the requirement that it must
be primary group, it's almost impossible to use.  A device gets
granted to a user instead, or the group in question becomes his
primary group, without granting it to others.  In most cases anyway.
This is in addition to the fact that group ownership for a net
device isn't very useful to begin with, because it's not intended
for "collective" use in the first place.

But the question remains -- what to do with this mess.

I almost forgot about this issue, -- I added the patch to the
local kernel package and it worked since.  But today I tried
to compile 2.6.29, the patch didn't apply so I skipped it the
first try, and almost immediately trapped to this issue again,
because my scripts and my kvm stuff stopped working... ;)

Thanks!

/mjt
