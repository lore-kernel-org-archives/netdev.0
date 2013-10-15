From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel side)
Date: Tue, 15 Oct 2013 13:34:39 -0700
Message-ID: <87a9ias274.fsf@xmission.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>
	<20131008.152349.729447337097758010.davem@davemloft.net>
	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>
	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net>
	<87li22vv1w.fsf@xmission.com> <525D7109.4010004@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36578 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757504Ab3JOUep convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 16:34:45 -0400
In-Reply-To: <525D7109.4010004@6wind.com> (Nicolas Dichtel's message of "Tue,
	15 Oct 2013 18:44:57 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 10/10/2013 02:17, Eric W. Biederman a =C3=A9crit :
>>
>> Right.
>>
>> IFLA_NET_NS_PID is not invertible as there may be no processes runni=
ng
>> in a pid namespace.
>>
>> IFLA_NET_NS_FD is in principle invertible.  We just need to add a fi=
le
>> descriptor to the callers fd table.  I don't see IFLA_NET_NS_FD bein=
g
>> invertible for broadcast messages, but for unicast it looks like a b=
it
>> of a pain but there are no fundamental problems.
> I'm not sure to understand why it is invertible only for unicast mess=
age.
> Or are you saying that it is invertible only for the netns where the
> caller stands (and then not for the veth peer)?

The pain is that it is a special case of SCM_RIGHTS aka passing file
descriptors.  Right now we don't support SCM_RIGHTS on netlink sockets
and so from that perspective IFLA_NET_NS_FD is a bit of a hack.

=46or unicast messages we can just stuff a file descriptor in the calli=
ng
process and be done with it.  For multicast messages we have to be much
more complete.

>> I don't know if we care enough yet to write the code for the
>> IFLA_NET_NS_FD attribute but it is doable.
> I care ;-)
> Has somebody already started to write a patch?

=46or IFLA_NET_NS_FD not that I know of.

Mostly it is doable but there are some silly cases.
- Do we need to actually implement SCM_RIGHTS to prevent people
  accepting file-descriptors unknowingly and hitting their file
  descriptor limits.

  In which case we need to call the attribute IFLA_NET_NS_SCM_FD
  so we knew it was just an index into the passed file descriptors.n

- Do we need an extra permission check to prevent keeping a network
  namespace alive longer than necessary?  Aka there are some permission
  checks opening and bind mounting /proc/<pid>/ns/net do we need
  a similar check.  Perhaps we would need to require CAP_NET_ADMIN over
  the target network namespace.

Beyond that it is just the logistics to open what is essentially
/proc/<pid>/ns/net and add it to the file descriptor table of the
requesting process.  Exactly which mount of proc we are going to
find the appropriate file to open I don't know.

It isn't likely to be lots of code but it is code that the necessary
infrastructure is not in place for, and a bunch of moderately hairy
corner cases to deal with.

Eric
