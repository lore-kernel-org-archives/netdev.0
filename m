From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 09:18:46 -0700
Message-ID: <56212366.4000307@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, ebiederm@xmission.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 3:25 AM, Hannes Frederic Sowa wrote:
> Namespaces at some point dealt with the same problem, they nowadays use
> bind mounts of/proc/$$/ns/* to some place in the file hierarchy to keep
> the namespace alive. This at least allows someone to build up its own
> hierarchy with normal unix tools and not hidden inside a C-program. For
> filedescriptors we already have/proc/$$/fd/* but it seems that doesn't
> work out of the box nowadays.

bind mounting of /proc/../fd was initially proposed by Andy and we've
looked at it thoroughly, but after discussion with Eric it became
apparent that it doesn't fit here. At the end we need shell tools
to access maps.
Also I think you missed the hierarchy in this patch set _is_ built with
normal 'mkdir' and files are removed with 'rm'.
The only thing that C does is BPF_PIN_FD of fd that was received from
bpf syscall. That's way cleaner api than doing bind mount from C
program.
We've considered letting open() of the file return bpf specific
anon-inode, but decided to reserve that for other more natural file
operations. Therefore BPF_NEW_FD is needed.

> I don't know in terms of how many objects bpf should be able to handle
> and if such a bind-mount based solution would work, I guess not.

We definitely missed you at the last plumbers where it was discussed :)

> In my opinion I still favor a user space approach.

that's not acceptable for tracing use cases. No daemons allowed.

> Subsystems which use
> ebpf in a way that no user space program needs to be running to control
> them would need to export the fds by itself. E.g. something like
> sysfs/kobject for tc? The hierarchy would then be in control of the
> subsystem which could also create a proper naming hierarchy or maybe
> even use an already given one. Do most other eBPF users really need to
> persist file descriptors somewhere without user space control and pick
> them up later?

I think it's way cleaner to have one way of solving it (like this patch
does) instead of asking every subsystem to solve it differently.
We've also looked at sysfs and it's ugly when it comes to removing,
since the user cannot use normal 'rm'.
