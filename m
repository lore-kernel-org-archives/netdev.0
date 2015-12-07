From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Mon, 7 Dec 2015 15:37:58 -0500
Message-ID: <5665EE26.3000706@gmail.com>
References: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <fcceeb2a58ce2054cedb091f0e251393b36418ba.1449250981.git.marcelo.leitner@gmail.com>
 <CACT4Y+b66FHbFyERm804RDWh9oPC==K43TgDJfs52cQG1MDjcg@mail.gmail.com>
 <20151204213428.GH4164@mrl.redhat.com> <56631357.6020304@gmail.com>
 <CACT4Y+YCZO2rfYdO_ACPF1U0p3YyXYJGA_Bhdb8CP8pecLy7SA@mail.gmail.com>
 <20151207131524.GA22989@mrl.redhat.com>
 <CACT4Y+ZhRG-LCdEoF=WusYVUj8gnm16663GcgJ=ztu0QC6r0vg@mail.gmail.com>
 <20151207185218.GB22989@mrl.redhat.com> <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33167 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932716AbbLGUiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 15:38:03 -0500
In-Reply-To: <20151207195032.GA22987@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2015 02:50 PM, Marcelo Ricardo Leitner wrote:
> On Mon, Dec 07, 2015 at 02:33:52PM -0500, Vlad Yasevich wrote:
>> On 12/07/2015 01:52 PM, Marcelo Ricardo Leitner wrote:
>>> On Mon, Dec 07, 2015 at 02:20:47PM +0100, Dmitry Vyukov wrote:
>>>> On Mon, Dec 7, 2015 at 2:15 PM, Marcelo Ricardo Leitner
>>>> <marcelo.leitner@gmail.com> wrote:
>>>>> On Mon, Dec 07, 2015 at 12:26:09PM +0100, Dmitry Vyukov wrote:
>>>>>> On Sat, Dec 5, 2015 at 5:39 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
>>> ...
>>>>>>> Hi Marcelo
>>>>>>>
>>>>>>> I think you also need to catch the SCTP_DISPOSITION_ABORT and update
>>>>>>> the pointer.  There are some issues there though as some functions report
>>>>>>> that code without actually destroying the association.  This happens when
>>>>>>> the ABORT chunk may be dropped.
>>>>>>>
>>>>>>> I think this might be why we still see the issue.
>>>>>>
>>>>>>
>>>>>> Marcelo,
>>>>>>
>>>>>> Is this info enough for you to cook another fix?
>>>>>
>>>>> Hi, I think so. I was really wondering how you could trigger that issue
>>>>> without the timestamp fix and Vlad's comment does shed some light on it.
>>>>>
>>>>> I'll do more tests later today, but what did you have connecting to the
>>>>> listening socket? Somehow you made that accept() call to return..
>>>>
>>>> Local connect in another thread I guess.
>>>
>>> Vlad, I reviewed the places on which it returns SCTP_DISPOSITION_ABORT,
>>> and if I didn't miss something in there all of them either issue
>>> SCTP_CMD_ASSOC_FAILED or SCTP_CMD_INIT_FAILED before returning it, thus
>>> delaying DELETE_TCB and with that the asoc free.
>>
>> They delay it from the perspective of the command interpreter since the command
>> to delete the TCB happens a little later, but status code  is checked after all
>> commands are processed and command processing doesn't change it.  So the 'status'
>> code would still be SCTP_DISPOSITION_ABORT after DELETE_TCB command was processed.
>> So, I think we may still have an use-after-free issue here.
> 
> Gotcha! That's pretty much it then. From that point of view now, there
> shouldn't be a case that it returns _ABORT without freeing the asoc in
> the same loop. (more below)
> 
>>> There is one place,
>>> though, that may not do it that way, it's sctp_sf_abort_violation(), but
>>> then that code only runs if asoc is already NULL by then.
>>
>> I don't believe so.  The violation state function can run with a non-NULL association
>> if we are encountering protocol violations after the association is established.
> 
> Yup, that's correct. I just tried to reference one case on which it
> would return _ABORT without issuing any of those _FAILEDs before doing
> so (meaning the association could still be valid) but that in that case,
> the asoc was already NULL.

I think it is possible to hit the 'discard:' tag in that function while still
having a valid association.  That happens when ABORT chunk is required to be
authenticated.  This that case, instead of generating an ABORT and terminating the
current association, we just drop the packet, but still report an _ABORT disposition code.

This probably need to change if we are going to catch the _ABORT disposition and
clear the asoc pointer.

-vlad

> 
> Dmitry, please give this one a run, as I still cannot reproduce your use
> case..
> 
> ---8<---
> 
> commit b63ad8dc45257dd6c536ac0227fcc623efd9328b
> Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date:   Fri Dec 4 15:30:23 2015 -0200
> 
>     sctp: fix use-after-free in pr_debug statement
>     
>     Dmitry Vyukov reported a use-after-free in the code expanded by the
>     macro debug_post_sfx, which is caused by the use of the asoc pointer
>     after it was freed within sctp_side_effect() scope.
>     
>     This patch fixes it by allowing sctp_side_effect to clear that asoc
>     pointer when the TCB is freed.
>     
>     As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
>     because it will trigger DELETE_TCB too on that same loop.
>     
>     The macro is already prepared to handle such NULL pointer.
>     
>     Reported-by: Dmitry Vyukov <dvyukov@google.com>
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 6098d4c42fa9..be23d5c2074f 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -63,7 +63,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  			     sctp_state_t state,
>  			     struct sctp_endpoint *ep,
> -			     struct sctp_association *asoc,
> +			     struct sctp_association **asoc,
>  			     void *event_arg,
>  			     sctp_disposition_t status,
>  			     sctp_cmd_seq_t *commands,
> @@ -1123,7 +1123,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>  	debug_post_sfn();
>  
>  	error = sctp_side_effects(event_type, subtype, state,
> -				  ep, asoc, event_arg, status,
> +				  ep, &asoc, event_arg, status,
>  				  &commands, gfp);
>  	debug_post_sfx();
>  
> @@ -1136,7 +1136,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  			     sctp_state_t state,
>  			     struct sctp_endpoint *ep,
> -			     struct sctp_association *asoc,
> +			     struct sctp_association **asoc,
>  			     void *event_arg,
>  			     sctp_disposition_t status,
>  			     sctp_cmd_seq_t *commands,
> @@ -1151,7 +1151,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  	 * disposition SCTP_DISPOSITION_CONSUME.
>  	 */
>  	if (0 != (error = sctp_cmd_interpreter(event_type, subtype, state,
> -					       ep, asoc,
> +					       ep, *asoc,
>  					       event_arg, status,
>  					       commands, gfp)))
>  		goto bail;
> @@ -1174,11 +1174,12 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>  		break;
>  
>  	case SCTP_DISPOSITION_DELETE_TCB:
> +	case SCTP_DISPOSITION_ABORT:
>  		/* This should now be a command. */
> +		*asoc = NULL;
>  		break;
>  
>  	case SCTP_DISPOSITION_CONSUME:
> -	case SCTP_DISPOSITION_ABORT:
>  		/*
>  		 * We should no longer have much work to do here as the
>  		 * real work has been done as explicit commands above.
> 
