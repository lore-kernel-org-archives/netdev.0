From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 21:54:42 +0200
Message-ID: <56215602.6070101@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net> <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56214FAC.5060704@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2015 09:27 PM, Alexei Starovoitov wrote:
> On 10/16/15 11:41 AM, Eric W. Biederman wrote:
>> Daniel Borkmann <daniel@iogearbox.net> writes:
>>> On 10/16/2015 07:42 PM, Alexei Starovoitov wrote:
>>>> On 10/16/15 10:21 AM, Hannes Frederic Sowa wrote:
>>>>> Another question:
>>>>> Should multiple mount of the filesystem result in an empty fs (a new
>>>>> instance) or in one were one can see other ebpf-fs entities? I think
>>>>> Daniel wanted to already use the mountpoint as some kind of hierarchy
>>>>> delimiter. I would have used directories for that and multiple mounts
>>>>> would then have resulted in the same content of the filesystem. IMHO
>>>>> this would remove some ambiguity but then the question arises how this
>>>>> is handled in a namespaced environment. Was there some specific reason
>>>>> to do so?
>>>>
>>>> That's an interesting question!
>>>> I think all mounts should be independent.
>>>> I can see tracing using one and networking using another one
>>>> with different hierarchies suitable for their own use cases.
>>>> What's an advantage to have the same content everywhere?
>>>> Feels harder to manage, since different users would need to
>>>> coordinate.
>>>
>>> I initially had it as a mount_single() file system, where I was thinking
>>> to have an entry under /sys/fs/bpf/, so all subsystems would work on top
>>> of that mount point, but for the same reasons above I lifted that restriction.
>>
>> I am missing something.
>>
>> When I suggested using a filesystem it was my thought there would be
>> exactly one superblock per map, and the map would be specified at mount
>> time.  You clearly are not implementing that.
>
> I don't think it's practical to have sb per map, since that would mean
> sb per prog and that won't scale.
> Also map today is an fd that belongs to a process. I cannot see
> an api from C program to do 'mount of FD' that wouldn't look like
> ugly hack.
>
>> A filesystem per map makes sense as you have a key-value store with one
>> file per key.
>>
>> The idea is that something resembling your bpf_pin_fd function would be
>> the mount system call for the filesystem.
>>
>> The the keys in the map could be read by "ls /mountpoint/".
>> Key values could be inspected with "cat /mountpoint/key".
>
> yes. that is still the goal for follow up patches, but contained
> within given bpffs. Something bpf_pin_fd-like command for bpf syscall
> would create files for keys in a map and allow 'cat' via open/read.
> Such api would be much cleaner from C app point of view.
> Potentially we can allow mount of a file created via BPF_PIN_FD
> that will expand into keys/values.

Yeah, sort of making this an optional debugging facility if anything (maybe
to just get a read-only snapshot view). Having maps with a very large number
of entries might end up being problematic by its own, or mapping potential
future map candidates such as rhashtable.

> There, actually, the main contention point is 'how to represent keys
> and values'. whether key is hex representation or we need some
> pretty-printers via format string or via schema? etc, etc.
> We tried few ideas of representing keys in our fuse implementations,
> but don't have an agreement yet.

That is unclear as well to make it useful.
