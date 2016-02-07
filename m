From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Sun, 07 Feb 2016 18:43:14 +0000
Message-ID: <8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
	<1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:44440 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752918AbcBGSnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 13:43:37 -0500
In-Reply-To: <1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Fri, 05 Feb 2016 15:03:18 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Fri, 2016-02-05 at 21:44 +0000, Rainer Weikusat wrote:
>> The present unix_stream_read_generic contains various code sequences of
>> the form
>> 
>> err = -EDISASTER;
>> if (<test>)
>> 	goto out;
>> 
>> This has the unfortunate side effect of possibly causing the error code
>> to bleed through to the final
>> 
>> out:
>> 	return copied ? : err;
>> 
>> and then to be wrongly returned if no data was copied because the caller
>> didn't supply a data buffer, as demonstrated by the program available at
>> 
>> http://pad.lv/1540731
>> 
>> Change it such that err is only set if an error condition was detected.
>
>
> Well, if you replace the traditional flow
>
> err = -XXXX;
> if (test)
>      goto out;
>
> Then please add unlikely() to at least give a hint to the compiler.

There are really four of these, the two leading ones,

if (unlikely(sk->sk_state != TCP_ESTABLISHED)) {
	err = -EINVAL;
	goto out;
}

if (unlikely(flags & MSG_OOB)) {
	err = -EOPNOTSUPP;
	goto out;
}

one in between which was already in the function,

unix_state_lock(sk);
if (sock_flag(sk, SOCK_DEAD)) {
	err = -ECONNRESET;
	goto unlock;
}
[at the beginning of the loop]

and lastly,

unix_state_unlock(sk);
if (!timeo) {
	err = -EAGAIN;
	break;
}

mutex_unlock(&u->readlock);

timeo = unix_stream_data_wait(sk, timeo, last,
			      last_len);

As can be seen here, I've added unlikely() to the first two, left the
middle-one alone and didn't change the last one: That's not really an
error but a non-blocking read. My gut feeling about that would be that's
it's rather likely than unlikely but since I have no real information on
this, I don't know how to annotate it correctly (I'll gladly add
whatever annotation somebody else considers sensible).

> And please add a 'Fixes: .... ' tag for bug fixes.

Similarly, if you think this should be considered as 'fixing' anything
in particular, I'll also gladly add that. In my opinion, the real
problem is that the function disagrees with itself on how to use the err
variable: The start uses that to record an error which might need to be
reported, the return statement uses it to indicate that an error has
occurred. Hence, some kind of in-between translation must occur.
The mutex_lock_interruptible happened to do that but that was never it's
intended purpose.

NB: This is not an attempt to start an argument about that, it just
summarizes my understanding of the situation and I don't insist on this
viewpoint.

I'll send an updated patch with the changes so far, ie, the two
unlikelys.
