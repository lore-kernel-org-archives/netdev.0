From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to filesystem
Date: Wed, 19 Apr 2017 18:48:47 -0700
Message-ID: <CAGXu5jJCvJ6-uZ=Kfhh3xD7UvaY+G99e9NXFMzvi=9OQzA6Ecg@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
 <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net> <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
 <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com> <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Casey Schaufler <casey@schaufler-ca.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 3:03 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
> On 19/04/2017 01:40, Kees Cook wrote:
>> On Tue, Apr 18, 2017 at 4:16 PM, Casey Schaufler <casey@schaufler-ca.com=
> wrote:
>>> On 4/18/2017 3:44 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>>>> On 19/04/2017 00:17, Kees Cook wrote:
>>>>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digiko=
d.net> wrote:
>>>>>> +void __init landlock_add_hooks(void)
>>>>>> +{
>>>>>> +       pr_info("landlock: Version %u", LANDLOCK_VERSION);
>>>>>> +       landlock_add_hooks_fs();
>>>>>> +       security_add_hooks(NULL, 0, "landlock");
>>>>>> +       bpf_register_prog_type(&bpf_landlock_type);
>>>>> I'm confused by the separation of hook registration here. The call to
>>>>> security_add_hooks is with count=3D0 is especially weird. Why isn't t=
his
>>>>> just a single call with security_add_hooks(landlock_hooks,
>>>>> ARRAY_SIZE(landlock_hooks), "landlock")?
>>>> Yes, this is ugly with the new security_add_hooks() with three argumen=
ts
>>>> but I wanted to split the hooks definition in multiple files.
>>>
>>> Why? I'll buy a good argument, but there are dangers in
>>> allowing multiple calls to security_add_hooks().
>
> I prefer to have one file per hook "family" (e.g. filesystem, network,
> ptrace=E2=80=A6). This reduce the mess with all the included files (neede=
d for
> LSM hook argument types) and make the files easier to read, understand
> and maintain.
>
>>>
>>>>
>>>> The current security_add_hooks() use lsm_append(lsm, &lsm_names) which
>>>> is not exported. Unfortunately, calling multiple security_add_hooks()
>>>> with the same LSM name would register multiple names for the same LSM=
=E2=80=A6
>>>> Is it OK if I modify this function to not add duplicated entries?
>>>
>>> It may seem absurd, but it's conceivable that a module might
>>> have two hooks it wants called. My example is a module that
>>> counts the number of times SELinux denies a process access to
>>> things (which needs to be called before and after SELinux in
>>> order to detect denials) and takes "appropriate action" if
>>> too many denials occur. It would be weird, wonky and hackish,
>>> but that never stopped anybody before.
>
> Right, but now, with the new lsm_append(), module names are concatenated
> ("%s,%s") in the lsm_names variable. It would be nice to not pollute
> this string with multiple time the same module name.

Perhaps security_add_hooks could be modified to accept a NULL lsm to
skip the lsm_append() call, so it could do:

security_add_hooks(hooks1, count1, NULL);
security_add_hooks(hooks2, count2, NULL);
security_add_hooks(NULL, 0, "landlock");

Or, as Casey suggests, disregard adding the name when it already exists:

security_add_hooks(hooks1, count1, "landlock");
security_add_hooks(hooks2, count2, "landlock");

Yeah, I think I prefer this...

-Kees

>
>>
>> If ends up being sane and clear, I'm fine with allowing multiple calls.
>>
>> -Kees
>>
>



--=20
Kees Cook
Pixel Security
