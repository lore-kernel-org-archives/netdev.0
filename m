From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V8 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Tue, 17 Oct 2017 16:00:31 +0200
Message-ID: <59E60CFF.5010203@iogearbox.net>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>        <150814916887.1806.4443991765779135803.stgit@firesoul>        <20171016214951.bia3esapu5o2niva@ast-mbp.dhcp.thefacebook.com> <20171017124729.59e45c74@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56580 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758740AbdJQOAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 10:00:39 -0400
In-Reply-To: <20171017124729.59e45c74@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 12:47 PM, Jesper Dangaard Brouer wrote:
> On Mon, 16 Oct 2017 14:49:53 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>
>> On Mon, Oct 16, 2017 at 12:19:28PM +0200, Jesper Dangaard Brouer wrote:
>>> The 'cpumap' is primarily used as a backend map for XDP BPF helper
>>> call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
>>>
>>> This patch implement the main part of the map.  It is not connected to
>>> the XDP redirect system yet, and no SKB allocation are done yet.
>>>
>>> The main concern in this patch is to ensure the datapath can run
>>> without any locking.  This adds complexity to the setup and tear-down
>>> procedure, which assumptions are extra carefully documented in the
>>> code comments.
>>>
>>> V2:
>>>   - make sure array isn't larger than NR_CPUS
>>>   - make sure CPUs added is a valid possible CPU
>>>
>>> V3: fix nitpicks from Jakub Kicinski <kubakici@wp.pl>
>>>
>>> V5:
>>>   - Restrict map allocation to root / CAP_SYS_ADMIN
>>>   - WARN_ON_ONCE if queue is not empty on tear-down
>>>   - Return -EPERM on memlock limit instead of -ENOMEM
>>>   - Error code in __cpu_map_entry_alloc() also handle ptr_ring_cleanup()
>>>   - Moved cpu_map_enqueue() to next patch
>>>
>>> V6: all notice by Daniel Borkmann
>>>   - Fix err return code in cpu_map_alloc() introduced in V5
>>>   - Move cpu_possible() check after max_entries boundary check
>>>   - Forbid usage initially in check_map_func_compatibility()
>>>
>>> V7:
>>>   - Fix alloc error path spotted by Daniel Borkmann
>>>   - Did stress test adding+removing CPUs from the map concurrently
>>>   - Fixed refcnt issue on cpu_map_entry, kthread started too soon
>>>   - Make sure packets are flushed during tear-down, involved use of
>>>     rcu_barrier() and kthread_run only exit after queue is empty
>>>   - Fix alloc error path in __cpu_map_entry_alloc() for ptr_ring
>>>
>>> V8:
>>>   - Nitpicking comments and gramma by Edward Cree
>>>   - Fix missing semi-colon introduced in V7 due to rebasing
>>>   - Move struct bpf_cpu_map_entry members cpu+map_id to tracepoint patch
>>>
>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>> ---
>>>   include/linux/bpf_types.h      |    1
>>>   include/uapi/linux/bpf.h       |    1
>>>   kernel/bpf/Makefile            |    1
>>>   kernel/bpf/cpumap.c            |  560 ++++++++++++++++++++++++++++++++++++++++
>>>   kernel/bpf/syscall.c           |    8 +
>>>   kernel/bpf/verifier.c          |    5
>>>   tools/include/uapi/linux/bpf.h |    1
>>>   7 files changed, 576 insertions(+), 1 deletion(-)
>>>   create mode 100644 kernel/bpf/cpumap.c
>>
>> Looks good to me
>> I like the idea of running networking stack from kthread
>> and hope adding GRO won't change the api.
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
> Thanks!
>
> I think adding GRO is still safe API-wise after this patchset.  I
> imagine that the GRO API will be tied to how we implement/expose the
> RX-hash to the eBPF program.  Thus, the API will be the eBPF prog can
> change the RX-hash, to influence the GRO aggregation/partial-sort. If
> the map need to behave differently for GRO then we have the map_flags
> to adjust this behavior (but I assume this would not be needed).

+1, this should happen transparent to the user. But would it mean that
the cpumap threads get a fake napi_struct for napi_gro_receive() or
would it require larger refactoring/splitting of gro engine internals?
Would be good to have a clearer picture on that before uapi freezes.

Thanks,
Daniel
