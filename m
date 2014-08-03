From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 18:49:25 -0700
Message-ID: <lrk4f5$4vo$2@ger.gmane.org>
References: <1406856100-21674-1-git-send-email-pmoody@google.com> <87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com> <lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Moody wrote:

> 
> Hey Alex,
> 
> On Fri, Aug 01 2014 at 21:55, Alex Elsayed wrote:
>> Out of curiosity, have you looked at Tomoyo much at all? In particular,
>> it:
>>
>> 1.) Keeps a tree all the way back to init
>> 2.) Has network event hooks (see footnote [1])
>> 3.) Has an interactive API for managing policy violations
>> (tomoyo-queryd[2] uses it)
>> 4.) Is in mainline already.
> 
> I have looked at tomoyo before. There were a couple of things that kept
> it from being suitable for our needs:
> 
> The big one is that since the process tree is used to check policy, it's
> kept in-kernel and I'm primarily interested in having these events be
> easily exportable.  IIRC (at least when I last looked), it wasn't
> possible to stream the events as they happened. tomoyo-queryd looks like
> it gets me real-time policy violations, but I don't have any policy
> per-se. I'm just trying to monitor processes and network activity.

Well, the simple answer is "define a policy that allows everything except 
network operations, and denies those" - this is reasonably simple if you use 
ACL groups because you can set the 'default policy' with acl group 0.

> We also already use apparmor so switching to a different LSM was a
> non-trivial task (admittedly this is now an issue for hone too, but hone
> wasn't an LSM initially).

Yeah, there are flavors of Tomoyo (out-of-tree) that can be stacked, and 
there's the ongoing effort from Casey Schaufler to enable stacking more 
generally.

>> The combination is actually sufficient to implement what you want for
>> Hone _today_ as far as I can tell, and there's even the out-of-tree AKARI
>> variant if you want to use it together with another LSM.
>>
>> There's also Caitsith[3] (also from Tetsuo Handa), which might be even
>> better suited but is not in mainline yet.
> 
> I'm not familiar with AKARI or Caitsith. I'll take a look.

AKARI is basically just Tomoyo, but as a loadable kernel module and with 
(IIRC) stacking capability.

CaitSith is rather different, in that rather than having domain be the 
primary key things operate off of, the action is the central piece. So while 
Tomoyo's policy syntax is

DOMAIN
    POLICY ACTION CONDITION

CaitSith's is

ACTION [QUALIFIER]
    PRIORITY POLICY CONDITION [CONDITION...]

That's why I thought it might be a better fit - it'd allow you to specify 
_exactly_ the actions (socket connect, etc) you care about.

>  Cheers,
>  peter
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-security-module" in the body of a message to
> majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

