From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V4 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Fri, 06 Oct 2017 16:52:40 +0200
Message-ID: <59D798B8.8090101@iogearbox.net>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>      <150711862505.9499.15042356194495111353.stgit@firesoul> <59D5FDFF.5040002@iogearbox.net> <20171006125008.676d5eaf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Tobias Klauser <tklauser@distanz.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59219 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751925AbdJFOwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 10:52:46 -0400
In-Reply-To: <20171006125008.676d5eaf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2017 12:50 PM, Jesper Dangaard Brouer wrote:
> On Thu, 05 Oct 2017 11:40:15 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 10/04/2017 02:03 PM, Jesper Dangaard Brouer wrote:
>> [...]
>>> +#define CPU_MAP_BULK_SIZE 8  /* 8 == one cacheline on 64-bit archs */
>>> +struct xdp_bulk_queue {
>>> +	void *q[CPU_MAP_BULK_SIZE];
>>> +	unsigned int count;
>>> +};
>>> +
>>> +/* Struct for every remote "destination" CPU in map */
>>> +struct bpf_cpu_map_entry {
>>> +	u32 cpu;    /* kthread CPU and map index */
>>> +	int map_id; /* Back reference to map */
>>
>> map_id is not used here if I read it correctly? We should
>> then remove it.
>
> It is actually used in a later patch. Notice, there is no unused
> members in the final patch.  I did consider adding back in the later
> patch, but it was annoying to during the devel and split-up patch
> phase, as it creates conflicts when I move between the different
> patches, that need to modify this struct.  Thus, I choose to keep the
> end-struct in this cpumap-base-patch.  If you insist, I can go though
> the patch-stack and carefully introduce changes to the struct in steps?

It would be great to have every patch as self-contained as possible
since it otherwise makes reviewing much more time consuming to check
through the other patches for possible usage patterns, I noticed you
are using it for the tracepoints in patch 4/5 to dump map_id. Would
definitely be good if you could avoid such split in future sets.

[...]
>>> +void __cpu_map_queue_destructor(void *ptr)
>>> +{
>>> +	/* For now, just catch this as an error */
>>> +	if (!ptr)
>>> +		return;
>>> +	pr_err("ERROR: %s() cpu_map queue was not empty\n", __func__);
>>
>> Can you elaborate on this "for now" condition? Is this a race
>> when kthread doesn't consume queue on thread exit, or should it
>> be impossible to trigger (should it then be replaced with a
>> 'if (WARN_ON_ONCE(ptr)) page_frag_free(ptr)' and a more elaborate
>> comment)?
>
> The "for now" is an old comment while developing and testing this.
> In this final state of the patchset it _should_ not be possible to
> trigger this situation.  I like your idea of replacing it with a
> WARN_ON_ONCE.  (as it might be good to keep in some form, as it would
> catch is someone changing the code which breaks the RCU+WQ+kthread
> tear-down procedure).

Ok.

[...]
>>> +		/* Updating qsize cause re-allocation of bpf_cpu_map_entry */
>>> +		rcpu = __cpu_map_entry_alloc(qsize, key_cpu, map->id);
>>> +		if (!rcpu)
>>> +			return -ENOMEM;
>>> +	}
>>> +	rcu_read_lock();
>>> +	__cpu_map_entry_replace(cmap, key_cpu, rcpu);
>>> +	rcu_read_unlock();
>>> +	return 0;
>>
>> You need to update verifier such that this function cannot be called
>> out of an BPF program,
>
> In the example BPF program, I do a lookup into the map, but only to
> verify that an entry exist (I don't look at the value).  I would like
> to support such usage.

Ok, put comment below.

>> otherwise it would be possible under full RCU
>> read context, which is explicitly avoided here and also it would otherwise
>> be allowed for other maps of different type as well, which needs to
>> be avoided.
>
> Sorry, I don't follow this.

What I meant is that check_map_func_compatibility() should check for
BPF_MAP_TYPE_CPUMAP and only allow func_id of BPF_FUNC_redirect_map
and BPF_FUNC_map_lookup_elem to be used, which I haven't seen the set
restricting it to. Some of your later patches do this for the helper
BPF_FUNC_redirect_map but the important point is that map updates
wouldn't be done out of the BPF program itself, but rather from user
space control path given they can't be done under full RCU read lock
context if I read this correctly (which the programs run in though).

[...]
>>> +static void *cpu_map_lookup_elem(struct bpf_map *map, void *key)
>>> +{
>>> +	struct bpf_cpu_map_entry *rcpu =
>>> +		__cpu_map_lookup_elem(map, *(u32 *)key);
>>> +
>>> +	return rcpu ? &rcpu->qsize : NULL;
>>
>> The qsize doesn't seem used anywhere else besides here, but you
>> probably should update verifier such that this cannot be called
>> out of the BPF program, which could then mangle qsize value.
>
> It is true that the BPF prog can modify this qsize value, but it's not
> the authoritative value, so it doesn't really matter.
>
> As I said above, I do want to do a lookup from a BPF program.  To allow
> to BPF program to know, if an entry is valid, else it will blindly
> send to a cpu destination.  Maybe bpf_prog's just have to use a
> map-on-the-side to coordinate this(?), but then a sysadm modifying the
> real cpumap will be invisible to the program.
>
> Maybe we should just disable BPF-progs from reading this in the first
> iteration?  It would allow for more advanced usage schemes later..

Okay, what you could do is the following to prevent unintended value
updates. Just read out the qsize from the value and put that into a
per-cpu scratch buffer that gets returned instead of the map value,
so even if the scratch buffer gets mangled, it's okay because the
actual map value doesn't. Verifier still checks the map value access
bounds for that one.

> One crazy idea is to have the cpu_map_lookup_elem() return if any
> packets are in-flight on this cpu-queue. (Making it easier to avoid OoO
> packets, when switching target CPU, but it can also be implemented by
> the BPF-programmer herself via maps, although via some extra atomic
> cost).
>
>>> +}
>>> +
>>> +static int cpu_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
>>> +{
>>> +	struct bpf_cpu_map *cmap = container_of(map, struct bpf_cpu_map, map);
>>> +	u32 index = key ? *(u32 *)key : U32_MAX;
>>> +	u32 *next = next_key;
>>> +
>>> +	if (index >= cmap->map.max_entries) {
>>> +		*next = 0;
>>> +		return 0;
>>> +	}
>>> +
>>> +	if (index == cmap->map.max_entries - 1)
>>> +		return -ENOENT;
>>> +	*next = index + 1;
>>> +	return 0;
>>> +}
>
> I would have liked to have implemented next_key so it only returned the
> next valid cpu_entry, and used it as a simple round-robin scheduler.
> But AFAIK the next_key function is not allowed from bpf_prog's, right?

Hm, true we don't export this as a helper right now, I currently don't
see a reason why we couldn't. For the array map, the get_next_key is
probably not too useful given we only return key + 1. For user space it
might help for iterating/dumping the map though. Probably one could
enable it and add a flag to search the next valid entry from the map,
though issue could well be that this might need to iterate/test millions
of empty slots until you get to the next valid one which might not be
suitable in a generic case to do out of a BPF prog, perhaps a second
map with keys to round robin over might help.

Cheers,
Daniel
