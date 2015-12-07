From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Mon, 7 Dec 2015 14:33:52 -0500
Message-ID: <5665DF20.9020904@gmail.com>
References: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <fcceeb2a58ce2054cedb091f0e251393b36418ba.1449250981.git.marcelo.leitner@gmail.com>
 <CACT4Y+b66FHbFyERm804RDWh9oPC==K43TgDJfs52cQG1MDjcg@mail.gmail.com>
 <20151204213428.GH4164@mrl.redhat.com> <56631357.6020304@gmail.com>
 <CACT4Y+YCZO2rfYdO_ACPF1U0p3YyXYJGA_Bhdb8CP8pecLy7SA@mail.gmail.com>
 <20151207131524.GA22989@mrl.redhat.com>
 <CACT4Y+ZhRG-LCdEoF=WusYVUj8gnm16663GcgJ=ztu0QC6r0vg@mail.gmail.com>
 <20151207185218.GB22989@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35663 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbbLGTd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 14:33:56 -0500
In-Reply-To: <20151207185218.GB22989@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2015 01:52 PM, Marcelo Ricardo Leitner wrote:
> On Mon, Dec 07, 2015 at 02:20:47PM +0100, Dmitry Vyukov wrote:
>> On Mon, Dec 7, 2015 at 2:15 PM, Marcelo Ricardo Leitner
>> <marcelo.leitner@gmail.com> wrote:
>>> On Mon, Dec 07, 2015 at 12:26:09PM +0100, Dmitry Vyukov wrote:
>>>> On Sat, Dec 5, 2015 at 5:39 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> ...
>>>>> Hi Marcelo
>>>>>
>>>>> I think you also need to catch the SCTP_DISPOSITION_ABORT and update
>>>>> the pointer.  There are some issues there though as some functions report
>>>>> that code without actually destroying the association.  This happens when
>>>>> the ABORT chunk may be dropped.
>>>>>
>>>>> I think this might be why we still see the issue.
>>>>
>>>>
>>>> Marcelo,
>>>>
>>>> Is this info enough for you to cook another fix?
>>>
>>> Hi, I think so. I was really wondering how you could trigger that issue
>>> without the timestamp fix and Vlad's comment does shed some light on it.
>>>
>>> I'll do more tests later today, but what did you have connecting to the
>>> listening socket? Somehow you made that accept() call to return..
>>
>> Local connect in another thread I guess.
> 
> Vlad, I reviewed the places on which it returns SCTP_DISPOSITION_ABORT,
> and if I didn't miss something in there all of them either issue
> SCTP_CMD_ASSOC_FAILED or SCTP_CMD_INIT_FAILED before returning it, thus
> delaying DELETE_TCB and with that the asoc free.

They delay it from the perspective of the command interpreter since the command
to delete the TCB happens a little later, but status code  is checked after all
commands are processed and command processing doesn't change it.  So the 'status'
code would still be SCTP_DISPOSITION_ABORT after DELETE_TCB command was processed.
So, I think we may still have an use-after-free issue here.

> There is one place,
> though, that may not do it that way, it's sctp_sf_abort_violation(), but
> then that code only runs if asoc is already NULL by then.

I don't believe so.  The violation state function can run with a non-NULL association
if we are encountering protocol violations after the association is established.

-vlad

> 
> Dmitry, still no luck here, cannot reproduce another hit.
> I'm using sctp_test and a custom test of mine, both on localhost so I
> would catch it in server or client side, nothing..
> 
> I need more info. Please enable the pr_debug() on debug_post_sfn() macro
> and see which status is being reported when you trigger the issue.
> And/or share a traffic capture so we can see what's going on with the
> association.
> 
>   Marcelo
> 
