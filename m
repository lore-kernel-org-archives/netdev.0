From: Jeffrey Vander Stoep <jeffv@google.com>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security field
 to eBPF map
Date: Thu, 31 Aug 2017 22:50:45 -0700
Message-ID: <CABXk95AaepfP94aPZM6kOBgKVM8e2Ma8g63DLdpOLAAyDF=eSQ@mail.gmail.com>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
 <20170831205635.80256-3-chenbofeng.kernel@gmail.com> <20170901020520.uifv6b7tvelgxumf@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        LSM List <linux-security-module@vger.kernel.org>,
        netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170901020520.uifv6b7tvelgxumf@ast-mbp>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 7:05 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Aug 31, 2017 at 01:56:34PM -0700, Chenbo Feng wrote:
>> From: Chenbo Feng <fengc@google.com>
>>
>> Introduce a pointer into struct bpf_map to hold the security information
>> about the map. The actual security struct varies based on the security
>> models implemented. Place the LSM hooks before each of the unrestricted
>> eBPF operations, the map_update_elem and map_delete_elem operations are
>> checked by security_map_modify. The map_lookup_elem and map_get_next_key
>> operations are checked by securtiy_map_read.
>>
>> Signed-off-by: Chenbo Feng <fengc@google.com>
>
> ...
>
>> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>>       if (IS_ERR(map))
>>               return PTR_ERR(map);
>>
>> +     err = security_map_read(map);
>> +     if (err)
>> +             return -EACCES;
>> +
>>       key = memdup_user(ukey, map->key_size);
>>       if (IS_ERR(key)) {
>>               err = PTR_ERR(key);
>> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
>>       if (IS_ERR(map))
>>               return PTR_ERR(map);
>>
>> +     err = security_map_modify(map);
>
> I don't feel these extra hooks are really thought through.
> With such hook you'll disallow map_update for given map. That's it.
> The key/values etc won't be used in such security decision.
> In such case you don't need such hooks in update/lookup at all.
> Only in map_creation and object_get calls where FD can be received.
> In other words I suggest to follow standard unix practices:
> Do permissions checks in open() and allow read/write() if FD is valid.
> Same here. Do permission checks in prog_load/map_create/obj_pin/get
> and that will be enough to jail bpf subsystem.
> bpf cmds that need to be fast (like lookup and update) should not
> have security hooks.
>

I do think we want to distinguish between read/write (or read/modify)
for these objects. Essentially, we want to implement the example
described in patch 0/3 where eBPF objects can be passed to less
privileged processes which can read, but not modify the map. What
would be the best way to do this? Add a mode field to the bpf_map
struct?
