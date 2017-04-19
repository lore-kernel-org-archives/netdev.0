From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [kernel-hardening] Re: [PATCH net-next v6 04/11] landlock: Add
 LSM hooks related to filesystem
Date: Wed, 19 Apr 2017 16:58:17 -0700
Message-ID: <ccad825b-7a58-e499-e51b-bd7c98581afe@schaufler-ca.com>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
 <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net>
 <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
 <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>
 <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "kernel-hardening@lists.o
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/19/2017 3:03 PM, Mickaël Salaün wrote:
> On 19/04/2017 01:40, Kees Cook wrote:
>> On Tue, Apr 18, 2017 at 4:16 PM, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org> wrote:
>>> On 4/18/2017 3:44 PM, Mickaël Salaün wrote:
>>>> On 19/04/2017 00:17, Kees Cook wrote:
>>>>> On Tue, Mar 28, 2017 at 4:46 PM, Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org> wrote:
>>>>>> +void __init landlock_add_hooks(void)
>>>>>> +{
>>>>>> +       pr_info("landlock: Version %u", LANDLOCK_VERSION);
>>>>>> +       landlock_add_hooks_fs();
>>>>>> +       security_add_hooks(NULL, 0, "landlock");
>>>>>> +       bpf_register_prog_type(&bpf_landlock_type);
>>>>> I'm confused by the separation of hook registration here. The call to
>>>>> security_add_hooks is with count=0 is especially weird. Why isn't this
>>>>> just a single call with security_add_hooks(landlock_hooks,
>>>>> ARRAY_SIZE(landlock_hooks), "landlock")?
>>>> Yes, this is ugly with the new security_add_hooks() with three arguments
>>>> but I wanted to split the hooks definition in multiple files.
>>> Why? I'll buy a good argument, but there are dangers in
>>> allowing multiple calls to security_add_hooks().
> I prefer to have one file per hook "family" (e.g. filesystem, network,
> ptrace…). This reduce the mess with all the included files (needed for
> LSM hook argument types) and make the files easier to read, understand
> and maintain.

Yeah, there's that tradeoff and it really is a matter
of taste I suppose.

>>>> The current security_add_hooks() use lsm_append(lsm, &lsm_names) which
>>>> is not exported. Unfortunately, calling multiple security_add_hooks()
>>>> with the same LSM name would register multiple names for the same LSM…
>>>> Is it OK if I modify this function to not add duplicated entries?
>>> It may seem absurd, but it's conceivable that a module might
>>> have two hooks it wants called. My example is a module that
>>> counts the number of times SELinux denies a process access to
>>> things (which needs to be called before and after SELinux in
>>> order to detect denials) and takes "appropriate action" if
>>> too many denials occur. It would be weird, wonky and hackish,
>>> but that never stopped anybody before.
> Right, but now, with the new lsm_append(), module names are concatenated
> ("%s,%s") in the lsm_names variable. It would be nice to not pollute
> this string with multiple time the same module name.

All it would take is a check that the module name
isn't already on the list. It's a trivial change.

>> If ends up being sane and clear, I'm fine with allowing multiple calls.
>>
>> -Kees
>>
