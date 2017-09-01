From: Chenbo Feng <fengc@google.com>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security field
 to eBPF map
Date: Thu, 31 Aug 2017 17:29:42 -0700
Message-ID: <CAMOXUJmW7-mOaWq1=qa8FXpvHdXSdAfDSboR-QN-u6DPkkCkkg@mail.gmail.com>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
 <20170831205635.80256-3-chenbofeng.kernel@gmail.com> <59A88FF0.9010605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        linux-security-module@vger.kernel.org,
        Jeffrey Vander Stoep <jeffv@google.com>,
        netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <59A88FF0.9010605@iogearbox.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 3:38 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/31/2017 10:56 PM, Chenbo Feng wrote:
>>
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
>
> Against which tree is this by the way, net-next? There are
> changes here which require a rebase of your set.
>

This patch series is rebased on security subsystem since patch 1/3 is
a patch for
security system I assume. But I am not sure where this specific patch
should go in.
If I should submit this one to net-next, I will rebase it against
net-next and submit again.
>> ---
>>   include/linux/bpf.h  |  3 +++
>>   kernel/bpf/syscall.c | 28 ++++++++++++++++++++++++++++
>>   2 files changed, 31 insertions(+)
>>
>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index b69e7a5869ff..ca3e6ff7091d 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -53,6 +53,9 @@ struct bpf_map {
>>         struct work_struct work;
>>         atomic_t usercnt;
>>         struct bpf_map *inner_map_meta;
>> +#ifdef CONFIG_SECURITY
>> +       void *security;
>> +#endif
>>   };
>>
>>   /* function argument constraints */
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index 045646da97cc..b15580bcf3b1 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -279,6 +279,10 @@ static int map_create(union bpf_attr *attr)
>>         if (err)
>>                 return -EINVAL;
>>
>> +       err = security_map_create();
>
>
> Seems a bit limited to me, don't you want to be able to
> also differentiate between different map types? Same goes
> for security_prog_load() wrt prog types, no?
>
I don't want to introduce extra complexity into it if not necessary.
so I only included the
thing needed for the selinux implementation for now.  But I agree that the map
and program type information could be useful when people developing more complex
security checks. I will add a union bpf_attr *attr pointer into the
security hook functions
for future needs.
>> +       if (err)
>> +               return -EACCES;
>> +
>>         /* find map type and init map: hashtable vs rbtree vs bloom vs ...
>> */
>>         map = find_and_alloc_map(attr);
>>         if (IS_ERR(map))
>> @@ -291,6 +295,10 @@ static int map_create(union bpf_attr *attr)
>>         if (err)
>>                 goto free_map_nouncharge;
>>
>> +       err = security_post_create(map);
>> +       if (err < 0)
>> +               goto free_map;
>> +
>
>
> So the hook you implement in patch 3/3 does:
>
> +static int selinux_bpf_post_create(struct bpf_map *map)
> +{
> +       struct bpf_security_struct *bpfsec;
> +
> +       bpfsec = kzalloc(sizeof(*bpfsec), GFP_KERNEL);
> +       if (!bpfsec)
> +               return -ENOMEM;
> +
> +       bpfsec->sid = current_sid();
> +       map->security = bpfsec;
> +
> +       return 0;
> +}
>
> Where do you kfree() bpfsec when the map gets released
> normally or in error path?
>
Will add it in next version. Thanks for point it out.
>>         err = bpf_map_alloc_id(map);
>>         if (err)
>>                 goto free_map;
>> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>>         if (IS_ERR(map))
>>                 return PTR_ERR(map);
>>
>> +       err = security_map_read(map);
>> +       if (err)
>> +               return -EACCES;
>
>
> How about actually dropping ref?
>
May bad, thanks again.
>> +
>>         key = memdup_user(ukey, map->key_size);
>>         if (IS_ERR(key)) {
>>                 err = PTR_ERR(key);
>> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
>>         if (IS_ERR(map))
>>                 return PTR_ERR(map);
>>
>> +       err = security_map_modify(map);
>> +       if (err)
>> +               return -EACCES;
>
>
> Ditto ...
>
>>         key = memdup_user(ukey, map->key_size);
>>         if (IS_ERR(key)) {
>>                 err = PTR_ERR(key);
>> @@ -573,6 +589,10 @@ static int map_delete_elem(union bpf_attr *attr)
>>         if (IS_ERR(map))
>>                 return PTR_ERR(map);
>>
>> +       err = security_map_modify(map);
>> +       if (err)
>> +               return -EACCES;
>
>
> Ditto ...
>
>>         key = memdup_user(ukey, map->key_size);
>>         if (IS_ERR(key)) {
>>                 err = PTR_ERR(key);
>> @@ -616,6 +636,10 @@ static int map_get_next_key(union bpf_attr *attr)
>>         if (IS_ERR(map))
>>                 return PTR_ERR(map);
>>
>> +       err = security_map_read(map);
>> +       if (err)
>> +               return -EACCES;
>
>
> And once again here ... :(
>
>
>>         if (ukey) {
>>                 key = memdup_user(ukey, map->key_size);
>>                 if (IS_ERR(key)) {
>> @@ -935,6 +959,10 @@ static int bpf_prog_load(union bpf_attr *attr)
>>         if (CHECK_ATTR(BPF_PROG_LOAD))
>>                 return -EINVAL;
>>
>> +       err = security_prog_load();
>> +       if (err)
>> +               return -EACCES;
>> +
>>         if (attr->prog_flags & ~BPF_F_STRICT_ALIGNMENT)
>>                 return -EINVAL;
>>
>>
>
