From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Mon, 19 Oct 2015 13:48:20 -0700
Message-ID: <56255714.2070800@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
 <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com>
 <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com>
 <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net>
 <56240814.8020105@plumgrid.com>
 <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>
 <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>
 <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>
 <56253335.9000206@plumgrid.com>
 <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32871 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbbJSUsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 16:48:19 -0400
Received: by pabrc13 with SMTP id rc13so200953093pab.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 13:48:18 -0700 (PDT)
In-Reply-To: <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/15 1:03 PM, Hannes Frederic Sowa wrote:
>
> I doubt it will stay a lightweight feature as it should not be in the
> responsibility of user space to provide those debug facilities.

It feels we're talking past each other.
I want to solve 'persistent map' problem.
debugging of maps/progs, hierarchy, etc are all nice to have,
but different issues.
In case of persistent maps I imagine unprivileged process would want
to use it eventually as well, so this requirement already kills cdev
approach for me, since I don't think we ever let unprivileged apps
create cdev with syscall.

> The bpf syscall is still used to create the pseudo nodes. If they should
> be persistent they just get registered in the sysfs class hierarchy.

nope. they should not. sysfs is debugging/tunning facility.
There is absolutely no need for bpf to plug into sysfs.

>> Doing 'resource stats' via sysfs requires bpf to add to sysfs, which
>> is not this cdev approach.
>
> This is not yet part of the patch, but I think this would be added.
> Daniel?

please don't. I'm strongly against adding unnecessary bloat.

> I don't think there are broad differences. But in case a namespaces uses
> huge number of maps with tons of data, the admin in the initial
> namespace might want to debug that without searching all mountpoints and
> find dependencies between processes etc. IMHO sysfs approach can be
> better extended here.

sure, then we can force all bpffs to have the same hierarchy and mounted
in /sys/kernel/bpf location. That would be the same.

It feels you're pushing for cdev only because of that potential
debugging need. Did you actually face that need? I didn't and
don't like to add 'nice to have' feature until real need comes.

>> Also I don't buy the point of reinventing sysfs. bpffs is not doing
>> sysfs. I don't want to see _every_ bpf object in sysfs. It's way too
>> much overhead. Classic doesn't have sysfs and everyone have been
>> using it just fine.
>
> But classic bpf does not have persistence for maps and data. ;) There is
> a 1:1 relationship between socket and bpf_prog for example.

single task in seccomp can have a chain of bpf progs, so hierarchy
is already there.

> But how can the filesystem be extended in terms of tunables and
> information? File attributes? Wouldn't it need the same infrastructure
> otherwise as sysfs? Some third-party lookup filesystem or ioctl? This
> char dev approach also pins maps and progs while giving more policy in
> hand of central user space programs we are currently using (udev,
> systemd, whatever, etc.).

tunables for bpf maps? There are no such things today.
I think you're implying that we can add rhashtable type of map, so
admin can tune thresholds ? Ouch. I think if we add it, its parameters
will be specified by the user that is creating the map only. There will
be no tunables exposed to sysfs and there should be no way of creating
maps via sysfs.
