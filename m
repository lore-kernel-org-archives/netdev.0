From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra
 and for pre-commit split
Date: Mon, 21 Sep 2015 21:06:17 +0200
Message-ID: <20150921175903.GA2023@nanopsycho.orion>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bArD_uYEnsQtvYg94qsydtEJAjYwC9Q3ZfaZH8Wqs0SEQ@mail.gmail.com>
 <20150921080949.GC2141@nanopsycho.orion>
 <CAE4R7bAoHdPHtPXiQgvSWBiSkT+Sdq-wcag4Bn+vQiEUxOOksQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36606 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162AbbIUTGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 15:06:20 -0400
Received: by wicgb1 with SMTP id gb1so128573150wic.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 12:06:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAoHdPHtPXiQgvSWBiSkT+Sdq-wcag4Bn+vQiEUxOOksQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 21, 2015 at 06:34:33PM CEST, sfeldma@gmail.com wrote:
>On Mon, Sep 21, 2015 at 1:09 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Sep 21, 2015 at 09:23:24AM CEST, sfeldma@gmail.com wrote:
>>>On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Jiri Pirko (6):
>>>>   switchdev: rename "trans" to "trans_ph".
>>>>   switchdev: introduce transaction infrastructure for attr_set and
>>>>     obj_add
>>>>   rocker: switch to local transaction phase enum
>>>>   switchdev: move transaction phase enum under transaction structure
>>>>   rocker: use switchdev transaction queue for allocated memory
>>>>   switchdev: split commit and prepare phase into two callbacks
>>>
>>>Patches compile, but first test bombs.  Cut-and-paste of dump at end
>>>of this email.
>>
>> Told you :)
>>
>>
>>>
>>>I'm not sure I'm liking this patchset because it looks like a way for
>>>switchdev drivers to easily opt-out of the prepare-commit transaction
>>>model by simply not implementing the *_pre op.  I would rather drivers
>>>explicitly handle the PREPARE phase in code, even if that means
>>>skipping it gracefully (in code) with a comment (in code) explaining
>>>why it does not matter for this device/operation.  That's what DSA had
>>>done, mostly because it was a retro-fit.
>>
>> Each driver should handle this inside it. If it does not need prepare
>> state, it simply does not implement it. That is the same for all cb,
>> ndos, netdev notifiers, etc. It is much cleaner and nicer to have these as
>> separate callbacks. Implementing multiple callback in one is just ugly,
>> sorry.
>>
>>
>>>
>>>Also, the patchset removes the ABORT callback in case of a rollback
>>>due to a failed PREPARE.  We can't make the assumption that it's just
>>>a memory list to destroy on ABORT.  The driver, on PREPARE, may have
>>>reserved device space or staged an operation on the device which we'll
>>>need to undo on ABORT.
>>
>> Yep, just register an item with custom destructor, there you can do
>> whatever. Also, I believe much nicer comparing to current code.
>>
>>
>>>
>>>So we need ABORT back, and we need PREPARE to not be optional, so
>>>what's left list enqueue/dequeue helpers, which I'm not seeing much
>>>value in up-leveling as the driver can do list_add/del itself.
>>
>> Why would every driver do it itself, over and over when there can be a
>> clean infrastructure to do that. Including abort phase. Without the driver
>> needed to be involved.
>>
>>
>>>
>>>Am I missing something?  I didn't see a motivation statement for the
>>>RFC so I'm not sure where you wanted to take this.
>>
>> I want to make current code much nicer, easier to read and implement in
>> other drivers. Look at rocker.c and how often there is == PREPARE there.
>> It's nearly impossible to followthe code, sorry.
>
>You're going to end up duplicate a lot of code and make it easier to
>make mistakes.  The reason why the == PREPARE checks are there is the
>same code is run for both PREPARE and COMMIT, with == PREPARE checks
>right at the last moment to avoid a irreversible change, such as
>deleting an entry from a table or changing a state variable or bumping
>a hardware desc pointer.  Otherwise the code paths should be the same
>for PREPARE and COMMIT.  If you split these, you're going to duplicate
>lots of code and one path will deviate from the other over time and
>now we've broken the prepare-commit model.  We want PREPARE to answer
>the question "is it OK to do this?" and COMMIT to do without failure.

Okay, I'll leave the last patch out for now. Let's see what the
future brings :)

I really don't like "NONE" phase, does not make sense for switchdev code
and it is just a hack for rocker. So I will kick it out from switchdev
anyway.

"ABORT" phase also does not allign to what you say about
one-code-two-passes and I think that my patchset is actually handling
abort nicely.

That leaves only "PREPARE" and "COMMIT"

Makes sense?

>
>Do you have a specific example where you can't follow the code with == PREPARE?
>
>> My next patchset is to un-mess rocker.c (that freaking ofdpa stuff is everywhere)
>
>Rocker implements OF-DPA so it's seems natural that freaking OF-DPA
>stuff would be everywhere.

Well, no. It is only one of many possible worlds. In qemu, the split is
done nicely. However in kernel, the ofdpa stuff is squashed to
the generic rocker stuff. I have a patchset for splitting
that under construction for some time. This week I have some time
allocated for that so I hopefully will send the patchset
this Thursday (fingers crossed).

Thanks for review!
