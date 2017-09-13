From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: netfilter: xt_bpf: ABI issue in xt_bpf_info_v1?
Date: Wed, 13 Sep 2017 11:35:38 -0400
Message-ID: <CAF=yD-Ldmk9mTC5rCxc8LSomNgvT5kPWFjDBvnSyX0EM-E6eFg@mail.gmail.com>
References: <20170913162442.368691c9@pixies> <nycvar.YFH.7.76.1709131613520.8761@n3.vanv.qr>
 <CAF=yD-LUCCLSXuPNKPgEY695ej+T-2s=zhmw6CJwK6tFyY+_dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Shmulik Ladkani <shmulik@nsof.io>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Network Development <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Rafael Buchbinder <rbk@nsof.io>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>, eyal@nsof.io
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33237 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdIMPgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:36:19 -0400
In-Reply-To: <CAF=yD-LUCCLSXuPNKPgEY695ej+T-2s=zhmw6CJwK6tFyY+_dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 13, 2017 at 11:05 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Wed, Sep 13, 2017 at 10:22 AM, Jan Engelhardt <jengelh@inai.de> wrote:
>>
>> On Wednesday 2017-09-13 15:24, Shmulik Ladkani wrote:
>>>
>>>One way to fix is to have iptables open the object (using the stored
>>>xt_bpf_info_v1->path), gaining a new process local fd for the object,
>>>just after getting the rules from IPT_SO_GET_ENTRIES.
>>>However we didn't see any other extensions doing something like that in
>>>iptables.
>
> The binary should call bpf_obj_get on the filepath each time. These are
> not regular files, but references to a pinned object in the bpf filesystem.
>
> Blindly passing back the fd received from the kernel is clearly wrong. I'm
> really surprised that I did not run into this problem when I wrote the
> feature.
>
>>>
>>>Another way to solve is to fix the ABI (or have a v2 one), that does NOT
>>>pass the fd from userspace, only the path of the pinned object.
>>>Then, 'bpf_mt_check_v1' will open the file from the given path in order
>>>to get the bpf_prog.
>>
>> But a path has a similar problem like a file descriptor - it is local to a
>> certain mount namespace.
>
> Because these are pinned objects in the bpf filesystem, and there is
> only one of those, it may be possible to lookup the object in the kernel
> without relying on a process-local view of mount points.

It would be preferable to fix this for the existing v1 users as well.

That said, the new bpf identifier feature allows passing a globally
unique id instead of a filepath.

>
>>
>> To load "large" blobs into the kernel, a pointer to user memory is a possible
>> option. The downside is that such extra data is not retrievable from the kernel
>> via the iptables setsockopts anymore - one could work around it with procfs, or
>> just let it be.
>>
>> https://sourceforge.net/p/xtables-addons/xtables-addons/ci/master/tree/extensions/xt_geoip.c
>> line 64+.
