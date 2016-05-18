From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC][PATCH net] bpf: Use mount_nodev not mount_ns to mount the
 bpf filesystem
Date: Wed, 18 May 2016 22:46:57 +0200
Message-ID: <bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
 <79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
 <87inybv2hv.fsf@x220.int.ebiederm.org> <573CD3D8.3030308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37761 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754041AbcERUrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 16:47:02 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 2986220CB8
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 16:47:01 -0400 (EDT)
In-Reply-To: <573CD3D8.3030308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2016 22:43, Daniel Borkmann wrote:
> On 05/18/2016 04:56 PM, Eric W. Biederman wrote:
>> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>>> On 18.05.2016 01:12, Eric W. Biederman wrote:
>>>>
>>>> While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
>>>> bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
>>>> with current->nsproxy->mnt_ns. As the code does not acquire a reference
>>>> to the mount namespace it can not possibly be correct to store the
>>>> mount
>>>> namespace on the superblock as it does.
>>>>
>>>> Replace mount_ns with mount_nodev so that each mount of the bpf
>>>> filesystem returns a distinct instance, and the code is not utterly
>>>> broken.
>>>>
>>>> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
>>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>>> ---
>>>>
>>>> No one should care about this change, as userspace typically only
>>>> mounts
>>>> things once and does not depend on things in one mount do not
>>>> showing up
>>>> in another.  Can someone who actually uses the bpf filesystem please
>>>> verify this.
> [...]
> 
> LGTM.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
>>> The idea is to have the bpf filesystem as a singeleton per mnt-namespace
>>> to prevent endless instances being created and kernel resources being
>>> hogged by pinning them to hard to discover bpf mounts.
> 
> Eric, please send the patch officially and feel free to add my Ack. Given
> the circumstances, moving to mount_nodev() seems the best way forward. To
> also address above mentioned concern from Hannes, we need to remove the
> FS_USERNS_MOUNT flag along with the change. It looks like the fix is best
> addressed in a single patch if you want to include it. If not, we can
> otherwise send it separately as well, I don't mind.

I agree. Would make most sense to make the change in one patch. Later on
we can reason about if it makes sense to use the net namespace to split
bpf maps and programs or maybe even introduce a new primitive for that.

Thanks,
Hannes
