From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Thu, 2 Mar 2017 16:55:21 -0800
Message-ID: <CALCETrW8Pmap7CgdtE+XL39fPR1tOM4d8BBA=S4jot-ocAcw3g@mail.gmail.com>
References: <20170222012632.4196-1-mic@digikod.net> <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
 <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net> <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
 <db8cbaea-d4e5-3123-0b14-857737b753bc@digikod.net> <CALCETrXpaz3Sw8Q28PKi2LGB956bZ0mfhoNg59Pe5EY+kTmqZg@mail.gmail.com>
 <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
	Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
	Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-6897-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <0efca89a-7e8b-a6f8-987b-95df61223a22@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Mar 2, 2017 at 4:48 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net> =
wrote:
>
> On 02/03/2017 17:36, Andy Lutomirski wrote:
>> On Wed, Mar 1, 2017 at 3:28 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.ne=
t> wrote:
>>>
>>>
>>> On 01/03/2017 23:20, Andy Lutomirski wrote:
>>>> On Wed, Mar 1, 2017 at 2:14 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>>>>
>>>>> On 28/02/2017 21:01, Andy Lutomirski wrote:
>>>>>> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digik=
od.net> wrote:
>>>>> This design makes it possible for a process to add more constraints t=
o
>>>>> its children on the fly. I think it is a good feature to have and a
>>>>> safer default inheritance mechanism, but it could be guarded by an
>>>>> option flag if we want both mechanism to be available. The same desig=
n
>>>>> could be used by seccomp filter too.
>>>>>
>>>>
>>>> Then let's do it right.
>>>>
>>>> Currently each task has an array of seccomp filter layers.  When a
>>>> task forks, the child inherits the layers.  All the layers are
>>>> presently immutable.  With Landlock, a layer can logically be a
>>>> syscall fitler layer or a Landlock layer.  This fits in to the
>>>> existing model just fine.
>>>>
>>>> If we want to have an interface to allow modification of an existing
>>>> layer, let's make it so that, when a layer is added, you have to
>>>> specify a flag to make the layer modifiable (by current, presumably,
>>>> although I can imagine other policies down the road).  Then have a
>>>> separate API that modifies a layer.
>>>>
>>>> IOW, I think your patch is bad for three reasons, all fixable:
>>>>
>>>> 1. The default is wrong.  A layer should be immutable to avoid an easy
>>>> attack in which you try to sandbox *yourself* and then you just modify
>>>> the layer to weaken it.
>>>
>>> This is not possible, there is only an operation for now:
>>> SECCOMP_ADD_LANDLOCK_RULE. You can only add more rules to the list (as
>>> for seccomp filter). There is no way to weaken a sandbox. The question
>>> is: how do we want to handle the rules *tree* (from the kernel point of
>>> view)?
>>>
>>
>> Fair enough.  But I still think that immutability (like regular
>> seccomp) should be the default.  For security, simplicity is
>> important.  I guess there could be two ways to relax immutability:
>> allowing making the layer stricter and allowing any change at all.
>>
>> As a default, though, programs should be able to expect that:
>>
>> seccomp(SECCOMP_ADD_WHATEVER, ...);
>> fork();
>>
>> [parent gets compromised]
>> [in parent]seccomp(anything whatsoever);
>>
>> will not affect the child,  If the parent wants to relax that, that's
>> fine, but I think it should be explicit.
>
> Good point. However the term "immutability" doesn't fit right because
> the process is still allowed to add more rules to itself (as for
> seccomp). The difference lays in the way a rule may be "appended" (by
> the current process) or "inserted" (by a parent process).
>
> I think three or four kind of operations (through the seccomp syscall)
> make sense:
> * append a rule (for the current process and its future children)

Sure, but this operation should *never* affect existing children,
existing seccomp layers, existing nodes, etc.  It should affect
current and future children only.  Or it could simply not exist for
Landlock and instead you'd have to add a layer (see below) and then
program that layer.

> * add a node (insert point), from which the inserted rules will be tied
> * insert a rule in the node, which will be inherited by futures children

I would advocate calling this a "seccomp layer" and making creation
and manipulation of them generic.

> * (maybe a "lock" command to make a layer immutable for the current
> process and its children)

Hmm, maybe.

>
> Doing so, a process is only allowed to insert a rule if a node was
> previously added. To forbid itself to insert new rules to one of its
> children, a process just need to not add a node before forking. Like
> this, there is no need for special rule flags nor default behavior,
> everything is explicit.

This is still slightly too complicated.  If you really want an
operation that adds a layer (please don't call it a node in the ABI)
and adds a rule to that layer in a single operation, it should be a
separate operation.  Please make everything explicit.

(I don't like exposing the word "node" to userspace because it means
nothing.  Having more than one layer of filter makes sense to me,
which is why I like "layer".  I'm sure that other good choices exist.)

>
> For this series, I will stick to the same behavior as seccomp filter:
> only append rules to the current process (and its future children).
>
>
>>>> 2. The API that adds a layer should be different from the API that
>>>> modifies a layer.
>>>
>>> Right, but it doesn't apply now because we can only add rules.
>>
>> That's not what the code appears to do, though.  Sometimes it makes a
>> new layer without modifying tasks that share the layer and sometimes
>> it modifies the layer.
>>
>> Both operations are probably okay, but they're not the same operation
>> and they shouldn't pretend to be.
>
> It should be OK with my previous proposal. The other details could be
> discussed in a separate future patch series.
>

NAK, or at least NAK pending better docs and justification.  The
operations of "add a layer and put a rule in it" and "add a rule to an
existing layer" are logically different and should not be the same
SECCOMP operation.  "Do what I mean" is a nice paradigm for a language
like Perl, but for security (and for kernel interfaces in general),
"do what I say and error out if I said nonsense" is much safer.
