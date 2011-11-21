From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH for 2.6.32 (untested)] netns: Add quota for number of NET_NS instances.
Date: Sun, 20 Nov 2011 18:45:26 -0800
Message-ID: <m1mxbqurax.fsf@fess.ebiederm.org>
References: <201111201622.FDJ51567.VLFHQFMFOOSOtJ@I-love.SAKURA.ne.jp>
	<m1bos6wfnt.fsf@fess.ebiederm.org>
	<201111210157.pAL1vbRo089486@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43328 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888Ab1KUCoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 21:44:19 -0500
In-Reply-To: <201111210157.pAL1vbRo089486@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Mon, 21 Nov 2011 10:57:37 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Eric W. Biederman wrote:
>> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:
>> 
>> > In order to solve below problems, can we add sysctl variable for
>> > restricting number of NET_NS instances?
>> 
>> I don't have any particular problems with patch but I don't think it
>> will result in a working system that is easy to keep working.  Tuning
>> static limits can be fickle.
>
> What I worry is that, although clone() is an operation that is allowed to
> sleep, waiting for too long might be annoying for users, especially when the
> user cannot easily send Ctrl-C or SIGKILL. (I think ftp client is an
> example.)

An ftp client can always close the connection.  We already have to
contend for the net_mutex when both creating and destroying network
namespaces so I would be surprised if it is actually a problem.

But the reality is that under high connection load if we actually want
to use network namespaces we have to wait for previous network
namespaces to clean up.  So I am not particularly worried.  Especially
since most of the cleanup speed issues when there is a backlog have
been fixed in more recent kernels.

>> My inclination in this case the practical fix is that during network
>> namespace allocation someone take a look at the cleanup_list.  See
>> that there is ongoing cleanup activity, and wait until at least one
>> network namespace has cleaned up.  Perhaps by creating a work struct
>> and waiting for it to cycle through the netns workqueue.
>
> Are you suggesting that we should wait only when "the number of NET_NS
> instances exceeded quota" and "there is a dead NET_NS instance"?
> In other words, let clone() fail immediately if "the number of NET_NS
> instances exceeded quota" but "cleanup_list is empty"?
>
> If you are suggesting that we should always wait until "the number of NET_NS
> instances becomes smaller than quota", clone() might sleep too long when the
> user cannot easily send signals.

I am suggesting that if a netns instance is being cleaned up we should
wait for one netns instance to be cleaned up.  A single netns instance
does not take long to clean up (in general).  But a lot of netns
instances do take a while.

With waiting for one netns instance to be cleaned up we should be able
to guarantee that we don't develop a substantial backlog network
namespaces to be cleaned up.  And that was the problem.

I don't expect we need to do anything if there are no network namespaces
not being cleaned up.

There is of course debian's solution which was to simply tweak vsftp
to not use network namespaces on 2.6.32 and only enable the feature
on later kernels.  But you seem to want to do something a little
more substantial than that.

Eric
