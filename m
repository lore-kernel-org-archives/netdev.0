From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 16:36:17 -0200
Message-ID: <5489E421.4020003@gmail.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com> <20141211170928.62c8e637@griffin> <20141211163335.GA27913@angus-think.wlc.globallogic.com> <5489D56E.4010505@gmail.com> <20141211190846.1e25e7fa@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vadim4j@gmail.com, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:50515 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758098AbaLKSg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 13:36:27 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so4403717qcq.11
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 10:36:26 -0800 (PST)
In-Reply-To: <20141211190846.1e25e7fa@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-2014 16:08, Jiri Benc wrote:
> On Thu, 11 Dec 2014 15:33:34 -0200, Marcelo Ricardo Leitner wrote:
>> In that case, it would be interesting to also accelerate the original use
>> case, no? So all usages we currently have will benefit from this speed up
>> without a change.
>>
>> if (command to be executed == myself)
>>     switch namespace, continue without fork/exec..
>
> It's never good idea to do such tricks behind the user's back. This
> particular case could easily break for users wanting to execute a
> different ip binary (for whatever reason).

Then the if() above wouldn't match. That if means to check 
/proc/self/exe against the result of the path expansion. If that fails, 
continue with the normal path. If it matches, it is the same binary, and 
no need to re-exec itself.

> All programs should do what they are told to do, not try to outsmart
> the user.

It's not outsmarting, it's just not being dumb and doing it the proper 
way. Bash itself does this twist a lot. If you just type 'echo hi', it 
won't execute /bin/echo but use a built-in version. But if you write 
"/bin/echo hi", it will use /bin/echo..

We could use the same idea. "ip netns exec ip" -> ellipse it and avoid 
the fork/exec. But if it's cmd != "ip", execute it..

Now consider other applications that are user of this command. They will 
have to implement something like:

if (this ip command has --netns argument) {
    cmd="ip --netns ..."
} else {
    cmd="ip netns exec ..."
}

which is ugly and inconvenient.

   Marcelo
