From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 13:56:58 -0700
Message-ID: <5621649A.80403@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4f2io9l.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 12:53 PM, Eric W. Biederman wrote:
> Alexei Starovoitov <ast@plumgrid.com> writes:
>
>> On 10/16/15 11:41 AM, Eric W. Biederman wrote:
> [...]
>>> I am missing something.
>>>
>>> When I suggested using a filesystem it was my thought there would be
>>> exactly one superblock per map, and the map would be specified at mount
>>> time.  You clearly are not implementing that.
>>
>> I don't think it's practical to have sb per map, since that would mean
>> sb per prog and that won't scale.
>
> What do you mean won't scale?  You want to have a name per map/prog so the
> basic complexity appears the same.  Is there some crucial interaction
> between the persistent dodads you are placing on a filesystem that I am
> missing?
>
> Given the fact you don't normally need any persistence without a program
> I am puzzled why "scaling" is an issue of any kind.  This is for a
> comparitively rare case if I am not mistaken.

representing map as a directory tree with files as keys is indeed 'rare'
since it's mainly for debugging and slow accesses,
but 'pin_fd' functionality now popping up everywhere.
Mainly because in things like openstack there are tons of disjoint
libraries written in different languages and the only thing
common is kernel. So pin_fd/new_fd is a mandatory feature.

>> Also map today is an fd that belongs to a process. I cannot see
>> an api from C program to do 'mount of FD' that wouldn't look like
>> ugly hack.
>
> mount -t bpffs ... -o fd=1234
>
> That is not all convoluted or hacky.  Especially compared to some of the
> alternatives I am seeing.
>
> It is no problem at all to wrap something like that in a nice function
> call that has the exact same complexity of use as any of the other
> options that are being explored to give something that starts out
> as a filedescriptor a name.

Frankly, I don't think parsing 'fd=1234' string is a clean api, but
before we argue about fs philosophy of passing options, let's
get on the same page with requirements.
First goal that this patch is solving is providing an ability
to 'pin' an FD, so that map/prog won't disappear when user app exist.
Second goal of future patches is to expose map internals as a directory
structure.
These two goals are independent.
We can argue about api for 2nd, whether it's mount with fd=1234 string
or else, but for the first mount style doesn't make sense.

>>> A filesystem per map makes sense as you have a key-value store with one
>>> file per key.
>>>
>>> The idea is that something resembling your bpf_pin_fd function would be
>>> the mount system call for the filesystem.
>>>
>>> The the keys in the map could be read by "ls /mountpoint/".
>>> Key values could be inspected with "cat /mountpoint/key".
>>
>> yes. that is still the goal for follow up patches, but contained
>> within given bpffs. Something bpf_pin_fd-like command for bpf syscall
>> would create files for keys in a map and allow 'cat' via open/read.
>> Such api would be much cleaner from C app point of view.
>> Potentially we can allow mount of a file created via BPF_PIN_FD
>> that will expand into keys/values.
>> All of that are our future plans.
>> There, actually, the main contention point is 'how to represent keys
>> and values'. whether key is hex representation or we need some
>> pretty-printers via format string or via schema? etc, etc.
>> We tried few ideas of representing keys in our fuse implementations,
>> but don't have an agreement yet.
>
> My gut feel would be to keep it simple and use the same representation
> you use in your existing system calls.  Certainly ordinary filenames are
> keys of arbitrary binary data that can included everything except
> a '\0' byte.  That they are human readable is a nice convention, but not
> at all fundamental to what they are.

that doesn't work. map keys are never human readable. they're arbitrary
binary data. That's why representing them as file name is not trivial.
Some pretty-printer is needed.
Again that is 2nd goal of bpffs in general. We cannot really solve it
now, because we cannot say 'lets represent keys like X and work
from there', since that will become kernel ABI and we won't be able to
change that.
It's equally not clear that thousands of keys can even work as files.
So quite a bit of brainstorming still to do for this 2nd goal.
