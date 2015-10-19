From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Mon, 19 Oct 2015 09:22:16 -0700
Message-ID: <562518B8.2070401@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5624FCDF.3090601@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/15 7:23 AM, Daniel Borkmann wrote:
>>> The mknod is not the holder but rather the kobject which should be
>>> represented in sysfs will be. So you can still get the map major:minor
>>> by looking up the /dev file in the correspdonding sysfs directory or I
>>> think we should provide a 'unbind' file, which will drop the kobject if
>>> the user writes a '1' to it.
>>
>> I agree, this could still be done.

imo doing 'rm' is way cleaner then dealing with 'unbind' file.

> As Hannes said, under /sys/class/bpf/ an admin can see all held nodes, so
> visibility is there for free at all times. The device management (creation/
> deletion) itself and the mknod's pointing to it are simply decoupled.
>
> This whole approach looks sound to me, also integrates nicely into the
> existing Linux facilities, and works on top of every fs supporting special
> files. Much cleaner than an extra file-system that would be required by a
> syscall in order to make the syscall work.

thanks for the explanations. I think I got a complete picture now on
how such cdev will be used and I don't like it.
There is nothing in linux or any unix that creates thousands of cdevs
on the fly, but here user apps will create/destroy them back and forth
and they would need to do it quickly. Whole sysfs/kobj baggage is
completely unnecessary here. The kernel will consume more memory for
no real reason other than cdev are used to keep prog/maps around.
imo fs is cleaner and we can tailor it to be similar to cdev style.
For example we can make bpffs automount in /sys/kernel/bpf/ as standard
location and have one directory structure for all mounts (like tracefs).
Then within it have idr mechanism to crate bpf_progX and bpf_mapY
special files via BPF_PIN_FD bpf syscall with single FD argument.
At this point fs and cdev approach from user point of view look
exactly the same, but overhead of fs is significantly lower,
normal 'rm' works just fine and much faster.
