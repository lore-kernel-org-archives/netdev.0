From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Mon, 19 Oct 2015 16:23:27 +0200
Message-ID: <5624FCDF.3090601@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net> <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com> <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com> <5624BD0C.3070404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5624BD0C.3070404@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2015 11:51 AM, Daniel Borkmann wrote:
> On 10/19/2015 09:36 AM, Hannes Frederic Sowa wrote:
>> On Sun, Oct 18, 2015, at 22:59, Alexei Starovoitov wrote:
>>> On 10/18/15 9:49 AM, Daniel Borkmann wrote:
>>>> Okay, I have pushed some rough working proof of concept here:
>>>>
>>>> https://git.breakpoint.cc/cgit/dborkman/net-next.git/log/?h=ebpf-fds-final5
>>>>
>>>> So the idea eventually had to be slightly modified after giving this
>>>> further
>>>> thoughts and is the following:
>>>>
>>>> We have 3 commands (BPF_DEV_CREATE, BPF_DEV_DESTROY, BPF_DEV_CONNECT), and
>>>> related to that a bpf_attr extension with only a single __u32 fd member
>>>> in it.
>>> ...
>>>> The nice thing about it is that you can create/unlink as many as you
>>>> want, but
>>>> when you remove the real device from an application via
>>>> bpf_dev_destroy(fd),
>>>> then all links disappear with it. Just like in the case of a normal
>>>> device driver.
>>>
>>> interesting idea!
>>> What happens if user app creates a dev via bpf_dev_create(), exits and
>>> then admin does rm of that dev ?
>>> Looks like map/prog will leak ?
>>> So the only proper way to delete such cdevs is via bpf_dev_destroy ?
>>
>> The mknod is not the holder but rather the kobject which should be
>> represented in sysfs will be. So you can still get the map major:minor
>> by looking up the /dev file in the correspdonding sysfs directory or I
>> think we should provide a 'unbind' file, which will drop the kobject if
>> the user writes a '1' to it.
>
> I agree, this could still be done.
>
>>>> On device creation, the kernel will return the minor number via bpf(2),
>>>> so you
>>>> can access the file easily, f.e. /dev/bpf/bpf_map<minor> resp.
>>>> /dev/bpf/bpf_prog<minor>,
>>>> and then move on with mknod(2) or symlink(2) from there if wished.
>>>
>>> what if admin mknod in that dir with some arbitrary minor ?
>>
>> Basically, -EIO. :)

If an admin does a mknod that has the major of a map or prog cdev, but a
not yet used minor, then connecting to that fails. And at the time when a
real device has been created with that assigned minor, then connecting to
it succeeds.

It's nothing different than with other devices in the system, f.e. ...

   # ls -la /dev/urandom
   crw-rw-rw-. 1 root root 1, 9 Oct 19 15:18 /dev/urandom
   # mknod ./foobar c 1 9

... will make random driver available under ./foobar as well.

If your question is rather on what happens when an admin does an ``mknod
/dev/bpf/bpf_map9 c 249 11'' and the device created has a minor of 9 and
/dev/bpf/bpf_map9 already exists in the system, then udev won't auto-create
or overwrite the node pointing to the major:minor there. The device itself
is being created nevertheless and visible under /sys/class/bpf/, but I think
this is a non-issue and nothing different from any other device drivers.

As Hannes said, under /sys/class/bpf/ an admin can see all held nodes, so
visibility is there for free at all times. The device management (creation/
deletion) itself and the mknod's pointing to it are simply decoupled.

This whole approach looks sound to me, also integrates nicely into the
existing Linux facilities, and works on top of every fs supporting special
files. Much cleaner than an extra file-system that would be required by a
syscall in order to make the syscall work.

>>> mknod will succeed, but it won't hold anything?
>>
>> That is right now true for basically all mknod operations, which udev
>> creates.
>>
>>> looks like bpf_dev_connect will handle it gracefully.
>>> So these cdevs should only be created and destroyed via bpf syscall
>>> and only sensible operations on them is open() to get fd and pass
>>> to bpf_dev_connect and symlink. Anything else admin should be
>>> careful not to do. Right?
>>
>> Besides maybe some statistics and other stuff in sysfs directory, no,
>> that is all.
>>
>> Bye,
>> Hannes
