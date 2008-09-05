From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 11:17:54 +0400
Message-ID: <20080905071754.GA25998@2ka.mipt.ru>
References: <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com> <20080903132734.GA17541@2ka.mipt.ru> <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com> <20080903151340.GA7566@2ka.mipt.ru> <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com> <20080903164346.GA6729@2ka.mipt.ru> <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com> <20080903220347.GA22395@2ka.mipt.ru> <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55450 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbYIEHS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 03:18:28 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Thu, Sep 04, 2008 at 04:44:15PM +0200, Johann Baudy (johaahn@gmail.c=
om) wrote:
> I'm finally able to run a full zero copy mechanism with UDP socket as=
 you said.
> Unfortunately, I need at least one vmsplice() system call per UDP
> packet (vmsplice call()).
> mere vmsplice(mem to pipe) cost much (80=C2=B5s of CPU). And splice(p=
ipe to
> socket) call is worst...
> 80us is approximately the duration of 12Kbytes sent at 1Gbps. As I
> need to send packet of 7200bytes (with no frag)...
> I can't use this mechanism unfortunaltely. I've only reached 20Mbytes=
/s.

vmsplice() can be slow, try to inject header via usual send() call, or
better do not use it at all for testing.

> You can find below a FTRACE of vmsplice(), if you find something
> abnormal ... :) :
> (80=C2=B5s result is an average of vmsplice() duration thanks to
> gettimeofday(): WITHOUT FTRACE IN KERNEL CONFIG)

Amount of gettimofday() and friends is excessive, but it can be a trace
tool itself. kill_fasync() also took too much time (top CPU user
is at bottom I suppose?), do you use SIGIO? Also vma traveling and page
checking is not what will be done in network code and your project, so
it also adds an overhead. Please try without vmsplice() at all, usual
splice()/sendfile() _has_ to saturate the link, otherwise we have a
serious problem.

> So, I will return to work on my circular buffer.
> This way I can control (ethernet frame length)*(number of frame)/
> (number of system call) ratio.

Not to distract you from the project, but you still can do the same wit=
h
existing methods and smaller amount of work. But I should be last sayin=
g
that creating tricky hacks to implement the idea should be abandoned in
favour of the standards (even slow) methods :)

--=20
	Evgeniy Polyakov
