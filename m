From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH net] bpf: Use mount_nodev not mount_ns to mount the bpf filesystem
Date: Wed, 18 May 2016 09:56:28 -0500
Message-ID: <87inybv2hv.fsf@x220.int.ebiederm.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
	<79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47718 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbcERPIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 11:08:00 -0400
In-Reply-To: <79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
	(Hannes Frederic Sowa's message of "Wed, 18 May 2016 12:48:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> On 18.05.2016 01:12, Eric W. Biederman wrote:
>> 
>> While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
>> bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
>> with current->nsproxy->mnt_ns. As the code does not acquire a reference
>> to the mount namespace it can not possibly be correct to store the mount
>> namespace on the superblock as it does.
>> 
>> Replace mount_ns with mount_nodev so that each mount of the bpf
>> filesystem returns a distinct instance, and the code is not utterly
>> broken.
>> 
>> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> 
>> No one should care about this change, as userspace typically only mounts
>> things once and does not depend on things in one mount do not showing up
>> in another.  Can someone who actually uses the bpf filesystem please
>> verify this.
>> 
>> This needs to be fixed as the existing code is broken beyond words that
>> I know how to express.
>
> The idea is to have the bpf filesystem as a singeleton per mnt-namespace
> to prevent endless instances being created and kernel resources being
> hogged by pinning them to hard to discover bpf mounts.

There is no method in the kernel to support a singleton per mount
namespace.  Mount propagation ruins that idea, and in most recent
distros mount propgation is enabled by default (it is something you can
opt out of later but not opt into later).

In general convention is a much better defense against endless
instances.

Having just fought a similar fight with devpts (because things went
horribly wrong) you are much better off with telling people to be careful
how to use things rather than not letting people use things wrong.
Especially if we are still at the "the idea is" stage rather than a
stage where changing this will actually break deployed implementations.

> Do you see any problem with adding appropriate reference counts?

Honestly my head hurts thinking about it.  Technically reference counts
would fix one aspect of it, but the whole situation really sucks.

Especially in a world of mount propgation where these mounts propgate
between mount namespaces, and where people choose to share or not on a
different criteria besides the mount namespace, attempting a one fs per
mount namespace policy is just bizarre bordering on completely broken.
Even if implemented correctly.

Filesystems do not know and should not care about the mount namespace
they are implemented it.  These are and should remain independent
concenpts and your implementation and attempted semantics violate that
horribly and I can't see a way to achieve what you were trying to
achieve.  The VFS just doesn't work that way.

Eric
