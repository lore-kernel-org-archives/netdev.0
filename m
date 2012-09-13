From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v4 4/8] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Thu, 13 Sep 2012 09:38:54 +0200
Message-ID: <50518D8E.5020206@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org> <1347459128-32236-5-git-send-email-wagi@monom.org> <50517FFF.4030106@huawei.com> <505183E3.3030409@monom.org> <505187C8.9030001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <505187C8.9030001-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Li,

On 13.09.2012 09:14, Li Zefan wrote:
> On 2012/9/13 14:57, Daniel Wagner wrote:
>> Hi Li,
>>
>> On 13.09.2012 08:41, Li Zefan wrote:
>>>> @@ -1321,11 +1321,13 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>>>>         * take duplicate reference counts on a subsystem that's already used,
>>>>         * but rebind_subsystems handles this case.
>>>>         */
>>>> -    for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
>>>> +    for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>>>>            unsigned long bit = 1UL << i;
>>>>
>>>>            if (!(bit & opts->subsys_mask))
>>>>                continue;
>>>> +        if (!subsys[i]->module)
>>>> +            continue;
>>>
>>> This check is not necessary. If it's builtin, try_module_get() will just return 1, and
>>> we're fine.
>>
>> Yes, I didn't see the try_module_get. Although I think with leaving the test away it would change the behavior, e.g.
>>
>>          if (!subsys[i]->module)
>>              continue;
>>          if (!try_module_get(subsys[i]->module)) {
>>              module_pin_failed = true;
>>              break;
>>          }
>>
>> module_pin_failed would be set then and we would jump into the error code later.
>>
>
> no behavioral change. For a builtin subsys, we won't run into the if block and have module_pin_failed be set.

Ah, I understand.

>> This tests looks a bit ugly though I think leaving it away and relying on try_module_get() is not correct.
>>
>
> I don't think this is bad. The block layer code does the similar thing in elevator_get().
>
> And we call module_put() unconditionally in rebind_subsys().

Okay, then these tests really not needed. I'll have them removed now
and tested the result. All works fine.

>>>> @@ -1437,6 +1443,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
>>>>        INIT_LIST_HEAD(&cgrp->event_list);
>>>>        spin_lock_init(&cgrp->event_list_lock);
>>>>        simple_xattrs_init(&cgrp->xattrs);
>>>> +    memset(cgrp->subsys, 0, sizeof(cgrp->subsys));
>>>
>>> This seems an unrelated change, and is redundant. Am I missing something?
>>
>> The reason why it is necessary to NULL all the entries in the array, is that task_cls_classid() and task_netprioidx() check the return pointer from task_subsys_state(). If it is NULL those function know that the subsystem is not ready to be used. Should I move this change to the next patch then?
>>
>
> It's already guaranteed the passing @cgrp is zeored. that's why cgrp->flags is not explicitly initialized here.

Stupid me, I didn't see the kzalloc. You are absolutely right.

Thanks for your review.

cheers,
daniel
