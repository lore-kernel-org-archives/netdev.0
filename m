From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Sat, 17 Oct 2015 19:20:41 -0700
Message-ID: <562301F9.1030702@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
 <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com>
 <56223F00.5030203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56223F00.5030203@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/15 5:28 AM, Daniel Borkmann wrote:
>
> Anyway, another idea I've been brainstorming with Hannes today a
> bit is about the following:
>
> We register two major numbers, one for eBPF maps (X), one for eBPF
> progs (Y). A user can either via cmdline call something like ...
> mknod /dev/bpf/maps/map_pkts c X Z to create a special character
> device, or alternatively out of an application through mknod(2)
> syscall (f.e. tc when setting up maps/progs internally from the obj
> file for a classifer).
>
> Then, we still have 2 eBPF commands for bpf(2) syscall to add, say
> (for example) BPF_BIND_DEV and BPF_FETCH_DEV. The application that
> created a map (or prog) already has the map fd and after mknod(2) it
> can open(2) the special file to get the special file fd. Then it can
> call something like bpf(BPF_BIND_DEV, &attr, sizeof(attr))) where
> attr looks like:
>
>    union bpf_attr attr = {
>      .bpf_fd    = bpf_fd,
>      .dev_fd    = dev_fd,
>    };
>
> The bpf(2) syscall can check whether dev_fd belongs to an eBPF special
> file and it can then copy over file->private_data from the bpf_fd
> to the dev_fd's underlying file, where the private_data, as we know,
> from the bpf_fd already points to a proper bpf_map/bpf_prog structure.
> The map/prog would then get ref'ed and lives onwards in the char device's
> lifetime. No special hashtable, gc, etc needed. The char device has fops
> that we can define by ourself, and unlinking would drop the ref from
> its private_data.
>
> Now to the other part: BPF_FETCH_DEV would work similar. The application
> opens the device, and fills bpf_attr as follows again:
>
>    union bpf_attr attr = {
>      .bpf_fd    = 0,
>      .dev_fd    = dev_fd,
>    };
>
> This would allow us to look up the map/prog from the dev_fd's file->
> private_data, and installs a new fd via bpf_{map,prog}_new_fd() that
> is returned from bpf(2) for bpf-related access. The remaining fops
> from the char device could still be reserved for possibilities like
> debugging in future.
>
> Now in future (2nd step), could either be to use Eric's idea and then do
> something like mount -t bpffs ... -o /dev/bpf/maps/map_pkts to dump
> attributes or other properties to some location for inspection from such
> a special file, or we could use kobjects for that attached to the device
> if the fops from the cdev should not be sufficient.
>
> So closing the loop to the special files where there were concerns:
>
> This won't forbid to have a future shell-style access possibility, and
> it would also not end up as a nightmare on what you mentioned with the
> S_ISSOCK-like bit in the other email.
>
> The pinning mechanism would not require an extra file system to be mounted
> somewhere, and yet the user can define himself an arbitrary hierarchy
> where he puts the special files as this facility already exists. An
> approach like this looks overall cleaner to me, and most likely be
> realizable in fewer lines of code as well.
>
> Thoughts?

that indeed sounds cleaner, less lines of code, no fs, etc, but
I don't see how it will work yet.
For chardev with our own ops we can be triggered on open and close
of that chardev, so replacing private_data will be cleared when
user process does close(dev_fd) ? There is no fops for unlink either,
it's fs only property ?
