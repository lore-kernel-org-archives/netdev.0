From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2] filter: added BPF random opcode
Date: Mon, 21 Apr 2014 19:42:29 -0700
Message-ID: <CAMEtUuwRFi0S9SFhaoBL34Oar95JdS+4byGCsfm=1yDENWUseg@mail.gmail.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<1398097284-20528-1-git-send-email-chema@google.com>
	<CAMEtUuw=trzxSC9Dc+UAEU5HyHk1Ym3cW7L+7tmvOe2hzHmXMw@mail.gmail.com>
	<CA+ZOOTNnfUkqLT9wrmoHtP+-a5+7UzLvO0qeNjtknZX1K9kn3g@mail.gmail.com>
	<CAMEtUuzBuK+82EvvSZmBTJtTJcTr0-r-AMOUNnYqF7aoQgtLdA@mail.gmail.com>
	<CA+ZOOTMr6_vTS36Nuk-azKdkAu7xmNSRARXb4eomuY2p=Q_=zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64782 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbaDVCmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 22:42:31 -0400
Received: by mail-we0-f174.google.com with SMTP id t60so4298092wes.5
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 19:42:30 -0700 (PDT)
In-Reply-To: <CA+ZOOTMr6_vTS36Nuk-azKdkAu7xmNSRARXb4eomuY2p=Q_=zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 4:19 PM, Chema Gonzalez <chema@google.com> wrote:
> On Mon, Apr 21, 2014 at 3:20 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> Nice. Now I see where it's going :)
>> The article helps a lot.
> Note that the paper implementation is slightly different from the one
> here: It was implemented for the BSD engine (therefore BSD or userland
> only). Also, random was implemented as a new load mode (called "ldr"),
> instead of an ancillary load. This, in retrospective, was a mistake:
> Ancillary load is a much simpler solution, doesn't require disabling
> the BSD BPF optimizer, and allows straightforward JITing. Also, when I
> think about a generic ISA, random is an OS call, not a ISA insn (I
> guess rdrand is an exception).
>
> While orthogonal to the load mode/ancillary load implementation, the
> main advantage of the old patch is that it used its own LCG-based
> PRNG, which allowed userland seeding (this is very important in
> testing and debugging). It also provided an extension of the tcpdump
> language, so you could add filters like "tcp and random 4 == 1" (which
> would sample 1 in 4 tcp packets).
>
>> btw it's funny how different people think of similar things.
>> It seems to complete what you wanted in the article you'd need
>> table access from the filter.
>> Did you have a chance to look at my bpf table proposal?
> I haven't had time.
>
> BTW, I like your eBPF work a lot. In fact, I like it so much that I
> decided to dust off the BPF random patch and send it to the list. I
> see eBPF as the final push of BPF from a special-purpose ISA
> (packet-filtering) to a generic-purpose one. This is the natural
> evolution of the seccomp-bpf work. In fact, I see BPF as an ISA in the
> kernel that can be used as *the* safe method to run stateful,
> user-provided functions in the kernel.

Thanks :)

>> It seems it will fit perfectly to your use case as well.
>>
>> Here is the copy paste from the other thread:
>> -----
>> Similar basic interface I'm proposing to use for bpf tables.
>> Probably makes sense to drop 'bpf' prefix, since they're just
>> hash tables. Little to do with bpf.
>> Have a netlink API from user into kernel:
>> - create hash table (num_of_entries, key_size, value_size, id)
>> - dump table via netlink
>> - add/remove key/value pair
>> Some kernel module may use it to transfer the data between
>> kernel and userspace.
>> This can be a generic kernel/user data sharing facility.
>>
>> Also let bpf programs do 'table_lookup/update', so that
>> filters can store interesting data.
>> --------
>> I've posted early bpf_table patches back in September...
>> Now in process of redoing them with cleaner interface.
>
> Persistent (inter-packet) state is a (way) more complicated issue than
> basic randomness. You're adding state that lives from one packet to
> the next one. In principle, I like your laundry list.
>
> - external create/init/read/write access to the tables(s). netlink
> sounds a good solution
> - external add/remove key[/value] entry. netlink again

I'm thinking about 'tables' and 'bpf filters' as complementary
and related, but independent and decoupled kernel mechanisms.
'tables' are kernel/user sharing facility available to root only.
If filter is loaded by the root, bpf verifier will allow access to
given tables.
tables can be used by kernel modules too without bpf around.

I'm not sure yet that we need to let unprivileged users create tables.
nids use case, tracing filters and ovs+bpf cases will do with root only.

Though I think it's ok to have per-user limit of N tables of M size.
Filters loaded by the same user will have access to user's tables.

> But still have many questions that give me pause:
>
> - safety: what I like best about BPF is that it's proved itself safe
> in 20+ years. We need to be very careful not to introduce issues. In

we need to be careful, but cannot stand still.
I'll try to phase in ebpf verifier in small bites with as many details
as possible.
In particular DAG check will come first, since it's needed
for classic bpf already to prevent unreachable code.

> particular, I've had discussions over the possibility of leaking
> entropy through BPF
> - what's the right approach to add state? I'd expect BPF to provide a
> lump buffer, and let the filters to use that buffer according to their
> needs. While a hash table is a good solution, I can see how users may
> prefer other data structures (e.g. Bloom filters)

correct. bloom filters can be one of the table types.
So far we have use cases for hash, hash+lru, lpm types.

> - how many hash tables? Which types? In principle, you can implement
> flow sampling with a couple of Bloom filters. They're very efficient
> memory-wise

I think there is no limit to the number of root's tables.
The table is defined by:
- table_id
- table type (hash, bloom, etc)
- max number of elements
- key size in bytes
- value size in bytes

API from user space:
- create/delete table
- add/remove/read element

API from kernel module or from bpf program:
- add/remove/read element
(kernel module and bpf loader also do table hold/release)

> - what about the hash function(s)? This should be configurable

for hash table itself? I'm not sure what it really buys us, but we can
have two hash types: one hashes provided key, another takes
key and hash from filter.
Then filter itself is responsible for hashing the key the way it wants.

> - what about space limits? I can see how some of my problems require
> BPF tables in the GB sizes. Is this an issue for anybody? Is this an
> issue at all?

if root allocates them, then I think it's not a problem.
for regular users we may want to have a limit just like max file descr,
for user's own safety.
In the near future I'm proposing it for root only.

> - where should the state live? Should we have common-CPU persistent
> state, or also per-CPU state. Probably both are nice

agree. we were debating about it internally too. In current
implementation every table element is not per-cpu.

from bpf program the access is like:
rcu_read_lock()
enter bpf filter
...
ptr_to_value = bpf_table_lookup(const_int_table_id, key)
access memory [ptr_to_value, ptr_to_value + value_size_in_bytes]
...
prepare key2 and value2 on stack of key_size and value_size
err = bpf_table_update(const_int_table_id2, key2, value2)
...
leave bpf filter
rcu_read_unlock()

bpf filter cannot create or delete a table.
During filter loading verifier does table_hold() on the tables that filter
may access, so they don't get deleted while filter is running

bpf_table_update() can fail if max_elements reached.
if key2 already exists, bpf_table_update() replaces it with value2 atomically

bpf_table_lookup() can return null or ptr_to_value
ptr_to_value is read/write from bpf program point of view.

> The solution discussed in the paper above was too strict (simple Bloom
> filters, mistakenly named "hash" tables). We also *really* wanted to
> be able to run tcpdump filters, so we extended the tcpdump language
> syntax. In retrospective, an asm-like syntax like the one used by
> bpf_asm is way better.

imo C is more readable than both tcpdump and asm, but we will
have asm as a minimum. Eventually C and other languages.

> I'll definitely be interested in seeing your new proposal when it's ready.

patches speak better than words. will get it ready.

Thanks!

> -Chema
