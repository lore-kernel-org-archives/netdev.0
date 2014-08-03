From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 19:28:43 -0700
Message-ID: <lrk6or$unu$2@ger.gmane.org>
References: <1406856100-21674-1-git-send-email-pmoody@google.com> <87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com> <lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com> <lrk4f5$4vo$2@ger.gmane.org> <r3nvbqajovk.fsf@perdido.sfo.corp.google.com>
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
> On Sat, Aug 02 2014 at 18:49, Alex Elsayed wrote:
> 
>> Well, the simple answer is "define a policy that allows everything except
>> network operations, and denies those" - this is reasonably simple if you
>> use ACL groups because you can set the 'default policy' with acl group 0.
> 
> I'm not understanding. I don't want to deny network operations, I just
> want to be able to associate the operation with the 'offending' process.
> 
>> Yeah, there are flavors of Tomoyo (out-of-tree) that can be stacked, and
>> there's the ongoing effort from Casey Schaufler to enable stacking more
>> generally.
> 
> Yeah, Casey was the one who suggested that I re-write this as an LSM. I
> think he saw the monitoring that I'm trying to do (as opposed to
> standard LSM deny/permit) as a good candidate for stacking.
> 
> 
>> CaitSith is rather different, in that rather than having domain be the
>> primary key things operate off of, the action is the central piece. So
>> while Tomoyo's policy syntax is
>>
>> DOMAIN
>>     POLICY ACTION CONDITION
>>
>> CaitSith's is
>>
>> ACTION [QUALIFIER]
>>     PRIORITY POLICY CONDITION [CONDITION...]
> 
> Interesting. It sounds like it's still primary designed to deny/permit
> actions (based on some policy) and I'm really just looking to monitor.

Oh, I see now. Okay, that's actually considerably simpler - I just had 
somehow gotten it fixated into my mind that the info would be used to decide 
on allow/deny actions.

The trick to do what you want is the 'audit' support in both - 
here I'll use CaitSith as an example since the syntax is nicer.

In the header of a CaitSith policy, you specify resource limits for audit 
logs in the format

quota audit[$audit_index] allowed=$max_logs_for_allowed_request 
unmatched=$max_logs_for_unmatched_request 
denied=$max_logs_for_denied_request

(sans the linewrapping)

Now, by default _everything_ logs into audit index zero, but you can have 
multiple audit logs, and you can specify which one an action logs into. The 
result:

# Don't pollute the logs
quota audit[0] allowed=0 unmatched=0 denied=0

# Allow a one-million-item backlog of events that don't
# have an explicit policy allow/deny set on this unusual audit field
quota audit[1] allowed=0 unmatched=1000000 denied=0

# Whenever someone tries to bind an AF_UNIX socket...
0 acl unix_stream_bind
    # ...log that sucker.
    audit 1

