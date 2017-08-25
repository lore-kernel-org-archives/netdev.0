From: Chenbo Feng <fengc@google.com>
Subject: Re: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 12:52:02 -0700
Message-ID: <CAMOXUJkQ-Wh==9nzgx3Sq4RUEBK5ArHk4b=AL0N65L9g6cAqcg@mail.gmail.com>
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
 <1503689199.9977.4.camel@tycho.nsa.gov> <CABXk95BkyU5MBLry0PEp+QwhtY7rM4DCmQq3CeQi6=TQtQQPwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
To: Jeffrey Vander Stoep <jeffv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35953 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbdHYTwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:52:05 -0400
Received: by mail-lf0-f50.google.com with SMTP id z130so3102679lff.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:52:04 -0700 (PDT)
In-Reply-To: <CABXk95BkyU5MBLry0PEp+QwhtY7rM4DCmQq3CeQi6=TQtQQPwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 12:45 PM, Jeffrey Vander Stoep <jeffv@google.com> w=
rote:
> On Fri, Aug 25, 2017 at 12:26 PM, Stephen Smalley <sds@tycho.nsa.gov> wro=
te:
>> On Fri, 2017-08-25 at 11:01 -0700, Jeffrey Vander Stoep via Selinux
>> wrote:
>>> I=E2=80=99d like to get your thoughts on adding LSM permission checks o=
n BPF
>>> objects.
>>>
>>> By default, the ability to create and use eBPF maps/programs requires
>>> CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access
>>> to bpf() functions. This seems like poor granularity. [2]
>>>
>>> Like files and sockets, eBPF maps and programs can be passed between
>>> processes by FD and have a number of functions that map cleanly to
>>> permissions.
>>>
>>> Let me know what you think. Are there simpler alternative approaches
>>> that we haven=E2=80=99t considered?
>>
>> Is it possible to create the map/program in one process (with
>> CAP_SYS_ADMIN), pass the resulting fd to netd, and then use it there
>> (without requiring CAP_SYS_ADMIN in netd itself)?
>
> That might work. Any use of bpf() requires CAP_SYS_ADMIN but netd
> could potentially just apply the prog_fd to a socket:
>
>            setsockopt(sockfd, SOL_SOCKET, SO_ATTACH_BPF,
>                       &prog_fd, sizeof(prog_fd));
>

This specific case might work. But other map and program related operations=
 can
only be done through syscalls. And the syscall can be set to only allow
CAP_SYS_ADMIN processes to use it or open to all processes. So when the
CAP_SYS_ADMIN limitation is enforced, netd will not be able to use any of t=
he
syscalls such as map_look_up, map_update, map_delete even if a
CAP_SYS_ADMIN process passed the fd to it. Here is how this enforcement
implemented:
http://elixir.free-electrons.com/linux/latest/source/kernel/bpf/syscall.c#L=
1005

>>
>> What level of granularity would be useful?  Would it go beyond just
>> being able to use bpf() at all?
>
> "use" might be sufficient. At least initially.
>
> I could see some others coming in handy. For example, a simple mapping
> of functionality to permissions gives:
> map_create, map_update, map_delete, map_read, prog_load, prog_use.
>
> Of course there's no sense in breaking "use" into multiple permissions if
> we expect the entire set to always be granted together.
>
>>
>>>
>>> Thanks!
>>> Jeff
>>>
>>> [1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
>>> [2] We are considering eBPF for network filtering by netd. Giving
>>> netd
>>> CAP_SYS_ADMIN would considerably increase netd=E2=80=99s privileges.
>>> Alternatively allowing all processes permission to use bpf() goes
>>> against the principle of least privilege exposing a lot of kernel
>>> attack surface to processes that do not actually need it.
>>>
