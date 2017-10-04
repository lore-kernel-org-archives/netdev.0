From: Chenbo Feng <fengc@google.com>
Subject: Re: [PATCH net-next 1/4] bpf: Add file mode configuration into bpf maps
Date: Wed, 4 Oct 2017 16:58:05 -0700
Message-ID: <CAMOXUJnpuvZjF7fiPXB+3ao0fopm6kS6Y9tACh8trq4PKG0RsA@mail.gmail.com>
References: <20171004182932.140028-1-chenbofeng.kernel@gmail.com>
 <20171004182932.140028-2-chenbofeng.kernel@gmail.com> <59D56EED.1030804@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org,
        Jeffrey Vander Stoep <jeffv@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <59D56EED.1030804@iogearbox.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 4, 2017 at 4:29 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/04/2017 08:29 PM, Chenbo Feng wrote:
>>
>> From: Chenbo Feng <fengc@google.com>
>>
>> Introduce the map read/write flags to the eBPF syscalls that returns the
>> map fd. The flags is used to set up the file mode when construct a new
>> file descriptor for bpf maps. To not break the backward capability, the
>> f_flags is set to O_RDWR if the flag passed by syscall is 0. Otherwise
>> it should be O_RDONLY or O_WRONLY. When the userspace want to modify or
>> read the map content, it will check the file mode to see if it is
>> allowed to make the change.
>
> [...]
>>
>> +int bpf_get_file_flag(int flags)
>> +{
>> +       if ((flags & BPF_F_RDONLY) && (flags & BPF_F_WRONLY))
>> +               return -EINVAL;
>> +       if (flags & BPF_F_RDONLY)
>> +               return O_RDONLY;
>> +       if (flags & BPF_F_WRONLY)
>> +               return O_WRONLY;
>> +       return O_RDWR;
>>   }
>>
>>   /* helper macro to check that unused fields 'union bpf_attr' are zero */
>> @@ -345,12 +376,17 @@ static int map_create(union bpf_attr *attr)
>>   {
>>         int numa_node = bpf_map_attr_numa_node(attr);
>>         struct bpf_map *map;
>> +       int f_flags;
>>         int err;
>>
>>         err = CHECK_ATTR(BPF_MAP_CREATE);
>>         if (err)
>>                 return -EINVAL;
>>
>> +       f_flags = bpf_get_file_flag(attr->map_flags);
>> +       if (f_flags < 0)
>> +               return f_flags;
>
>
> Wait, I just noticed, given you add BPF_F_RDONLY/BPF_F_WRONLY
> to attr->map_flags, and later go into find_and_alloc_map(),
> for map alloc, which is e.g. array_map_alloc(). There, we
> bail out with EINVAL on attr->map_flags & ~BPF_F_NUMA_NODE,
> which is the case for both BPF_F_RDONLY/BPF_F_WRONLY ... I
> would have expected that the entire code was tested properly;
> what was tested exactly in the set?
>

Thanks for pointing out this, my test for the patch create the map
with RD/WR flag which is 0.... that's why I didn't catch this. And
bpf_obj_get do not have similar checks for map_flags.
>>         if (numa_node != NUMA_NO_NODE &&
>>             ((unsigned int)numa_node >= nr_node_ids ||
>>              !node_online(numa_node)))
>> @@ -376,7 +412,7 @@ static int map_create(union bpf_attr *attr)
>>         if (err)
>>                 goto free_map;
>>
>> -       err = bpf_map_new_fd(map);
>> +       err = bpf_map_new_fd(map, f_flags);
>>         if (err < 0) {
>>                 /* failed to allocate fd.
>>                  * bpf_map_put() is needed because the above
>> @@ -491,6 +527,11 @@ static int map_lookup_elem(union bpf_attr *attr)
>
> [...]
