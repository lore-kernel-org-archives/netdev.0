From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra and
 for pre-commit split
Date: Mon, 21 Sep 2015 09:34:33 -0700
Message-ID: <CAE4R7bAoHdPHtPXiQgvSWBiSkT+Sdq-wcag4Bn+vQiEUxOOksQ@mail.gmail.com>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bArD_uYEnsQtvYg94qsydtEJAjYwC9Q3ZfaZH8Wqs0SEQ@mail.gmail.com> <20150921080949.GC2141@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36559 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757253AbbIUQex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 12:34:53 -0400
Received: by obbmp4 with SMTP id mp4so51930865obb.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 09:34:52 -0700 (PDT)
In-Reply-To: <20150921080949.GC2141@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 1:09 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Sep 21, 2015 at 09:23:24AM CEST, sfeldma@gmail.com wrote:
>>On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Jiri Pirko (6):
>>>   switchdev: rename "trans" to "trans_ph".
>>>   switchdev: introduce transaction infrastructure for attr_set and
>>>     obj_add
>>>   rocker: switch to local transaction phase enum
>>>   switchdev: move transaction phase enum under transaction structure
>>>   rocker: use switchdev transaction queue for allocated memory
>>>   switchdev: split commit and prepare phase into two callbacks
>>
>>Patches compile, but first test bombs.  Cut-and-paste of dump at end
>>of this email.
>
> Told you :)
>
>
>>
>>I'm not sure I'm liking this patchset because it looks like a way for
>>switchdev drivers to easily opt-out of the prepare-commit transaction
>>model by simply not implementing the *_pre op.  I would rather drivers
>>explicitly handle the PREPARE phase in code, even if that means
>>skipping it gracefully (in code) with a comment (in code) explaining
>>why it does not matter for this device/operation.  That's what DSA had
>>done, mostly because it was a retro-fit.
>
> Each driver should handle this inside it. If it does not need prepare
> state, it simply does not implement it. That is the same for all cb,
> ndos, netdev notifiers, etc. It is much cleaner and nicer to have these as
> separate callbacks. Implementing multiple callback in one is just ugly,
> sorry.
>
>
>>
>>Also, the patchset removes the ABORT callback in case of a rollback
>>due to a failed PREPARE.  We can't make the assumption that it's just
>>a memory list to destroy on ABORT.  The driver, on PREPARE, may have
>>reserved device space or staged an operation on the device which we'll
>>need to undo on ABORT.
>
> Yep, just register an item with custom destructor, there you can do
> whatever. Also, I believe much nicer comparing to current code.
>
>
>>
>>So we need ABORT back, and we need PREPARE to not be optional, so
>>what's left list enqueue/dequeue helpers, which I'm not seeing much
>>value in up-leveling as the driver can do list_add/del itself.
>
> Why would every driver do it itself, over and over when there can be a
> clean infrastructure to do that. Including abort phase. Without the driver
> needed to be involved.
>
>
>>
>>Am I missing something?  I didn't see a motivation statement for the
>>RFC so I'm not sure where you wanted to take this.
>
> I want to make current code much nicer, easier to read and implement in
> other drivers. Look at rocker.c and how often there is == PREPARE there.
> It's nearly impossible to followthe code, sorry.

You're going to end up duplicate a lot of code and make it easier to
make mistakes.  The reason why the == PREPARE checks are there is the
same code is run for both PREPARE and COMMIT, with == PREPARE checks
right at the last moment to avoid a irreversible change, such as
deleting an entry from a table or changing a state variable or bumping
a hardware desc pointer.  Otherwise the code paths should be the same
for PREPARE and COMMIT.  If you split these, you're going to duplicate
lots of code and one path will deviate from the other over time and
now we've broken the prepare-commit model.  We want PREPARE to answer
the question "is it OK to do this?" and COMMIT to do without failure.

Do you have a specific example where you can't follow the code with == PREPARE?

> My next patchset is to un-mess rocker.c (that freaking ofdpa stuff is everywhere)

Rocker implements OF-DPA so it's seems natural that freaking OF-DPA
stuff would be everywhere.
