From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 10:55:16 -0700
Message-ID: <CALCETrXWzja6W6y=p9MrtynGZMsrD5KQu0KBK6Bs1dQxnesv2A@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com> <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org> <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org> <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org> <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
 <1394733077.32465.243.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Simo Sorce <ssorce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:38556 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbaCMRzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 13:55:37 -0400
Received: by mail-vc0-f179.google.com with SMTP id ij19so1514014vcb.38
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 10:55:36 -0700 (PDT)
In-Reply-To: <1394733077.32465.243.camel@willson.li.ssimo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 10:51 AM, Simo Sorce <ssorce@redhat.com> wrote:
> On Wed, 2014-03-12 at 19:12 -0700, Andy Lutomirski wrote:
>> On Wed, Mar 12, 2014 at 6:43 PM, Simo Sorce <ssorce@redhat.com> wrote:
>> > On Wed, 2014-03-12 at 18:21 -0700, Andy Lutomirski wrote:
>> >> On Wed, Mar 12, 2014 at 6:17 PM, Simo Sorce <ssorce@redhat.com> wrote:
>> >> > On Wed, 2014-03-12 at 14:19 -0700, Andy Lutomirski wrote:
>> >> >> On Wed, Mar 12, 2014 at 2:16 PM, Simo Sorce <ssorce@redhat.com> wrote:
>> >> >>
>> >> >> >
>> >> >> > Connection time is all we do and can care about.
>> >> >>
>> >> >> You have not answered why.
>> >> >
>> >> > We are going to disclose information to the peer based on policy that
>> >> > depends on the cgroup the peer is part of. All we care for is who opened
>> >> > the connection, if the peer wants to pass on that information after it
>> >> > has obtained it there is nothing we can do, so connection time is all we
>> >> > really care about.
>> >>
>> >> Can you give a realistic example?
>> >>
>> >> I could say that I'd like to disclose information to processes based
>> >> on their rlimits at the time they connected, but I don't think that
>> >> would carry much weight.
>> >
>> > We want to be able to show different user's list from SSSD based on the
>> > docker container that is asking for it.
>> >
>> > This works by having libnsss_sss.so from the containerized application
>> > connect to an SSSD daemon running on the host or in another container.
>> >
>> > The only way to distinguish between containers "from the outside" is to
>> > lookup the cgroup of the requesting process. It has a unique container
>> > ID, and can therefore be mapped to the appropriate policy that will let
>> > us decide which 'user domain' to serve to the container.
>> >
>>
>> I can think of at least three other ways to do this.
>>
>> 1. Fix Docker to use user namespaces and use the uid of the requesting
>> process via SCM_CREDENTIALS.
>
> This is not practical, I have no control on what UIDs will be used
> within a container, and IIRC user namespaces have severe limitations
> that may make them unusable in some situations. Forcing the use of user
> namespaces on docker to satisfy my use case is not in my power.

Except that Docker w/o userns is basically completely insecure unless
selinux or apparmor is in use, so this may not matter.

>
>> 2. Docker is a container system, so use the "container" (aka
>> namespace) APIs.  There are probably several clever things that could
>> be done with /proc/<pid>/ns.
>
> pid is racy, if it weren't I would simply go straight
> to /proc/<pid>/cgroups ...

How about:

open("/proc/self/ns/ipc", O_RDONLY);
send the result over SCM_RIGHTS?

>
>> 3. Given that Docker uses network namespaces, I assume that the socket
>> connection between the two sssd instances either comes from Docker
>> itself or uses socket inodes.  In either case, the same mechanism
>> should be usable for authentication.
>
> It is a unix socket, ie bind mounted on the container filesystem, not
> sure network namespaces really come into the picture, and I do not know
> of a racefree way of knowing what is the namespace of the peer at
> connect time.
> Is there a SO_PEER_NAMESPACE option ?

So give each container its own unix socket.  Problem solved, no?

--Andy
